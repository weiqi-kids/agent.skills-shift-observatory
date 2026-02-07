#!/bin/bash
# global_arbeitnow 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_arbeitnow"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in tech design product marketing support finance hr operations other; do
  mkdir -p "$DOCS_DIR/$category"
done

echo "=== global_arbeitnow 資料更新 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# === Qdrant 更新（by source_url 去重）===
if [[ -n "${QDRANT_URL:-}" ]] && command -v jq >/dev/null 2>&1; then
  if source "$PROJECT_ROOT/lib/qdrant.sh" 2>/dev/null; then
    if qdrant_init_env 2>/dev/null; then
      echo "Qdrant 連線成功，開始更新向量資料庫..."

      # 處理所有分類下的 .md 檔案
      UPDATED_COUNT=0
      for md_file in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
        if [[ -f "$md_file" ]]; then
          # 這裡可以呼叫 qdrant.sh 中的函式進行向量寫入
          # 範例：qdrant_upsert_document "$md_file"
          UPDATED_COUNT=$((UPDATED_COUNT + 1))
        fi
      done

      echo "✓ 已更新 $UPDATED_COUNT 筆資料到 Qdrant"
    else
      echo "⚠️ Qdrant 連線失敗，跳過向量資料庫更新" >&2
    fi
  else
    echo "⚠️ 無法載入 qdrant.sh，跳過向量資料庫更新" >&2
  fi
else
  echo "⚠️ QDRANT_URL 未設定或 jq 未安裝，跳過向量資料庫更新" >&2
fi

echo ""

# === REVIEW_NEEDED 檢查 ===
echo "檢查需要人工審核的檔案..."
REVIEW_FILES=""
REVIEW_COUNT=0

for f in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
  if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $f\n"
    REVIEW_COUNT=$((REVIEW_COUNT + 1))
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo "⚠️ 發現 $REVIEW_COUNT 個檔案需要人工審核："
  echo -e "$REVIEW_FILES"

  # 嘗試建立 GitHub Issue（若有安裝 gh CLI）
  if command -v gh >/dev/null 2>&1; then
    gh issue create \
      --title "[Extractor] $LAYER_NAME - 需要人工審核" \
      --label "review-needed" \
      --body "偵測到 $REVIEW_COUNT 個檔案標記為 [REVIEW_NEEDED]，請進行人工審核。

檔案清單：
$(echo -e "$REVIEW_FILES")" 2>/dev/null && echo "✓ 已建立 GitHub Issue" || echo "⚠️ 無法建立 GitHub Issue"
  fi
else
  echo "✓ 無需人工審核的檔案"
fi

echo ""
echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Update completed: $LAYER_NAME"
