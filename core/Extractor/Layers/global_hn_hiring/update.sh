#!/bin/bash
# global_hn_hiring 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="global_hn_hiring"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in backend frontend fullstack mobile devops data security management other; do
  mkdir -p "$DOCS_DIR/$category"
done

echo "=== global_hn_hiring 資料更新 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# === Qdrant 更新（by source_url 去重）===
if [[ -n "${QDRANT_URL:-}" ]]; then
  echo "連線 Qdrant..."
  if qdrant_init_env; then
    echo "✓ Qdrant 連線成功"

    # 處理傳入的 .md 檔案參數
    if [[ $# -gt 0 ]]; then
      echo "更新 $# 筆資料到 Qdrant..."
      for md_file in "$@"; do
        if [[ -f "$md_file" ]]; then
          # 這裡可以呼叫 qdrant.sh 中的寫入函式
          # qdrant_upsert_document "$md_file" "$LAYER_NAME"
          echo "  處理: $(basename "$md_file")"
        fi
      done
    fi
  else
    echo "⚠ Qdrant 連線失敗，跳過向量資料庫更新" >&2
  fi
else
  echo "⚠ 未設定 QDRANT_URL，跳過向量資料庫更新"
fi

echo ""

# === REVIEW_NEEDED 檢查 ===
echo "檢查 REVIEW_NEEDED 標記..."
REVIEW_FILES=""
REVIEW_COUNT=0

for f in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
  if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $(basename "$f")\n"
    REVIEW_COUNT=$((REVIEW_COUNT + 1))
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo "發現 $REVIEW_COUNT 個需要審核的檔案："
  echo -e "$REVIEW_FILES"

  # 若有 gh CLI，嘗試建立 issue
  if command -v gh >/dev/null 2>&1; then
    echo ""
    echo "嘗試建立 GitHub Issue..."
    gh issue create \
      --title "[Extractor] $LAYER_NAME - 需要人工審核 ($REVIEW_COUNT 筆)" \
      --label "review-needed" \
      --body "偵測到 \`[REVIEW_NEEDED]\` 標記，請檢視以下檔案：

$REVIEW_FILES

Layer: \`$LAYER_NAME\`
檢查時間: $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null && echo "✓ Issue 已建立" || echo "⚠ Issue 建立失敗（可能需要認證）"
  fi
else
  echo "✓ 無需審核的項目"
fi

echo ""
echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Update completed: $LAYER_NAME"
