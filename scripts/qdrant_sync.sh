#!/bin/bash
# qdrant_sync.sh — 將 Extractor Layer 萃取的 .md 同步寫入 Qdrant 向量資料庫
#
# 用途：
#   - 補齊 / 重建 Qdrant 向量（update.sh 過去未實際寫入，故需此回填工具）
#   - 以 source_url 的確定性 UUID 為主鍵去重，可安全重複執行（idempotent）
#
# 用法：
#   scripts/qdrant_sync.sh all                # 同步所有啟用的 Layer
#   scripts/qdrant_sync.sh workforce_news ... # 同步指定 Layer（可多個）
#
# 相依：lib/qdrant.sh（qdrant_upsert_document）、lib/chatgpt.sh（embedding）、.env

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 載入環境變數
if [[ -f "$PROJECT_ROOT/.env" ]]; then
  set -a; source "$PROJECT_ROOT/.env"; set +a
fi

source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/chatgpt.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

chatgpt_init_env >/dev/null 2>&1 || { echo "❌ chatgpt_init_env 失敗（檢查 OPENAI_API_KEY）" >&2; exit 1; }
qdrant_init_env  >/dev/null 2>&1 || { echo "❌ qdrant_init_env 失敗（檢查 QDRANT_URL/API_KEY）" >&2; exit 1; }

EXTRACTOR_DIR="$PROJECT_ROOT/docs/Extractor"
LAYERS_DIR="$PROJECT_ROOT/core/Extractor/Layers"

# 決定要處理的 Layer 清單
declare -a TARGETS=()
if [[ $# -eq 0 || "${1:-}" == "all" ]]; then
  for d in "$LAYERS_DIR"/*/; do
    l="$(basename "$d")"
    [[ -f "$d/.disabled" ]] && continue          # 跳過停用 Layer
    [[ -d "$EXTRACTOR_DIR/$l" ]] || continue       # 無萃取資料則跳過
    TARGETS+=("$l")
  done
else
  TARGETS=("$@")
fi

echo "=== Qdrant 同步開始 ==="
echo "Collection: ${QDRANT_COLLECTION}"
echo "目標 Layer（${#TARGETS[@]}）: ${TARGETS[*]}"
echo ""

grand_new=0; grand_skip=0; grand_fail=0
for layer in "${TARGETS[@]}"; do
  layer_docs="$EXTRACTOR_DIR/$layer"
  if [[ ! -d "$layer_docs" ]]; then
    echo "⚠️  跳過 $layer：無 docs/Extractor/$layer"
    continue
  fi
  # 收集所有 .md（排除 raw/ 與內部規劃檔）— bash 3.2 相容（無 mapfile）
  files=()
  while IFS= read -r _f; do
    [[ -n "$_f" ]] && files+=("$_f")
  done < <(find "$layer_docs" -name "*.md" -not -path "*/raw/*" -type f 2>/dev/null | sort)
  echo "── ${layer} : ${#files[@]} md"
  new=0; skip=0; fail=0
  [[ ${#files[@]} -eq 0 ]] && { echo "   (no data, skip)"; continue; }
  for f in "${files[@]}"; do
    out="$(qdrant_upsert_document "$f" "$layer" 2>/dev/null)"
    case "$out" in
      *"⊘ 已存在"*) ((skip++)) ;;
      *"✓ 寫入"*)   ((new++)) ;;
      *)            ((fail++)); echo "    ✗ 失敗: $(basename "$f")" >&2 ;;
    esac
  done
  echo "   new=${new} skip=${skip} fail=${fail}"
  grand_new=$((grand_new+new)); grand_skip=$((grand_skip+skip)); grand_fail=$((grand_fail+fail))
done

echo ""
echo "=== 同步完成 ==="
echo "Total: new=${grand_new} skip=${grand_skip} fail=${grand_fail}"
points="$(curl -s -H "api-key: ${QDRANT_API_KEY}" "${QDRANT_URL%/}/collections/${QDRANT_COLLECTION}" 2>/dev/null | jq -r '.result.points_count // "?"')"
echo "Qdrant points now: ${points}"
