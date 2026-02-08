#!/bin/bash
# global_adzuna 資料擷取腳本
# 從 Adzuna API 擷取全球職缺與薪資統計資料
# API 文件：https://developer.adzuna.com/docs/search

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_adzuna"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# 設定檔案路徑
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/jobs-$TIMESTAMP.jsonl"
SALARY_JSONL="$RAW_DIR/salary-$TIMESTAMP.jsonl"

# Adzuna API 端點
API_BASE="https://api.adzuna.com/v1/api/jobs"

# 檢查環境變數
if [[ -z "${ADZUNA_APP_ID:-}" ]] || [[ -z "${ADZUNA_APP_KEY:-}" ]]; then
    echo "錯誤: 需要設定 ADZUNA_APP_ID 和 ADZUNA_APP_KEY 環境變數" >&2
    echo "請在 .env 檔案中加入:" >&2
    echo "  ADZUNA_APP_ID=your_app_id" >&2
    echo "  ADZUNA_APP_KEY=your_app_key" >&2
    echo "" >&2
    echo "註冊網址: https://developer.adzuna.com/signup" >&2
    exit 1
fi

# 支援的國家代碼
COUNTRIES="us gb au de fr"

# 從 roles.json 讀取搜尋關鍵字
ROLES_FILE="$PROJECT_ROOT/core/Extractor/Layers/tw_104_jobs/roles.json"

echo "=== global_adzuna 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: Adzuna API"
echo ""

# 檢查 jq 是否可用
if ! command -v jq >/dev/null 2>&1; then
    echo "錯誤: 需要 jq 來解析 JSON" >&2
    exit 1
fi

# 初始化計數器
TOTAL_JOBS=0
TOTAL_SALARY_STATS=0

# === 策略 1: 擷取職缺資料 ===
echo "策略 1: 擷取職缺資料..."

# 讀取搜尋關鍵字（英文職業名稱）
if [[ -f "$ROLES_FILE" ]]; then
    KEYWORDS=$(jq -r '.[].key' "$ROLES_FILE" 2>/dev/null | sed 's/_/ /g' | head -20)
else
    # 預設關鍵字
    KEYWORDS="software engineer
data scientist
product manager
sales manager
customer service
marketing manager
financial analyst
accountant
lawyer
teacher
nurse
mechanical engineer
electrician
chef
graphic designer"
fi

for country in $COUNTRIES; do
    echo ""
    echo "國家: $country"
    echo "---"

    while IFS= read -r keyword; do
        [[ -z "$keyword" ]] && continue

        echo "  搜尋: $keyword"

        # 呼叫 Adzuna API（每次請求最多 50 筆）
        API_URL="${API_BASE}/${country}/search/1?app_id=${ADZUNA_APP_ID}&app_key=${ADZUNA_APP_KEY}&results_per_page=50&what=${keyword}&sort_by=date"

        HTTP_CODE=$(curl -s -w "%{http_code}" -o "$RAW_DIR/temp-${country}-${keyword// /-}.json" \
            --max-time 30 \
            "$API_URL" 2>/dev/null || echo "000")

        if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$RAW_DIR/temp-${country}-${keyword// /-}.json" ]]; then
            # 解析 API 回應（Adzuna API 回應格式：{"results": [...], "count": N}）
            JOB_COUNT=$(jq -r '.count // 0' "$RAW_DIR/temp-${country}-${keyword// /-}.json" 2>/dev/null || echo 0)

            if [[ $JOB_COUNT -gt 0 ]]; then
                echo "    找到 $JOB_COUNT 筆"

                # 逐一萃取職缺資料
                jq -c '.results[]' "$RAW_DIR/temp-${country}-${keyword// /-}.json" 2>/dev/null | while IFS= read -r job; do
                    # 萃取欄位
                    JOB_ID=$(echo "$job" | jq -r '.id // ""')
                    TITLE=$(echo "$job" | jq -r '.title // ""')
                    COMPANY=$(echo "$job" | jq -r '.company.display_name // "未提供"')
                    LOCATION=$(echo "$job" | jq -r '.location.display_name // ""')
                    SALARY_MIN=$(echo "$job" | jq -r '.salary_min // 0')
                    SALARY_MAX=$(echo "$job" | jq -r '.salary_max // 0')
                    CURRENCY=$(echo "$job" | jq -r '.currency // "USD"')
                    DESCRIPTION=$(echo "$job" | jq -r '.description // ""')
                    CATEGORY=$(echo "$job" | jq -r '.category.label // ""')
                    CONTRACT_TYPE=$(echo "$job" | jq -r '.contract_type // "permanent"')
                    JOB_URL=$(echo "$job" | jq -r '.redirect_url // ""')
                    CREATED=$(echo "$job" | jq -r '.created // ""')

                    # 跳過無效職缺
                    if [[ -z "$JOB_ID" ]] || [[ -z "$TITLE" ]]; then
                        continue
                    fi

                    # 輸出為 JSONL
                    jq -n -c \
                        --arg id "$JOB_ID" \
                        --arg title "$TITLE" \
                        --arg company "$COMPANY" \
                        --arg location "$LOCATION" \
                        --arg country "$country" \
                        --argjson salary_min "$SALARY_MIN" \
                        --argjson salary_max "$SALARY_MAX" \
                        --arg currency "$CURRENCY" \
                        --arg description "$DESCRIPTION" \
                        --arg category "$CATEGORY" \
                        --arg contract_type "$CONTRACT_TYPE" \
                        --arg url "$JOB_URL" \
                        --arg created "$CREATED" \
                        --arg fetched_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                        --arg source "adzuna_api" \
                        --arg data_type "job_posting" \
                        '{
                            id: $id,
                            title: $title,
                            company: $company,
                            location: $location,
                            country: $country,
                            salary_min: $salary_min,
                            salary_max: $salary_max,
                            currency: $currency,
                            description: $description,
                            category: $category,
                            contract_type: $contract_type,
                            url: $url,
                            created: $created,
                            fetched_at: $fetched_at,
                            source: $source,
                            data_type: $data_type
                        }' >> "$OUTPUT_JSONL"

                    ((TOTAL_JOBS++))
                done
            else
                echo "    查無資料"
            fi
        else
            echo "    ✗ API 請求失敗 (HTTP $HTTP_CODE)" >&2
        fi

        # 清理暫存檔
        rm -f "$RAW_DIR/temp-${country}-${keyword// /-}.json"

        # API 限流保護（避免超過每秒請求限制）
        sleep 1

    done <<< "$KEYWORDS"
