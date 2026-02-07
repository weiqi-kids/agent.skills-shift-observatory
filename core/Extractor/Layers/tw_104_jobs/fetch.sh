#!/bin/bash
# tw_104_jobs 資料擷取腳本
# 職責：從 104 人力銀行 API 擷取 53 個職務角色的職缺資料
# 輸出：docs/Extractor/tw_104_jobs/raw/jobs-{YYYYMMDD_HHMMSS}.jsonl
#
# 使用方式：
#   ./fetch.sh                    # 預設每個角色擷取 100 筆
#   ./fetch.sh --results 50       # 每個角色擷取 50 筆
#   ./fetch.sh --test             # 測試模式（僅擷取 1 個角色）
#
# 注意：
#   - 使用 104 非官方 API（可能隨時失效）
#   - 每次 API 請求間隨機暫停 3-5 秒（避免被封鎖）
#   - 單一 API 呼叫最多回傳 20 筆（分頁處理）
#
# API 狀態說明：
#   - 此腳本使用 104 網站的內部 API，非官方公開 API
#   - 104 官方開發者 API: https://developers.104.com.tw/
#   - 若頻繁失敗，建議申請官方 API 或改用 tw_govjobs Layer（台灣就業通 Open API）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="tw_104_jobs"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
ROLES_FILE="$SCRIPT_DIR/roles.json"

# 確保輸出目錄存在
mkdir -p "$RAW_DIR"

# === 參數解析 ===
RESULTS_PER_ROLE="${RESULTS_PER_ROLE:-100}"  # 每個角色擷取的職缺數量（預設 100）
PAGE_SIZE=20  # 104 API 每頁最多回傳 20 筆
TEST_MODE=false  # 測試模式（僅擷取 1 個角色）
CONSECUTIVE_FAILURES=0  # 連續失敗計數
MAX_CONSECUTIVE_FAILURES=5  # 最大連續失敗次數（超過則中止）

# 支援命令列參數
while [[ $# -gt 0 ]]; do
  case "$1" in
    --results)
      RESULTS_PER_ROLE="$2"
      shift 2
      ;;
    --test)
      TEST_MODE=true
      RESULTS_PER_ROLE=10
      shift
      ;;
    *)
      echo "未知參數：$1" >&2
      echo "使用方式：$0 [--results N] [--test]" >&2
      exit 1
      ;;
  esac
done

# === 驗證 roles.json 存在 ===
if [[ ! -f "$ROLES_FILE" ]]; then
  echo "錯誤：找不到 $ROLES_FILE" >&2
  exit 1
fi

# === 產生輸出檔名 ===
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$RAW_DIR/jobs-$TIMESTAMP.jsonl"

echo "=== tw_104_jobs 資料擷取開始 ==="
echo "輸出檔案：$OUTPUT_FILE"
echo "每個角色擷取：$RESULTS_PER_ROLE 筆"
if [[ "$TEST_MODE" == "true" ]]; then
  echo "⚠️  測試模式：僅擷取第 1 個角色"
fi
echo ""

# === API 連線測試 ===
echo "測試 104 API 連線..."
TEST_URL="https://www.104.com.tw/jobs/search/list?ro=0&kwop=7&keyword=%E5%B7%A5%E7%A8%8B%E5%B8%AB&page=1"
TEST_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  -H "Referer: https://www.104.com.tw/jobs/search/" \
  --max-time 15 \
  "$TEST_URL" 2>/dev/null || echo "000")

if [[ "$TEST_CODE" != "200" ]]; then
  echo ""
  echo "⚠️  104 API 連線失敗 (HTTP $TEST_CODE)"
  echo ""
  echo "=== 可能原因 ==="
  echo "1. 104 網站暫時無法存取"
  echo "2. IP 被暫時封鎖（請稍後重試）"
  echo "3. API 結構已變動"
  echo ""
  echo "=== 建議行動 ==="
  echo "1. 稍後重試"
  echo "2. 申請 104 官方開發者 API: https://developers.104.com.tw/"
  echo "3. 改用 tw_govjobs Layer（台灣就業通 Open API）作為替代"
  echo ""

  # 建立空輸出檔並記錄時間
  touch "$OUTPUT_FILE"
  date +"%Y%m%d_%H%M%S" > "$RAW_DIR/.last_fetch"
  echo "API_ERROR: HTTP $TEST_CODE at $(date)" >> "$RAW_DIR/.fetch_errors.log"
  exit 1
fi

echo "✓ API 連線正常"
echo ""

# === 讀取角色清單 ===
# roles.json 是一個 JSON 陣列，每個元素包含：
# { "id": 1, "search_term": "軟體工程師", "key": "software_engineer", "sector": "tech", ... }

TOTAL_ROLES=$(jq 'length' "$ROLES_FILE")
TOTAL_JOBS=0
CURRENT_ROLE=0
FAILED_ROLES=0

# 測試模式僅擷取第一個角色
if [[ "$TEST_MODE" == "true" ]]; then
  TOTAL_ROLES=1
fi

echo "共 $TOTAL_ROLES 個角色需要擷取"
echo ""

