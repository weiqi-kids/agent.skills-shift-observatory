#!/bin/bash
# global_arbeitnow 資料擷取腳本
# 從 Arbeitnow API 擷取歐洲職缺

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_arbeitnow"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/arbeitnow-$TIMESTAMP.jsonl"

API_URL="https://www.arbeitnow.com/api/job-board-api"

echo "=== global_arbeitnow 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: Arbeitnow API"
echo ""

TOTAL_COUNT=0
PAGE=1
MAX_PAGES=5  # 最多抓取 5 頁（500 筆）

while [[ $PAGE -le $MAX_PAGES ]]; do
    echo "擷取第 $PAGE 頁..."

    HTTP_CODE=$(curl -s -w "%{http_code}" -o "$RAW_DIR/temp-page-$PAGE.json" \
        --max-time 60 \
        "$API_URL?page=$PAGE" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$RAW_DIR/temp-page-$PAGE.json" ]]; then
        # 提取 data 陣列並轉換為 JSONL
        PAGE_COUNT=$(jq '.data | length' "$RAW_DIR/temp-page-$PAGE.json" 2>/dev/null || echo 0)

        if [[ "$PAGE_COUNT" -eq 0 ]]; then
            echo "  第 $PAGE 頁無資料，停止擷取"
            rm -f "$RAW_DIR/temp-page-$PAGE.json"
            break
        fi

        jq -c '.data[]' "$RAW_DIR/temp-page-$PAGE.json" >> "$OUTPUT_JSONL" 2>/dev/null
        TOTAL_COUNT=$((TOTAL_COUNT + PAGE_COUNT))
        echo "  ✓ 取得 $PAGE_COUNT 筆（累計 $TOTAL_COUNT 筆）"

        rm -f "$RAW_DIR/temp-page-$PAGE.json"
    else
        echo "  ✗ 第 $PAGE 頁請求失敗 (HTTP $HTTP_CODE)" >&2
        rm -f "$RAW_DIR/temp-page-$PAGE.json"
        break
    fi

    PAGE=$((PAGE + 1))
    sleep 1  # 避免請求過快
done

if [[ $TOTAL_COUNT -gt 0 ]]; then
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"

    echo ""
    echo "=== 擷取完成 ==="
    echo "總筆數: $TOTAL_COUNT"
    echo "輸出檔案: $OUTPUT_JSONL"
else
    echo "⚠️ 未擷取到任何職缺資料" >&2
    exit 1
fi

echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Fetch completed: $LAYER_NAME"
