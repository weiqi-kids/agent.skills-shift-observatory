#!/bin/bash
# global_hn_hiring 資料擷取腳本
# 從 HackerNews "Who is hiring" 月度帖子擷取職缺

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_hn_hiring"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/hn-hiring-$TIMESTAMP.jsonl"

echo "=== global_hn_hiring 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: HackerNews Algolia API"
echo ""

# 搜尋最新的 "Who is hiring" 帖子（精確搜尋，篩選 whoishiring 帳號發布）
echo "搜尋最新的 Who is hiring 帖子..."
SEARCH_RESULT=$(curl -s "https://hn.algolia.com/api/v1/search_by_date?query=%22Who%20is%20hiring%22&tags=ask_hn,author_whoishiring&hitsPerPage=5" 2>/dev/null)

# 從搜尋結果中找到標題包含 "Who is hiring?" 的帖子（排除 "Who is firing?" 等）
THREAD_ID=$(echo "$SEARCH_RESULT" | jq -r '[.hits[] | select(.title | test("Who is hiring\\?"; "i"))] | .[0].objectID' 2>/dev/null)
THREAD_TITLE=$(echo "$SEARCH_RESULT" | jq -r '[.hits[] | select(.title | test("Who is hiring\\?"; "i"))] | .[0].title' 2>/dev/null)

if [[ -z "$THREAD_ID" ]] || [[ "$THREAD_ID" == "null" ]]; then
    echo "✗ 無法找到 Who is hiring 帖子" >&2
    exit 1
fi

echo "找到帖子: $THREAD_TITLE (ID: $THREAD_ID)"
echo ""

# 擷取帖子內容（包含所有留言）
echo "擷取職缺留言..."
HTTP_CODE=$(curl -s -w "%{http_code}" -o "$RAW_DIR/temp-$TIMESTAMP.json" \
    --max-time 120 \
    "https://hn.algolia.com/api/v1/items/$THREAD_ID" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$RAW_DIR/temp-$TIMESTAMP.json" ]]; then
    echo "✓ API 回應成功，正在轉換為 JSONL..."

    # 提取所有第一層留言（職缺貼文）
    jq -c '.children[] | {
        id: .id,
        author: .author,
        created_at: .created_at,
        text: .text,
        thread_id: "'"$THREAD_ID"'",
        thread_title: "'"$THREAD_TITLE"'",
        fetched_at: "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
    }' "$RAW_DIR/temp-$TIMESTAMP.json" > "$OUTPUT_JSONL" 2>/dev/null

    TOTAL_COUNT=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')
    echo "找到 $TOTAL_COUNT 筆職缺留言"

    rm -f "$RAW_DIR/temp-$TIMESTAMP.json"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"

    echo ""
    echo "=== 擷取完成 ==="
    echo "總筆數: $TOTAL_COUNT"
    echo "輸出檔案: $OUTPUT_JSONL"
else
    echo "✗ API 請求失敗 (HTTP $HTTP_CODE)" >&2
    rm -f "$RAW_DIR/temp-$TIMESTAMP.json"
    exit 1
fi

echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Fetch completed: $LAYER_NAME"
