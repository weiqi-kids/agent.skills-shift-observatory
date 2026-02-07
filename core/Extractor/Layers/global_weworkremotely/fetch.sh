#!/bin/bash
# global_weworkremotely 資料擷取腳本
# 從 WeWorkRemotely RSS 擷取全球遠端職缺

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_weworkremotely"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/weworkremotely-$TIMESTAMP.jsonl"
TEMP_XML="$RAW_DIR/temp-$TIMESTAMP.xml"

RSS_URL="https://weworkremotely.com/remote-jobs.rss"

echo "=== global_weworkremotely 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: WeWorkRemotely RSS"
echo ""

# 下載 RSS
HTTP_CODE=$(curl -s -w "%{http_code}" -o "$TEMP_XML" \
    --max-time 60 \
    "$RSS_URL" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_XML" ]]; then
    echo "✓ RSS 下載成功，正在轉換為 JSONL..."

    # 檢查 xmllint 是否可用
    if ! command -v xmllint >/dev/null 2>&1; then
        echo "錯誤: 需要 xmllint 來解析 XML" >&2
        rm -f "$TEMP_XML"
        exit 1
    fi

    # 計算職缺數量
    JOB_COUNT=$(xmllint --xpath "count(//item)" "$TEMP_XML" 2>/dev/null || echo 0)
    echo "找到 $JOB_COUNT 筆職缺"

    # 逐一萃取每筆職缺
    for ((i=1; i<=JOB_COUNT; i++)); do
        TITLE=$(xmllint --xpath "string(//item[$i]/title)" "$TEMP_XML" 2>/dev/null || echo "")
        LINK=$(xmllint --xpath "string(//item[$i]/link)" "$TEMP_XML" 2>/dev/null || echo "")
        PUBDATE=$(xmllint --xpath "string(//item[$i]/pubDate)" "$TEMP_XML" 2>/dev/null || echo "")
        REGION=$(xmllint --xpath "string(//item[$i]/region)" "$TEMP_XML" 2>/dev/null || echo "")
        COUNTRY=$(xmllint --xpath "string(//item[$i]/country)" "$TEMP_XML" 2>/dev/null || echo "")
        SKILLS=$(xmllint --xpath "string(//item[$i]/skills)" "$TEMP_XML" 2>/dev/null || echo "")
        CATEGORY=$(xmllint --xpath "string(//item[$i]/category)" "$TEMP_XML" 2>/dev/null || echo "")
        TYPE=$(xmllint --xpath "string(//item[$i]/type)" "$TEMP_XML" 2>/dev/null || echo "")
        # 注意：description 可能包含 HTML，需要特殊處理
        DESCRIPTION=$(xmllint --xpath "string(//item[$i]/description)" "$TEMP_XML" 2>/dev/null || echo "")

        # 跳過無效職缺
        if [[ -z "$TITLE" ]]; then
            continue
        fi

        # 輸出為 JSONL
        jq -n -c \
            --arg title "$TITLE" \
            --arg link "$LINK" \
            --arg pubDate "$PUBDATE" \
            --arg region "$REGION" \
            --arg country "$COUNTRY" \
            --arg skills "$SKILLS" \
            --arg category "$CATEGORY" \
            --arg type "$TYPE" \
            --arg description "$DESCRIPTION" \
            --arg fetched_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            --arg source "weworkremotely_rss" \
            '{
                title: $title,
                link: $link,
                pubDate: $pubDate,
                region: $region,
                country: $country,
                skills: $skills,
                category: $category,
                type: $type,
                description: $description,
                fetched_at: $fetched_at,
                source: $source
            }' >> "$OUTPUT_JSONL"

        # 進度顯示
        if ((i % 20 == 0)); then
            echo "  已處理 $i 筆..."
        fi
    done

    TOTAL_COUNT=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')
    rm -f "$TEMP_XML"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"

    echo ""
    echo "=== 擷取完成 ==="
    echo "總筆數: $TOTAL_COUNT"
    echo "輸出檔案: $OUTPUT_JSONL"
else
    echo "✗ RSS 請求失敗 (HTTP $HTTP_CODE)" >&2
    rm -f "$TEMP_XML"
    exit 1
fi

echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Fetch completed: $LAYER_NAME"
