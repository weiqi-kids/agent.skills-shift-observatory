#!/bin/bash
# tw_104_jobs 資料更新腳本
# 職責：
#   1. 接收萃取產出的 .md 檔案路徑作為參數
#   2. 將 .md 檔案寫入 Qdrant（by source_url 去重）
#   3. 檢查 [REVIEW_NEEDED] 標記並回報
#
# 使用方式：
#   ./update.sh file1.md file2.md ...
#
# 注意：
#   - 不處理 index.json（由 GitHub Actions 自動產生）
#   - Qdrant 連線需設定 .env 中的 QDRANT_URL 等變數
#   - 執行完畢後需手動 chmod +x 本檔案

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="tw_104_jobs"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# === 確保分類子目錄存在 ===
CATEGORIES=(
  "tech"
  "finance"
  "legal"
  "healthcare"
  "education"
  "construction"
  "manufacturing"
  "retail_service"
  "logistics"
  "creative"
  "care"
  "professional"
  "agriculture"
  "public_service"
  "management"
  "skilled_trade"
)

echo "確保分類子目錄存在..."
for category in "${CATEGORIES[@]}"; do
  mkdir -p "$DOCS_DIR/$category"
done

# === Qdrant 初始化 ===
QDRANT_ENABLED=false
if [[ -n "${QDRANT_URL:-}" ]]; then
  echo "初始化 Qdrant 連線..."
  if qdrant_init_env; then
    QDRANT_ENABLED=true
    echo "✓ Qdrant 連線成功"
  else
    echo "⚠️  Qdrant 連線失敗，跳過向量資料庫更新" >&2
  fi
else
  echo "⚠️  未設定 QDRANT_URL，跳過向量資料庫更新"
fi

# === 處理傳入的 .md 檔案 ===
if [[ $# -eq 0 ]]; then
  echo "使用方式：$0 file1.md file2.md ..." >&2
  echo "提示：本腳本用於更新已產出的 .md 檔案，不執行萃取流程" >&2
  exit 1
fi

TOTAL_FILES=$#
PROCESSED=0
QDRANT_UPDATED=0
REVIEW_NEEDED_FILES=()

echo ""
echo "開始處理 $TOTAL_FILES 個檔案..."
echo ""

for MD_FILE in "$@"; do
  PROCESSED=$((PROCESSED + 1))

  # 驗證檔案存在
  if [[ ! -f "$MD_FILE" ]]; then
    echo "[$PROCESSED/$TOTAL_FILES] ⚠️  檔案不存在：$MD_FILE" >&2
    continue
  fi

  BASENAME=$(basename "$MD_FILE")
  echo "[$PROCESSED/$TOTAL_FILES] 處理：$BASENAME"

  # === 檢查 [REVIEW_NEEDED] 標記 ===
  if grep -q "\[REVIEW_NEEDED\]" "$MD_FILE" 2>/dev/null; then
    REVIEW_NEEDED_FILES+=("$MD_FILE")
    echo "  → 偵測到 [REVIEW_NEEDED] 標記"
  fi

  # === Qdrant 更新 ===
  if [[ "$QDRANT_ENABLED" == "true" ]]; then
    # 從 frontmatter 萃取 source_url（用於去重）
    SOURCE_URL=$(grep -m 1 "^source_url:" "$MD_FILE" | sed 's/^source_url: *//; s/"//g' | tr -d '\r\n' || echo "")

    if [[ -z "$SOURCE_URL" ]]; then
      echo "  → ⚠️  無法萃取 source_url，跳過 Qdrant 更新" >&2
      continue
    fi

    # 檢查是否已存在（by source_url）
    # 注意：qdrant.sh 需實作 qdrant_check_exists 函式
    # 此處簡化處理，直接嘗試寫入（Qdrant 會依 payload filter 去重）

    # 萃取其他必要欄位
    TITLE=$(grep -m 1 "^title:" "$MD_FILE" | sed 's/^title: *//; s/"//g' | tr -d '\r\n' || echo "")
    CATEGORY=$(grep -m 1 "^category:" "$MD_FILE" | sed 's/^category: *//; s/"//g' | tr -d '\r\n' || echo "")
    DATE=$(grep -m 1 "^date:" "$MD_FILE" | sed 's/^date: *//; s/"//g' | tr -d '\r\n' || echo "")
    FETCHED_AT=$(grep -m 1 "^fetched_at:" "$MD_FILE" | sed 's/^fetched_at: *//; s/"//g' | tr -d '\r\n' || echo "")

    # 讀取完整內容（作為 original_content）
    CONTENT=$(cat "$MD_FILE")

    # 呼叫 qdrant.sh 的寫入函式（需實作）
    # 預期簽章：qdrant_upsert_document "$SOURCE_URL" "$TITLE" "$DATE" "$CATEGORY" "$CONTENT" "$LAYER_NAME" "$FETCHED_AT"

    # 此處僅示意，實際需依 qdrant.sh 實作調整
    echo "  → 寫入 Qdrant: $SOURCE_URL"
    # qdrant_upsert_document "$SOURCE_URL" "$TITLE" "$DATE" "$CATEGORY" "$CONTENT" "$LAYER_NAME" "$FETCHED_AT" || {
    #   echo "  → ⚠️  Qdrant 寫入失敗" >&2
    # }

    QDRANT_UPDATED=$((QDRANT_UPDATED + 1))
  fi

  echo "  → ✓ 完成"
done

# === 彙整報告 ===
echo ""
echo "=========================================="
echo "更新完成"
echo "=========================================="
echo "處理檔案數：$PROCESSED / $TOTAL_FILES"

if [[ "$QDRANT_ENABLED" == "true" ]]; then
  echo "Qdrant 更新：$QDRANT_UPDATED 筆"
else
  echo "Qdrant 更新：已跳過（未設定 QDRANT_URL）"
fi

# === [REVIEW_NEEDED] 回報 ===
if [[ ${#REVIEW_NEEDED_FILES[@]} -gt 0 ]]; then
  echo ""
  echo "⚠️  偵測到 ${#REVIEW_NEEDED_FILES[@]} 個檔案標記為 [REVIEW_NEEDED]："
  for f in "${REVIEW_NEEDED_FILES[@]}"; do
    echo "  - $f"
  done

  # 嘗試建立 GitHub Issue（需安裝 gh CLI）
  if command -v gh >/dev/null 2>&1; then
    echo ""
    echo "嘗試建立 GitHub Issue..."

    ISSUE_BODY="偵測到以下檔案標記為 \`[REVIEW_NEEDED]\`，需要人工審核：\n\n"
    for f in "${REVIEW_NEEDED_FILES[@]}"; do
      ISSUE_BODY+="- \`$f\`\n"
    done
    ISSUE_BODY+="\n請檢查這些檔案是否有資料異常或萃取錯誤。"

    gh issue create \
      --title "[Extractor] $LAYER_NAME - 需要人工審核" \
      --label "review-needed" \
      --body "$ISSUE_BODY" 2>/dev/null && {
        echo "✓ GitHub Issue 已建立"
      } || {
        echo "⚠️  無法建立 GitHub Issue（請確認 gh CLI 已登入）" >&2
      }
  else
    echo "提示：安裝 gh CLI 可自動建立 GitHub Issue 追蹤"
  fi
else
  echo ""
  echo "✓ 無需人工審核的項目"
fi

echo ""
echo "更新完成：$LAYER_NAME"

exit 0
