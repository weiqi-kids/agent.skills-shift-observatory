#!/usr/bin/env python3
"""qdrant_backfill.py — 高效批次回填 Qdrant 向量資料庫。

過去各 Layer 的 update.sh 並未實際寫入 Qdrant，導致 collection 長期僅有少量點。
本工具掃描 docs/Extractor/{layer}/**.md，批次去重 → 批次 embedding → 批次 upsert，
以 source_url 的確定性 UUID(v5) 為主鍵，可安全重複執行（idempotent）。

用法：
    scripts/qdrant_backfill.py            # 全部啟用的 Layer
    scripts/qdrant_backfill.py workforce_news funding_signals
    scripts/qdrant_backfill.py --dry-run  # 僅統計新增/已存在，不寫入

相依：Python 3.8+（僅標準函式庫）、.env（QDRANT_URL/API_KEY/COLLECTION、OPENAI_API_KEY、EMBEDDING_*）。
"""
import json
import os
import re
import sys
import time
import urllib.request
import urllib.error
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXTRACTOR = ROOT / "docs" / "Extractor"
LAYERS = ROOT / "core" / "Extractor" / "Layers"

DEDUP_CHUNK = 256     # 每次批次查詢的 point id 數
EMBED_CHUNK = 64      # 每次 embedding 的文字數
UPSERT_CHUNK = 64     # 每次 upsert 的 point 數


def load_env():
    env_path = ROOT / ".env"
    if env_path.exists():
        for line in env_path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            v = v.strip().strip('"').strip("'")
            os.environ.setdefault(k.strip(), v)


