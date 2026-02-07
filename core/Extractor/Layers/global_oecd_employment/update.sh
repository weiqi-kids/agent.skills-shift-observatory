#!/bin/bash
# global_oecd_employment 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="global_oecd_employment"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in unemployment_rate employment_population labor_participation industry_employment wage_statistics; do
  mkdir -p "$DOCS_DIR/$category"
done

# === Qdrant 更新（by source_url 去重）===
if [[ -n "${QDRANT_URL:-}" ]]; then
  qdrant_init_env || echo "Qdrant 連線失敗" >&2
fi

# === REVIEW_NEEDED 檢查（僅檢查傳入的檔案）===
REVIEW_FILES=""
for f in "$@"; do
  if [[ -f "$f" ]] && grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $f\n"
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo "需要審核：" && echo -e "$REVIEW_FILES"
  # 若有 gh CLI 可建立 issue
  if command -v gh >/dev/null 2>&1; then
    gh issue create \
      --title "[Extractor] $LAYER_NAME - 需要人工審核" \
      --label "review-needed" \
      --body "偵測到 [REVIEW_NEEDED] 標記：
$REVIEW_FILES" 2>/dev/null || true
  fi
fi

echo "Update completed: $LAYER_NAME"
