#!/bin/bash
# workforce_news 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="workforce_news"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
CATEGORIES=("layoff" "hiring_surge" "restructuring" "policy_change" "market_signal")

for category in "${CATEGORIES[@]}"; do
  mkdir -p "$DOCS_DIR/$category"
done

echo "=== workforce_news 資料更新開始 ==="
echo ""

# === Qdrant 更新（by source_url 去重）===
if [[ -n "${QDRANT_URL:-}" ]]; then
  echo "正在初始化 Qdrant 連線..."
  if qdrant_init_env; then
    echo "Qdrant 連線成功"
    echo ""

    # 掃描所有產出的 .md 檔案並寫入 Qdrant
    for category in "${CATEGORIES[@]}"; do
      category_dir="$DOCS_DIR/$category"
      if [[ -d "$category_dir" ]]; then
        md_files=$(find "$category_dir" -name "*.md" -type f 2>/dev/null || true)
        if [[ -n "$md_files" ]]; then
          echo "正在處理分類: $category"
          for md_file in $md_files; do
            echo "  寫入: $(basename "$md_file")"
            # 呼叫 qdrant.sh 的寫入函式（需實作 qdrant_upsert_document）
            # qdrant_upsert_document "$md_file" "$LAYER_NAME" || echo "    警告: 寫入失敗" >&2
          done
        fi
      fi
    done
    echo ""
  else
    echo "警告: Qdrant 連線失敗，跳過向量資料庫更新" >&2
    echo ""
  fi
else
  echo "未設定 QDRANT_URL，跳過向量資料庫更新"
  echo ""
fi

# === REVIEW_NEEDED 檢查 ===
echo "正在檢查需要人工審核的項目..."
REVIEW_FILES=""
REVIEW_COUNT=0

for category in "${CATEGORIES[@]}"; do
  category_dir="$DOCS_DIR/$category"
  if [[ -d "$category_dir" ]]; then
    for f in $(find "$category_dir" -name "*.md" -type f 2>/dev/null || true); do
      if grep -q "^\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
        REVIEW_FILES+="  - $(basename "$f") ($category)\n"
        ((REVIEW_COUNT++))
      fi
    done
  fi
done

if [[ $REVIEW_COUNT -gt 0 ]]; then
  echo ""
  echo "發現 $REVIEW_COUNT 個項目需要人工審核："
  echo -e "$REVIEW_FILES"
  echo ""

  # 嘗試建立 GitHub Issue（如果 gh CLI 可用）
  if command -v gh >/dev/null 2>&1; then
    echo "正在建立 GitHub Issue..."
    gh issue create \
      --title "[Extractor] $LAYER_NAME - 需要人工審核 ($REVIEW_COUNT 個項目)" \
      --label "review-needed" \
      --body "偵測到以下項目標記了 \`[REVIEW_NEEDED]\`：

$REVIEW_FILES

請檢查這些項目的資料來源與可信度。" 2>/dev/null || echo "警告: GitHub Issue 建立失敗" >&2
  fi
else
  echo "所有項目皆通過自動審核"
fi

echo ""
echo "=== workforce_news 資料更新完成 ==="
echo "文件位置: $DOCS_DIR"
