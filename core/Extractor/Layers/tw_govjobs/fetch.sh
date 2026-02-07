#!/bin/bash
# tw_govjobs 資料擷取腳本
# 從台灣就業通 Open API 擷取職缺資料
# API 文件：https://free.taiwanjobs.gov.tw/webservice_taipei/A17000000J-030144-Taiwanjobs-OpenData.pdf

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="tw_govjobs"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# 設定檔案路徑
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/jobs-$TIMESTAMP.jsonl"
TEMP_XML="$RAW_DIR/temp-$TIMESTAMP.xml"

# 台灣就業通 Open API
API_URL="https://free.taiwanjobs.gov.tw/webservice_taipei/Webservice.ashx"

# 從 roles.json 讀取搜尋關鍵字
ROLES_FILE="$PROJECT_ROOT/core/Extractor/Layers/tw_104_jobs/roles.json"

echo "=== tw_govjobs 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: 台灣就業通 Open API"
echo ""

# 檢查 jq 是否可用
if ! command -v jq >/dev/null 2>&1; then
    echo "錯誤: 需要 jq 來解析 JSON" >&2
    exit 1
fi

# 初始化計數器
TOTAL_COUNT=0

# === 策略 1: 直接抓取全部職缺（最多 1000 筆）===
echo "策略 1: 抓取全部職缺..."

