#!/bin/bash
# global_abs 資料更新腳本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/core.sh" 2>/dev/null || true
source "$PROJECT_ROOT/lib/qdrant.sh" 2>/dev/null || true

LAYER_NAME="global_abs"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in labour_force employment unemployment; do
  mkdir -p "$DOCS_DIR/$category"
done

echo "=== $LAYER_NAME 資料更新 ==="

# Qdrant 更新
if [[ -n "${QDRANT_URL:-}" ]]; then
  echo "更新 Qdrant 向量資料庫..."
  
  for md_file in "$@"; do
    if [[ -f "$md_file" ]]; then
      qdrant_upsert_from_md "$md_file" 2>/dev/null || echo "  警告: $md_file 更新失敗"
    fi
  done
fi

# REVIEW_NEEDED 檢查
echo "檢查 [REVIEW_NEEDED] 標記..."
REVIEW_FILES=""
for f in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
  if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $f\n"
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo "需要審核的檔案："
  echo -e "$REVIEW_FILES"
fi

echo "=== 更新完成 ==="
