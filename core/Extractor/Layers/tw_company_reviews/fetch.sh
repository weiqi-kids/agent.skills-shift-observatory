#!/bin/bash
# tw_company_reviews 資料擷取腳本
# 從求職天眼通網站擷取公司評論資料

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="tw_company_reviews"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# 設定檔案路徑
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/reviews-$TIMESTAMP.jsonl"
TEMP_HTML="$RAW_DIR/temp-$TIMESTAMP.html"

# 求職天眼通網站
BASE_URL="https://www.qollie.com"

# 目標公司清單 (可從 tw_104_jobs 或 tw_govjobs 的公司名稱擷取)
# 這裡先使用台灣前 100 大企業作為種子清單
COMPANIES=(
    "台積電"
    "鴻海"
    "聯發科"
    "廣達"
    "和碩"
    "緯創"
    "仁寶"
    "英業達"
    "華碩"
    "宏碁"
    "台達電"
    "光寶科"
    "研華"
    "聯電"
    "日月光"
    "南亞科"
    "群創"
    "友達"
    "中華電信"
    "遠傳電信"
    # ... 可擴充更多公司
)

echo "=== tw_company_reviews 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "目標公司數: ${#COMPANIES[@]}"

# 初始化計數器
TOTAL_COUNT=0
FAILED_COUNT=0

# User-Agent 輪替 (避免被偵測)
USER_AGENTS=(
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

# 對每個公司進行搜尋
for company in "${COMPANIES[@]}"; do
    echo ""
    echo "正在搜尋: $company"

    # 隨機選擇 User-Agent
    UA="${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}"

    # 嘗試抓取該公司的評論列表頁
    # 求職天眼通的 URL 結構可能是: /company/{company_slug}/reviews
    # 需先將中文公司名轉為 URL slug (這裡簡化為直接搜尋)

    SEARCH_URL="$BASE_URL/search?q=$(printf %s "$company" | jq -sRr @uri)"

    HTTP_CODE=$(curl -s -w "%{http_code}" -o "$TEMP_HTML" \
        -A "$UA" \
        -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
        -H "Accept-Language: zh-TW,zh;q=0.9,en;q=0.8" \
        -H "Referer: $BASE_URL/" \
        --max-time 30 \
        --retry 2 \
        --retry-delay 3 \
        "$SEARCH_URL" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" != "200" ]]; then
        echo "  ⚠️  HTTP $HTTP_CODE (跳過)" >&2
        FAILED_COUNT=$((FAILED_COUNT + 1))

        # 若連續失敗超過 5 次, 可能被封鎖, 建議延長間隔
        if [[ $FAILED_COUNT -ge 5 ]]; then
            echo "  ⚠️  連續失敗 $FAILED_COUNT 次, 延長等待時間..." >&2
            sleep 30
            FAILED_COUNT=0
        fi
        continue
    fi

    # 檢查是否遇到驗證碼或登入頁面
    if grep -qi "captcha\|cloudflare\|請登入\|驗證" "$TEMP_HTML" 2>/dev/null; then
        echo "  ⚠️  偵測到反爬機制 (驗證碼或登入要求), 跳過" >&2
        FAILED_COUNT=$((FAILED_COUNT + 1))
        sleep 10
        continue
    fi

    # 解析 HTML 並萃取評論清單
    # 假設評論列表在 <div class="review-item"> 中 (需依實際 HTML 結構調整)

    if command -v pup >/dev/null 2>&1; then
        # 使用 pup 解析 (需安裝: brew install pup)
        pup 'div.review-item json{}' < "$TEMP_HTML" 2>/dev/null | \
        jq -c --arg company "$company" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.[] | {
            company_name: $company,
            title: (.text | split("\n")[0] | gsub("^\\s+|\\s+$";"") // ""),
            rating: (.text | match("([0-9.]+)\\s*[星分]") | .captures[0].string | tonumber // null),
            link: (if .href then (if (.href | startswith("http")) then .href else ("'$BASE_URL'" + .href) end) else "" end),
            published_date: (.text | match("20[0-9]{2}-[0-9]{2}-[0-9]{2}") | .string // ""),
            fetched_at: $ts
        } | select(.title != "")' >> "$OUTPUT_JSONL" 2>/dev/null || true
    else
        # 降級: 使用 grep + sed 簡易萃取
        grep -oP '<div class="review-item"[^>]*>.*?</div>' "$TEMP_HTML" 2>/dev/null | \
        head -20 | \
        while IFS= read -r line; do
            # 萃取標題
            TITLE=$(echo "$line" | grep -oP '<h3[^>]*>\K[^<]+' 2>/dev/null || echo "")
            # 萃取連結
            LINK=$(echo "$line" | grep -oP 'href="([^"]+)"' 2>/dev/null | head -1 | sed 's/href="//;s/"//' || echo "")
            [[ "$LINK" =~ ^http ]] || LINK="$BASE_URL$LINK"

            if [[ -n "$TITLE" ]]; then
                echo "{\"company_name\":\"$company\",\"title\":\"$TITLE\",\"link\":\"$LINK\",\"fetched_at\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >> "$OUTPUT_JSONL"
            fi
        done || true
    fi

    # 計數本次搜尋結果
    COUNT=$(grep -c "\"company_name\":\"$company\"" "$OUTPUT_JSONL" 2>/dev/null || echo 0)
    TOTAL_COUNT=$((TOTAL_COUNT + COUNT))
    echo "  → 找到 $COUNT 筆評論"

    # 延遲避免被封鎖 (3-5 秒隨機)
    DELAY=$((3 + RANDOM % 3))
    sleep $DELAY

    # 清理暫存檔
    rm -f "$TEMP_HTML"
done

# 去重 (依 link 去重)
if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_COUNT -gt 0 ]]; then
    TEMP_DEDUP="$RAW_DIR/temp-dedup-$TIMESTAMP.jsonl"

    if command -v jq >/dev/null 2>&1; then
        jq -s 'unique_by(.link) | .[]' "$OUTPUT_JSONL" > "$TEMP_DEDUP"
        mv "$TEMP_DEDUP" "$OUTPUT_JSONL"
    else
        sort -u "$OUTPUT_JSONL" > "$TEMP_DEDUP"
        mv "$TEMP_DEDUP" "$OUTPUT_JSONL"
    fi

    FINAL_COUNT=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')
    echo ""
    echo "=== 擷取完成 ==="
    echo "原始筆數: $TOTAL_COUNT"
    echo "去重後筆數: $FINAL_COUNT"
    echo "輸出檔案: $OUTPUT_JSONL"

    # 記錄最後擷取時間
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"
else
    echo ""
    echo "⚠️  未擷取到任何評論資料" >&2
    echo "可能原因:" >&2
    echo "  1. 網站結構已變動 (需更新 HTML 解析邏輯)" >&2
    echo "  2. 網站反爬機制生效 (驗證碼、登入要求、IP 封鎖)" >&2
    echo "  3. 目標公司在平台上無評論" >&2
    echo "  4. 網站暫時無法存取" >&2
    exit 1
fi

echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "⚠️  注意事項:"
echo "  - 若頻繁出現 HTTP 403/429, 表示觸發反爬機制, 建議增加延遲或使用代理"
echo "  - 求職天眼通可能需要登入才能查看完整評論, 此腳本僅擷取公開資訊"
echo "  - 建議定期更新 User-Agent 與 Headers 以降低被偵測風險"