# === 逐一擷取每個角色 ===
jq -c '.[]' "$ROLES_FILE" | head -n "$TOTAL_ROLES" | while IFS= read -r role; do
  CURRENT_ROLE=$((CURRENT_ROLE + 1))

  ROLE_ID=$(echo "$role" | jq -r '.id')
  SEARCH_TERM=$(echo "$role" | jq -r '.search_term')
  ROLE_KEY=$(echo "$role" | jq -r '.key')
  SECTOR=$(echo "$role" | jq -r '.sector')

  echo "[$CURRENT_ROLE/$TOTAL_ROLES] 擷取角色：$SEARCH_TERM (key: $ROLE_KEY, sector: $SECTOR)"

  # 計算需要的頁數
  TOTAL_PAGES=$(( (RESULTS_PER_ROLE + PAGE_SIZE - 1) / PAGE_SIZE ))
  ROLE_JOBS=0

  for PAGE in $(seq 1 "$TOTAL_PAGES"); do
    # URL encode search_term
    ENCODED_TERM=$(echo "$SEARCH_TERM" | jq -sRr @uri)

    # 104 API URL
    API_URL="https://www.104.com.tw/jobs/search/list?ro=0&kwop=7&keyword=${ENCODED_TERM}&expansionType=area,spec,com,job,wf,wktm&mode=s&jobsource=2018indexpoc&order=1&asc=0&page=${PAGE}"

    echo "  → 頁面 $PAGE/$TOTAL_PAGES (已擷取 $ROLE_JOBS 筆)"

    # 呼叫 API（加上必要的 headers）
    HTTP_CODE=$(curl -s -o "$RAW_DIR/.tmp_response.json" -w "%{http_code}" \
      -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
      -H "Referer: https://www.104.com.tw/jobs/search/" \
      "$API_URL")

    if [[ "$HTTP_CODE" != "200" ]]; then
      echo "  ⚠️  API 回應異常（HTTP $HTTP_CODE），跳過此頁" >&2
      rm -f "$RAW_DIR/.tmp_response.json"
      break
    fi

    # 驗證 JSON 格式
    if ! jq empty "$RAW_DIR/.tmp_response.json" 2>/dev/null; then
      echo "  ⚠️  回應內容非有效 JSON，跳過此頁" >&2
      rm -f "$RAW_DIR/.tmp_response.json"
      break
    fi

    # 檢查是否有資料
    LIST_LENGTH=$(jq '.data.list | length' "$RAW_DIR/.tmp_response.json" 2>/dev/null || echo "0")

    if [[ "$LIST_LENGTH" == "0" ]]; then
      echo "  → 無更多資料，結束擷取"
      rm -f "$RAW_DIR/.tmp_response.json"
      break
    fi

    # 注入 metadata 並轉換為 JSONL
    FETCH_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+08:00")

    jq -c --arg role_key "$ROLE_KEY" \
          --arg sector "$SECTOR" \
          --arg ts "$FETCH_TIMESTAMP" \
          '.data.list[] | . + {_meta: {search_role: $role_key, sector: $sector, fetch_timestamp: $ts}}' \
          "$RAW_DIR/.tmp_response.json" >> "$OUTPUT_FILE"

    PAGE_JOBS=$(jq '.data.list | length' "$RAW_DIR/.tmp_response.json")
    ROLE_JOBS=$((ROLE_JOBS + PAGE_JOBS))
    TOTAL_JOBS=$((TOTAL_JOBS + PAGE_JOBS))

    rm -f "$RAW_DIR/.tmp_response.json"

    # 若已達目標數量，提前結束
    if [[ $ROLE_JOBS -ge $RESULTS_PER_ROLE ]]; then
      echo "  → 已達目標數量 ($RESULTS_PER_ROLE 筆)"
      break
    fi

    # 隨機暫停 3-5 秒（避免被封鎖）
    SLEEP_TIME=$((3 + RANDOM % 3))
    echo "  → 暫停 $SLEEP_TIME 秒..."
    sleep "$SLEEP_TIME"
  done

  echo "  ✓ 完成，共 $ROLE_JOBS 筆"
  echo ""

  # 角色間暫停（避免被封鎖）
  if [[ $CURRENT_ROLE -lt $TOTAL_ROLES ]]; then
    SLEEP_TIME=$((3 + RANDOM % 3))
    echo "  → 角色間暫停 $SLEEP_TIME 秒..."
    sleep "$SLEEP_TIME"
  fi
done

# === 完成 ===
echo ""
echo "=========================================="
echo "擷取完成"
echo "=========================================="
echo "總職缺數：$TOTAL_JOBS"
echo "輸出檔案：$OUTPUT_FILE"
echo ""
echo "下一步：執行萃取流程"
echo "  1. 逐行讀取 JSONL"
echo "  2. 交由 Claude 萃取為 Markdown"
echo "  3. 執行 update.sh 寫入 Qdrant"

# 記錄最後擷取時間
echo "$TIMESTAMP" > "$RAW_DIR/.last_fetch"

exit 0
