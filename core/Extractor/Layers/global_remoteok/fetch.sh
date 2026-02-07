#!/bin/bash
# global_remoteok 資料擷取腳本
# 從 RemoteOK API 擷取全球遠端職缺

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_remoteok"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/remoteok-$TIMESTAMP.jsonl"

API_URL="https://remoteok.com/api"

echo "=== global_remoteok 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: RemoteOK API"
echo ""

# 擷取 API 資料
HTTP_CODE=$(curl -s -w "%{http_code}" -o "$RAW_DIR/temp-$TIMESTAMP.json" \
    --max-time 60 \
    -H "User-Agent: Mozilla/5.0 (compatible; SkillsShiftObservatory/1.0)" \
    "$API_URL" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$RAW_DIR/temp-$TIMESTAMP.json" ]]; then
    echo "✓ API 回應成功,正在轉換為 JSONL..."

    # 跳過第一筆(API 條款說明),轉換為 JSONL
    jq -c '.[] | select(.id != null)' "$RAW_DIR/temp-$TIMESTAMP.json" > "$OUTPUT_JSONL" 2>/dev/null

    TOTAL_COUNT=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')
    echo "找到 $TOTAL_COUNT 筆職缺"

    # 清理暫存檔
    rm -f "$RAW_DIR/temp-$TIMESTAMP.json"

    # 記錄最後擷取時間
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
