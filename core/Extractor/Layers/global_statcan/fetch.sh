#!/bin/bash
# global_statcan 資料擷取腳本
# 從 Statistics Canada Web Data Service 擷取勞動力統計資料
# API 文件：https://www.statcan.gc.ca/en/developers/wds/user-guide

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_statcan"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# 設定檔案路徑
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/statcan-$TIMESTAMP.jsonl"

# Statistics Canada Web Data Service API
BASE_URL="https://www150.statcan.gc.ca/t1/wds/rest"

echo "=== global_statcan 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: Statistics Canada Web Data Service"
echo ""
echo "注意: Statistics Canada API 端點格式可能已變更"
echo "若遇到 HTTP 404 錯誤，請參考以下方式："
echo "  1. 手動下載 CSV: https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410028701"
echo "  2. 或使用 OECD/ILO 的加拿大資料作為替代"
echo ""

# 檢查 jq 是否可用
if ! command -v jq >/dev/null 2>&1; then
    echo "錯誤: 需要 jq 來解析 JSON" >&2
    exit 1
fi

# 初始化計數器
TOTAL_COUNT=0

# === 資料表定義 ===
# 格式: product_id|coordinate|periods|description
TABLES=(
    "1410028701|1.1.1.1.1.1.1|12|Labour force - Canada - Both sexes - 15+ - Estimate"
    "1410028701|1.2.1.1.1.1.1|12|Employment - Canada - Both sexes - 15+ - Estimate"
    "1410028701|1.3.1.1.1.1.1|12|Unemployment - Canada - Both sexes - 15+ - Estimate"
    "1410028701|1.4.1.1.1.1.1|12|Unemployment rate - Canada - Both sexes - 15+ - Estimate"
    "1410028701|1.5.1.1.1.1.1|12|Participation rate - Canada - Both sexes - 15+ - Estimate"
    "1410028701|1.6.1.1.1.1.1|12|Employment rate - Canada - Both sexes - 15+ - Estimate"
)

# === 擷取資料 ===
for table_def in "${TABLES[@]}"; do
    IFS='|' read -r product_id coordinate periods description <<< "$table_def"

    echo "擷取: $description"

    # 構建 API URL
    API_URL="$BASE_URL/getDataFromCubePidCoordAndLatestNPeriods/$product_id/$coordinate/$periods"

    # 發送請求
    HTTP_CODE=$(curl -s -w "%{http_code}" -o "$RAW_DIR/temp-$product_id-$coordinate.json" \
        --max-time 30 \
        "$API_URL" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$RAW_DIR/temp-$product_id-$coordinate.json" ]]; then
        echo "  ✓ API 回應成功，正在轉換為 JSONL..."

        # 解析 JSON 並轉換為 JSONL
        # Statistics Canada API 回傳格式：
        # [
        #   {
        #     "object": "https://www150.statcan.gc.ca/t1/wds/rest/...",
        #     "vectorDataPoint": {
        #       "productId": "14-10-0287-01",
        #       "coordinate": "1.1.1.1.1.1.1",
        #       "value": 20500.5,
        #       "referencePeridod": "2026-01",
        #       "releaseTime": "2026-02-07T08:30:00Z",
        #       ...
        #     }
        #   }
        # ]

        # 萃取每筆資料點
        jq -c '.[] | select(.vectorDataPoint != null) | {
            product_id: (.vectorDataPoint.productId // ""),
            coordinate: (.vectorDataPoint.coordinate // ""),
            value: (.vectorDataPoint.value // null),
            uom: (.vectorDataPoint.uom // ""),
            scalar: (.vectorDataPoint.scalar // ""),
            reference_period: (.vectorDataPoint.referencePeridod // ""),
            release_time: (.vectorDataPoint.releaseTime // ""),
            status: (.vectorDataPoint.status // ""),
            symbol: (.vectorDataPoint.symbol // ""),
            fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
            source: "statcan_api"
        }' "$RAW_DIR/temp-$product_id-$coordinate.json" >> "$OUTPUT_JSONL" 2>/dev/null || {
            echo "  ✗ JSON 解析失敗" >&2
            continue
        }

        # 計算新增的資料點數
        NEW_COUNT=$(jq -s 'length' "$RAW_DIR/temp-$product_id-$coordinate.json" 2>/dev/null || echo 0)
        TOTAL_COUNT=$((TOTAL_COUNT + NEW_COUNT))
        echo "  新增 $NEW_COUNT 筆資料點"

    else
        echo "  ✗ API 請求失敗 (HTTP $HTTP_CODE)" >&2
        echo "  URL: $API_URL" >&2
    fi

    # 清理暫存檔
    rm -f "$RAW_DIR/temp-$product_id-$coordinate.json"

    # API 請求間隔（避免過快）
    sleep 1
done

echo ""

# === 擷取產品元資料（用於產生完整標題）===
echo "擷取資料表元資料..."

for product_id in "1410028701"; do
    # 將 product_id 轉換回帶連字號格式（用於元資料查詢）
    FORMATTED_ID="${product_id:0:2}-${product_id:2:2}-${product_id:4:4}-${product_id:8:2}"

    META_URL="$BASE_URL/getCubeMetadata/[$product_id]"

    HTTP_CODE=$(curl -s -w "%{http_code}" -o "$RAW_DIR/meta-$product_id.json" \
        --max-time 30 \
        "$META_URL" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$RAW_DIR/meta-$product_id.json" ]]; then
        echo "  ✓ 元資料取得成功: $FORMATTED_ID"
    else
        echo "  ⚠️  元資料取得失敗: $FORMATTED_ID (HTTP $HTTP_CODE)" >&2
    fi
done

echo ""

# === 去重（優先用 product_id + coordinate + reference_period）===
if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_COUNT -gt 0 ]]; then
    BEFORE=$TOTAL_COUNT
    TEMP_DEDUP="$RAW_DIR/temp-dedup-$TIMESTAMP.jsonl"

    # 依 product_id + coordinate + reference_period 組合去重
    jq -sc 'group_by(.product_id + .coordinate + .reference_period) | map(.[0])[]' "$OUTPUT_JSONL" > "$TEMP_DEDUP" 2>/dev/null && \
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
    echo "⚠️  未擷取到任何統計資料" >&2
    echo "可能原因:" >&2
    echo "  1. Statistics Canada API 暫時無法存取" >&2
    echo "  2. 網路連線問題" >&2
    echo "  3. API 資料結構變動" >&2
    echo "建議: 稍後重試或檢查 $BASE_URL 是否可達" >&2

    # 仍建立空檔案並記錄時間
    touch "$OUTPUT_JSONL"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"
    exit 1
fi

echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Fetch completed: $LAYER_NAME"