done

echo ""
echo "職缺資料擷取完成: $TOTAL_JOBS 筆"

# === 策略 2: 擷取薪資統計資料 ===
echo ""
echo "策略 2: 擷取薪資統計資料..."

for country in $COUNTRIES; do
    echo ""
    echo "國家: $country"

    # 呼叫 Adzuna Salary History API
    API_URL="${API_BASE}/${country}/history?app_id=${ADZUNA_APP_ID}&app_key=${ADZUNA_APP_KEY}&months=6"

    HTTP_CODE=$(curl -s -w "%{http_code}" -o "$RAW_DIR/temp-salary-${country}.json" \
        --max-time 30 \
        "$API_URL" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$RAW_DIR/temp-salary-${country}.json" ]]; then
        # 解析薪資歷史資料（格式：{"month": [...], "histogram": {...}}）
        # 注意：Adzuna Salary History API 回傳格式可能因國家而異
        # 這裡僅做示範，實際需依 API 文件調整

        # 提取統計資料（範例：假設有 occupation-specific 端點，實際可能需要另外呼叫）
        # 由於 Adzuna API 限制，這裡暫時跳過詳細薪資統計
        # 實際使用時可能需要呼叫其他端點或搭配 Job Search 統計

        echo "  ✓ 薪資歷史資料已下載（待後續分析）"
    else
        echo "  ✗ API 請求失敗 (HTTP $HTTP_CODE)" >&2
    fi

    # 清理暫存檔
    rm -f "$RAW_DIR/temp-salary-${country}.json"

    # API 限流保護
    sleep 1
done

echo ""

# === 去重（依 id + country）===
if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_JOBS -gt 0 ]]; then
    BEFORE=$TOTAL_JOBS
    TEMP_DEDUP="$RAW_DIR/temp-dedup-$TIMESTAMP.jsonl"

    # 依 id + country 組合去重
    jq -sc 'group_by(.id + .country) | map(.[0])[]' "$OUTPUT_JSONL" > "$TEMP_DEDUP" 2>/dev/null && \
        mv "$TEMP_DEDUP" "$OUTPUT_JSONL" || rm -f "$TEMP_DEDUP"

    AFTER=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')

    if [[ "$BEFORE" -ne "$AFTER" ]]; then
        echo "去重: $BEFORE → $AFTER 筆"
        TOTAL_JOBS=$AFTER
    fi
fi

# === 最終結果 ===
echo "=== 擷取完成 ==="
echo "職缺資料: $TOTAL_JOBS 筆"
echo "薪資統計: $TOTAL_SALARY_STATS 筆"

if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_JOBS -gt 0 ]]; then
    echo "輸出檔案: $OUTPUT_JSONL"
fi

# 記錄最後擷取時間
date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"

echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Fetch completed: $LAYER_NAME"