HTTP_CODE=$(curl -s -w "%{http_code}" -o "$TEMP_XML" \
    --max-time 60 \
    "$API_URL?count=1000" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_XML" ]]; then
    echo "  ✓ API 回應成功，正在轉換為 JSONL..."

    # 使用 xmllint + jq 或純 shell 解析 XML
    # 台灣就業通 API 回傳格式：
    # <DataList>
    #   <Data>
    #     <OCCU_DESC>職缺名稱</OCCU_DESC>
    #     <COMPNAME>公司名稱</COMPNAME>（注意：此欄位可能不在 API 中）
    #     ...
    #   </Data>
    # </DataList>

    if command -v xmllint >/dev/null 2>&1; then
        # 使用 xmllint 計算職缺數量
        JOB_COUNT=$(xmllint --xpath "count(//Data)" "$TEMP_XML" 2>/dev/null || echo 0)
        echo "  找到 $JOB_COUNT 筆職缺"

        # 逐一萃取每筆職缺
        for ((i=1; i<=JOB_COUNT; i++)); do
            # 萃取各欄位（使用 xmllint xpath）
            OCCU_DESC=$(xmllint --xpath "string(//Data[$i]/OCCU_DESC)" "$TEMP_XML" 2>/dev/null || echo "")
            COMPNAME=$(xmllint --xpath "string(//Data[$i]/COMPNAME)" "$TEMP_XML" 2>/dev/null || echo "")
            # 若無 COMPNAME，嘗試從 OCCU_DESC 或其他欄位取得（台灣就業通 API 可能不提供公司名）
            if [[ -z "$COMPNAME" ]]; then
                COMPNAME="未提供"
            fi
            NT_L=$(xmllint --xpath "string(//Data[$i]/NT_L)" "$TEMP_XML" 2>/dev/null || echo "0")
            NT_U=$(xmllint --xpath "string(//Data[$i]/NT_U)" "$TEMP_XML" 2>/dev/null || echo "0")
            CITYNAME=$(xmllint --xpath "string(//Data[$i]/CITYNAME)" "$TEMP_XML" 2>/dev/null || echo "")
            JOB_DETAIL=$(xmllint --xpath "string(//Data[$i]/JOB_DETAIL)" "$TEMP_XML" 2>/dev/null || echo "")
            CJOB_NAME1=$(xmllint --xpath "string(//Data[$i]/CJOB_NAME1)" "$TEMP_XML" 2>/dev/null || echo "")
            CJOB_NAME2=$(xmllint --xpath "string(//Data[$i]/CJOB_NAME2)" "$TEMP_XML" 2>/dev/null || echo "")
            WK_TYPE=$(xmllint --xpath "string(//Data[$i]/WK_TYPE)" "$TEMP_XML" 2>/dev/null || echo "")
            JOB_PERSON=$(xmllint --xpath "string(//Data[$i]/JOB_PERSON)" "$TEMP_XML" 2>/dev/null || echo "")
            STOP_DATE=$(xmllint --xpath "string(//Data[$i]/STOP_DATE)" "$TEMP_XML" 2>/dev/null || echo "")
            # 舊欄位（可能存在於不同版本的 API）
            EXPERIENCE=$(xmllint --xpath "string(//Data[$i]/EXPERIENCE)" "$TEMP_XML" 2>/dev/null || echo "")
            EDGRDESC=$(xmllint --xpath "string(//Data[$i]/EDGRDESC)" "$TEMP_XML" 2>/dev/null || echo "")
            HILOSAL=$(xmllint --xpath "string(//Data[$i]/HILOSAL)" "$TEMP_XML" 2>/dev/null || echo "")
            # URL_QUERY 包含完整的職缺連結（比 JOB_NO 更可靠）
            URL_QUERY=$(xmllint --xpath "string(//Data[$i]/URL_QUERY)" "$TEMP_XML" 2>/dev/null || echo "")
            TRANDATE=$(xmllint --xpath "string(//Data[$i]/TRANDATE)" "$TEMP_XML" 2>/dev/null || echo "")

            # 跳過無效職缺（無職缺名稱或公司名稱）
            if [[ -z "$OCCU_DESC" ]] || [[ -z "$COMPNAME" ]]; then
                continue
            fi

            # 使用 URL_QUERY 作為職缺連結（API 直接提供）
            JOB_URL="$URL_QUERY"

            # 輸出為 JSONL（處理薪資欄位可能是 "-" 或空值的情況）
            jq -n -c \
                --arg title "$OCCU_DESC" \
                --arg company "$COMPNAME" \
                --arg salary_low "$NT_L" \
                --arg salary_high "$NT_U" \
                --arg salary_desc "$HILOSAL" \
                --arg city "$CITYNAME" \
                --arg description "$JOB_DETAIL" \
                --arg category1 "$CJOB_NAME1" \
                --arg category2 "$CJOB_NAME2" \
                --arg experience "$EXPERIENCE" \
                --arg education "$EDGRDESC" \
                --arg link "$JOB_URL" \
                --arg trandate "$TRANDATE" \
                --arg fetched_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                --arg source "taiwanjobs_api" \
                '{
                    title: $title,
                    company: $company,
                    salary_low: (if $salary_low == "-" or $salary_low == "" then 0 else ($salary_low | tonumber // 0) end),
                    salary_high: (if $salary_high == "-" or $salary_high == "" then 0 else ($salary_high | tonumber // 0) end),
                    salary_desc: $salary_desc,
                    city: $city,
                    description: $description,
                    job_category1: $category1,
                    job_category2: $category2,
                    experience: $experience,
                    education: $education,
                    link: $link,
                    trandate: $trandate,
                    fetched_at: $fetched_at,
                    source: $source
                }' >> "$OUTPUT_JSONL"

            ((TOTAL_COUNT++))

            # 進度顯示（每 100 筆顯示一次）
            if ((TOTAL_COUNT % 100 == 0)); then
                echo "  已處理 $TOTAL_COUNT 筆..."
            fi
        done
    else
        # 無 xmllint 時的降級處理：使用 grep/sed 簡易解析
        echo "  警告: xmllint 不可用，使用簡易解析..." >&2

        # 萃取所有 <Data>...</Data> 區塊
        # 注意：CDATA 區塊需要特殊處理
        grep -oE '<Data>.*?</Data>' "$TEMP_XML" 2>/dev/null | while IFS= read -r job_block; do
            # 萃取 CDATA 內容
            OCCU_DESC=$(echo "$job_block" | grep -oP '(?<=<OCCU_DESC><!\[CDATA\[).*?(?=\]\]></OCCU_DESC>)' || echo "")
            COMPNAME=$(echo "$job_block" | grep -oP '(?<=<COMPNAME><!\[CDATA\[).*?(?=\]\]></COMPNAME>)' || echo "未提供")
            CJOB_NAME1=$(echo "$job_block" | grep -oP '(?<=<CJOB_NAME1><!\[CDATA\[).*?(?=\]\]></CJOB_NAME1>)' || echo "")
            CJOB_NAME2=$(echo "$job_block" | grep -oP '(?<=<CJOB_NAME2><!\[CDATA\[).*?(?=\]\]></CJOB_NAME2>)' || echo "")
            JOB_DETAIL=$(echo "$job_block" | grep -oP '(?<=<JOB_DETAIL><!\[CDATA\[).*?(?=\]\]></JOB_DETAIL>)' || echo "")

            if [[ -n "$OCCU_DESC" ]]; then
                jq -n -c \
                    --arg title "$OCCU_DESC" \
                    --arg company "$COMPNAME" \
                    --arg category1 "$CJOB_NAME1" \
                    --arg category2 "$CJOB_NAME2" \
                    --arg description "$JOB_DETAIL" \
                    --arg fetched_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                    --arg source "taiwanjobs_api" \
                    '{title: $title, company: $company, job_category1: $category1, job_category2: $category2, description: $description, fetched_at: $fetched_at, source: $source}' >> "$OUTPUT_JSONL"
            fi
        done

        TOTAL_COUNT=$(wc -l < "$OUTPUT_JSONL" 2>/dev/null | tr -d ' ')
    fi
else
    echo "  ✗ API 請求失敗 (HTTP $HTTP_CODE)" >&2
fi

# 清理暫存檔
rm -f "$TEMP_XML"

echo ""

# === 策略 2: 依搜尋角色補充擷取（若策略 1 不足）===
if [[ $TOTAL_COUNT -lt 100 ]] && [[ -f "$ROLES_FILE" ]]; then
    echo "策略 2: 依搜尋角色補充擷取..."

    # 讀取 roles.json 中的搜尋關鍵字（正確的 jq 路徑）
    KEYWORDS=$(jq -r '.[].search_term' "$ROLES_FILE" 2>/dev/null | head -20)

    while IFS= read -r keyword; do
        [[ -z "$keyword" ]] && continue

        echo "  搜尋: $keyword"

        # 嘗試帶關鍵字搜尋（API 可能不支援，保留備用）
        # 台灣就業通 API 支援 jobno（通俗職業代碼）參數
        sleep 1
    done <<< "$KEYWORDS"
fi

echo ""

# === 去重（優先用 link，否則用 title+company+city）===
if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_COUNT -gt 0 ]]; then
    BEFORE=$TOTAL_COUNT
    TEMP_DEDUP="$RAW_DIR/temp-dedup-$TIMESTAMP.jsonl"

    # 依 link 或 title+company+city 組合去重
    # 使用 -c 確保輸出為 compact JSONL 格式
    jq -sc 'group_by(if .link != "" then .link else (.title + .company + .city) end) | map(.[0])[]' "$OUTPUT_JSONL" > "$TEMP_DEDUP" 2>/dev/null && \
        mv "$TEMP_DEDUP" "$OUTPUT_JSONL" || rm -f "$TEMP_DEDUP"

    AFTER=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')

    if [[ "$BEFORE" -ne "$AFTER" ]]; then
        echo "去重: $BEFORE → $AFTER 筆"
        TOTAL_COUNT=$AFTER
    fi
fi

# === 最終結果 ===
echo "=== 擷取完成 ==="
if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_COUNT -gt 0 ]]; then
    echo "總筆數: $TOTAL_COUNT"
    echo "輸出檔案: $OUTPUT_JSONL"

    # 記錄最後擷取時間
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"
else
    echo "⚠️  未擷取到任何職缺資料" >&2
    echo "可能原因:" >&2
    echo "  1. 台灣就業通 API 暫時無法存取" >&2
    echo "  2. 網路連線問題" >&2
    echo "建議: 稍後重試或檢查 $API_URL 是否可達" >&2

    # 仍建立空檔案並記錄時間
    touch "$OUTPUT_JSONL"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"
    exit 1
fi

echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Fetch completed: $LAYER_NAME"
