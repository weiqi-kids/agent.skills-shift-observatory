#!/bin/bash
# global_bls 資料擷取腳本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_bls"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$RAW_DIR/bls-${TIMESTAMP}.jsonl"

# BLS API endpoint
BLS_API="https://api.bls.gov/publicAPI/v2/timeseries/data/"

# 關鍵 series IDs
# CES0000000001 - Total nonfarm employment
# LNS14000000 - Unemployment rate (U-3)
# LNS13327709 - U-6 Underemployment
# CES0500000003 - Average hourly earnings
# JTS000000000000000JOL - JOLTS total job openings
# CUSR0000SA0 - CPI-U All Items

SERIES='["CES0000000001","LNS14000000","LNS13327709","CES0500000003","JTS000000000000000JOL","CUSR0000SA0"]'

# 抓取最近 2 年資料
CURRENT_YEAR=$(date +%Y)
START_YEAR=$((CURRENT_YEAR - 2))

echo "Fetching BLS data for series: $SERIES"
echo "Period: $START_YEAR - $CURRENT_YEAR"

# 構建 API payload
PAYLOAD=$(jq -n \
  --argjson series "$SERIES" \
  --arg start "$START_YEAR" \
  --arg end "$CURRENT_YEAR" \
  '{seriesid: $series, startyear: $start, endyear: $end}')

# 呼叫 API
RESPONSE=$(curl -s -X POST "$BLS_API" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# 檢查回應狀態
STATUS=$(echo "$RESPONSE" | jq -r '.status // "ERROR"')

if [[ "$STATUS" != "REQUEST_SUCCEEDED" ]]; then
  echo "API request failed: $STATUS" >&2
  echo "$RESPONSE" | jq '.' >&2
  exit 1
fi

# 轉換為 JSONL：每個 series 的每個 data point 一行
echo "$RESPONSE" | jq -c '
  .Results.series[] as $series |
  $series.data[] |
  {
    series_id: $series.seriesID,
    year: .year,
    period: .period,
    period_name: .periodName,
    value: .value,
    footnotes: .footnotes,
    fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
  }
' >> "$OUTPUT_FILE"

echo "Fetch completed: $LAYER_NAME"
echo "Output: $OUTPUT_FILE"
echo "Lines: $(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo 0)"
