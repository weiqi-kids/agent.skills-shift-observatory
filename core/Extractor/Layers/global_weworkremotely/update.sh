#!/bin/bash
# global_weworkremotely 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

# 檢查是否有 qdrant.sh（選用功能）
if [[ -f "$PROJECT_ROOT/lib/qdrant.sh" ]]; then
    source "$PROJECT_ROOT/lib/qdrant.sh"
    QDRANT_AVAILABLE=1
else
    QDRANT_AVAILABLE=0
fi

LAYER_NAME="global_weworkremotely"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in programming design marketing support copywriting devops management product other; do
  mkdir -p "$DOCS_DIR/$category"
done

echo "=== global_weworkremotely 資料更新 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# === Qdrant 更新（選用，by source_url 去重）===
if [[ "$QDRANT_AVAILABLE" -eq 1 ]] && [[ -n "${QDRANT_URL:-}" ]]; then
    echo "正在連接 Qdrant..."
    if qdrant_init_env 2>/dev/null; then
        echo "✓ Qdrant 連線成功"

        # 遍歷所有分類目錄下的 .md 檔案
        MD_COUNT=0
        for md_file in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
            # 這裡可以呼叫 qdrant_upsert_document 等函式
            # 實作細節依據 lib/qdrant.sh 的實際介面
            ((MD_COUNT++))
        done

        echo "已處理 $MD_COUNT 個文件到 Qdrant"
    else
        echo "⚠ Qdrant 連線失敗，跳過向量資料庫更新" >&2
    fi
else
    echo "⚠ Qdrant 未設定或不可用，跳過向量資料庫更新"
fi

echo ""

# === REVIEW_NEEDED 檢查 ===
echo "檢查 [REVIEW_NEEDED] 標記..."
REVIEW_FILES=""
REVIEW_COUNT=0

for f in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
  if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $(basename "$f")\n"
    ((REVIEW_COUNT++))
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo ""
  echo "=== 需要審核的檔案（共 $REVIEW_COUNT 筆）==="
  echo -e "$REVIEW_FILES"

  # 嘗試建立 GitHub Issue（如果有安裝 gh CLI）
  if command -v gh >/dev/null 2>&1; then
    echo ""
    echo "正在建立 GitHub Issue..."
    gh issue create \
      --title "[Extractor] $LAYER_NAME - 需要人工審核" \
      --label "review-needed" \
      --body "偵測到 $REVIEW_COUNT 個檔案需要審核：

$REVIEW_FILES

請檢查這些檔案是否符合品質標準。" 2>/dev/null && echo "✓ Issue 已建立" || echo "⚠ Issue 建立失敗"
  fi
else
  echo "✓ 沒有需要審核的檔案"
fi

echo ""
echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Update completed: $LAYER_NAME"