def http_json(url, payload, headers, method="POST", timeout=120, retries=3):
    data = None if method == "GET" else json.dumps(payload).encode("utf-8")
    last = None
    for attempt in range(1, retries + 1):
        req = urllib.request.Request(url, data=data, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            body = e.read().decode("utf-8", "replace")
            last = f"HTTP {e.code}: {body[:200]}"
            if e.code in (429, 500, 502, 503, 504) and attempt < retries:
                time.sleep(2 * attempt)
                continue
            raise RuntimeError(last)
        except (urllib.error.URLError, TimeoutError) as e:
            last = str(e)
            if attempt < retries:
                time.sleep(2 * attempt)
                continue
            raise RuntimeError(last)
    raise RuntimeError(last or "unknown")


def id_to_uuid(s):
    return str(uuid.uuid5(uuid.NAMESPACE_URL, s))


FM_RE = re.compile(r"^---\s*$(.*?)^---\s*$", re.M | re.S)
KV_RE = re.compile(r"^([A-Za-z_][\w]*):\s*(.*)$")


def doc_key_for(path, layer):
    """每份文件的唯一鍵：docs/Extractor 之下的相對路徑（去副檔名）。
    避免統計型 Layer 多筆 .md 共用同一 source_url 時塌縮成單一向量點。"""
    try:
        rel = path.relative_to(EXTRACTOR)
        key = str(rel)
    except ValueError:
        key = str(path)
    if key.endswith(".md"):
        key = key[:-3]
    return key


def parse_md(path, layer):
    txt = path.read_text(encoding="utf-8", errors="replace")
    head = txt.split("---", 1)[0] if "---" in txt else txt
    review = "[REVIEW_NEEDED]" in head
    fm, body = {}, txt
    m = FM_RE.search(txt)
    if m:
        body = txt[m.end():].strip()
        for line in m.group(1).splitlines():
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            mm = KV_RE.match(line)
            if not mm:
                continue
            k, v = mm.group(1), mm.group(2).strip()
            if len(v) >= 2 and v[0] in "\"'" and v[-1] == v[0]:
                v = v[1:-1]
            fm[k] = v
    src = fm.get("source_url", "").strip()
    if not src:
        return None
    title = fm.get("title", "").strip()
    if not title:
        # 後備：部分 Layer（如 hn_hiring、oecd_stats）無 title 欄位，改取正文第一個 H1 標題
        hm = re.search(r"^#\s+(.+?)\s*$", body, re.M)
        if hm:
            title = hm.group(1).strip()
    payload = {
        "source_url": src,
        "title": title,
        "source_layer": fm.get("source_layer", layer) or layer,
        "category": fm.get("category", ""),
        "date": fm.get("date", ""),
        "fetched_at": fm.get("fetched_at", ""),
        "severity": fm.get("severity", ""),
        "confidence": fm.get("confidence", ""),
        "review_needed": review,
        "original_content": body[:4000],
    }
    return {
        "point_id": id_to_uuid(doc_key_for(path, layer)),
        "source_url": src,
        "payload": payload,
        "embed_text": (title + "\n\n" + body)[:6000],
    }


def chunked(seq, n):
    for i in range(0, len(seq), n):
        yield seq[i:i + n]


def existing_ids(qurl, coll, qheaders, ids):
    found = set()
    for batch in chunked(ids, DEDUP_CHUNK):
        res = http_json(f"{qurl}/collections/{coll}/points",
                        {"ids": batch, "with_payload": False, "with_vector": False},
                        qheaders)
        for p in res.get("result", []):
            found.add(str(p.get("id")))
    return found


def embed(oai_url, oai_headers, model, texts):
    vectors = []
    for batch in chunked(texts, EMBED_CHUNK):
        clean = [t[:4000] if len(t) > 4000 else t for t in batch]
        res = http_json(f"{oai_url}/embeddings", {"input": clean, "model": model}, oai_headers)
        data = sorted(res["data"], key=lambda d: d["index"])
        vectors.extend(d["embedding"] for d in data)
    return vectors


def upsert(qurl, coll, qheaders, points):
    for batch in chunked(points, UPSERT_CHUNK):
        http_json(f"{qurl}/collections/{coll}/points", {"points": batch}, qheaders, method="PUT")


def discover_layers():
    out = []
    for d in sorted(LAYERS.glob("*/")):
        if (d / ".disabled").exists():
            continue
        layer = d.name
        if (EXTRACTOR / layer).is_dir():
            out.append(layer)
    return out


def main():
    load_env()
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry-run" in sys.argv

    qurl = os.environ.get("QDRANT_URL", "").rstrip("/")
    coll = os.environ.get("QDRANT_COLLECTION", "")
    qkey = os.environ.get("QDRANT_API_KEY", "")
    okey = os.environ.get("OPENAI_API_KEY", "")
    oai_url = os.environ.get("CHATGPT_BASE_URL", "https://api.openai.com/v1").rstrip("/")
    model = os.environ.get("EMBEDDING_MODEL", "text-embedding-3-small")
    if not (qurl and coll and qkey and okey):
        print("❌ 缺少必要環境變數（QDRANT_URL/COLLECTION/API_KEY、OPENAI_API_KEY）", file=sys.stderr)
        return 1

    qheaders = {"Content-Type": "application/json", "api-key": qkey}
    oai_headers = {"Content-Type": "application/json", "Authorization": f"Bearer {okey}"}
    proj = os.environ.get("CHATGPT_PROJECT_ID") or os.environ.get("OPENAI_PROJECT_ID")
    if proj:
        oai_headers["OpenAI-Project"] = proj

    layers = args or discover_layers()
    print(f"=== Qdrant backfill ===\nCollection: {coll}\nLayers ({len(layers)}): {' '.join(layers)}\n")

    g_new = g_skip = g_fail = 0
    for layer in layers:
        ldir = EXTRACTOR / layer
        if not ldir.is_dir():
            print(f"-- {layer}: (no docs, skip)")
            continue
        files = [f for f in ldir.rglob("*.md") if "/raw/" not in str(f)]
        docs = []
        for f in files:
            try:
                d = parse_md(f, layer)
                if d:
                    docs.append(d)
            except Exception as e:
                print(f"   parse-fail {f.name}: {e}", file=sys.stderr)
        # 去重（同一 source_url 在同 layer 內只留一份）
        uniq = {}
        for d in docs:
            uniq[d["point_id"]] = d
        docs = list(uniq.values())

        ids = [d["point_id"] for d in docs]
        have = existing_ids(qurl, coll, qheaders, ids) if ids else set()
        new = [d for d in docs if d["point_id"] not in have]
        skip = len(docs) - len(new)
        print(f"-- {layer}: {len(files)} md, {len(docs)} uniq | new={len(new)} skip={skip}", flush=True)

        if dry or not new:
            g_new += len(new); g_skip += skip
            continue
        try:
            vecs = embed(oai_url, oai_headers, model, [d["embed_text"] for d in new])
            points = [{"id": d["point_id"], "vector": v, "payload": d["payload"]}
                      for d, v in zip(new, vecs)]
            upsert(qurl, coll, qheaders, points)
            print(f"   ✓ upserted {len(points)}", flush=True)
            g_new += len(points); g_skip += skip
        except Exception as e:
            print(f"   ✗ layer {layer} failed: {e}", file=sys.stderr)
            g_fail += len(new)

    print(f"\n=== done === new={g_new} skip={g_skip} fail={g_fail}")
    try:
        info = http_json(f"{qurl}/collections/{coll}", {}, qheaders, method="GET")
        print(f"Qdrant points now: {info['result']['points_count']}")
    except Exception:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
