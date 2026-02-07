#!/bin/bash
# global_manpower_outlook 資料更新腳本
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="global_manpower_outlook"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in net_outlook_index industry_outlook country_comparison seasonal_trend talent_shortage; do
  mkdir -p "$DOCS_DIR/$category"
done

# === Qdrant 更新（by source_url 去重）===
if [[ -n "${QDRANT_URL:-}" ]]; then
  qdrant_init_env || echo "Qdrant 連線失敗" >&2
fi

# === REVIEW_NEEDED 檢查 ===
REVIEW_FILES=""
for f in "$@"; do
  if [[ -f "$f" ]] && grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $f\n"
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo "需要審核：" && echo -e "$REVIEW_FILES"
  command -v gh >/dev/null 2>&1 && gh issue create \
    --title "[Extractor] $LAYER_NAME - 需要人工審核" \
    --label "review-needed" \
    --body "偵測到 [REVIEW_NEEDED] 標記" 2>/dev/null || true
fi

echo "Update completed: $LAYER_NAME"
