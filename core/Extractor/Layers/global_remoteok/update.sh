#!/bin/bash
# global_remoteok 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json(由 GitHub Actions 產生)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="global_remoteok"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in tech design product marketing support finance hr operations other; do
  mkdir -p "$DOCS_DIR/$category"
done

echo "=== global_remoteok 資料更新 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# === Qdrant 更新(by source_url 去重)===
if [[ -n "${QDRANT_URL:-}" ]]; then
  echo "正在連線至 Qdrant..."
  if qdrant_init_env; then
    echo "✓ Qdrant 連線成功"

    # 處理傳入的 .md 檔案列表
    MD_FILES="${@:-}"
    if [[ -n "$MD_FILES" ]]; then
      echo "更新 Qdrant 索引: $MD_FILES"
      # TODO: 實作 Qdrant 寫入邏輯(呼叫 qdrant.sh 中的函式)
    else
      echo "未提供 .md 檔案,跳過 Qdrant 更新"
    fi
  else
    echo "✗ Qdrant 連線失敗,跳過索引更新" >&2
  fi
else
  echo "未設定 QDRANT_URL,跳過 Qdrant 更新"
fi

echo ""

# === REVIEW_NEEDED 檢查 ===
echo "檢查需要審核的檔案..."
REVIEW_FILES=""
REVIEW_COUNT=0

for f in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
  if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $f\n"
    REVIEW_COUNT=$((REVIEW_COUNT + 1))
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo ""
  echo "⚠️  發現 $REVIEW_COUNT 個需要審核的檔案:"
  echo -e "$REVIEW_FILES"

  # 嘗試建立 GitHub Issue(若有安裝 gh CLI)
  if command -v gh >/dev/null 2>&1; then
    ISSUE_BODY="偵測到 [REVIEW_NEEDED] 標記,請人工確認以下檔案:\n\n$REVIEW_FILES"
    gh issue create \
      --title "[Extractor] $LAYER_NAME - 需要人工審核" \
      --label "review-needed" \
      --body "$ISSUE_BODY" 2>/dev/null || echo "無法建立 GitHub Issue(可能不在 git repo 中)"
  fi
else
  echo "✓ 無需要審核的檔案"
fi

echo ""
echo "=== 更新完成 ==="
echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Update completed: $LAYER_NAME"
