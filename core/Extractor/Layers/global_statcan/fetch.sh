#!/bin/bash
# global_statcan data fetcher
# Fetches labour force statistics from Statistics Canada Web Data Service
# Uses vector IDs for efficient API calls

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_statcan"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d)
OUTPUT_JSONL="$RAW_DIR/statcan-$TIMESTAMP.jsonl"

BASE_URL="https://www150.statcan.gc.ca/t1/wds/rest"

echo "=== global_statcan fetch ==="
echo "Start: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Source: Statistics Canada Web Data Service"
echo ""

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq required" >&2
    exit 1
fi

TOTAL_COUNT=0

# Vector definitions for Labour Force Survey (Table 14-10-0287-01)
# Canada, Total Gender, 15 years and over, Seasonally adjusted
# Format: vectorId|description
VECTORS=(
    "2064888|Population"
    "2064889|Labour force"
    "2064890|Employment"
    "2064891|Full-time employment"
    "2064892|Part-time employment"
    "2064893|Unemployment"
    "2064894|Unemployment rate"
    "2064895|Participation rate"
    "2064896|Employment rate"
)

echo "Fetching Labour Force Survey data (Table 14-10-0287-01)..."
echo ""

for vector_def in "${VECTORS[@]}"; do
    IFS='|' read -r vector_id description <<< "$vector_def"

    echo "Fetching: $description (v$vector_id)"

    # Build POST body - get last 12 months
    POST_BODY="[{\"vectorId\": $vector_id, \"latestN\": 12}]"

    TEMP_FILE="$RAW_DIR/temp-v$vector_id.json"

    HTTP_CODE=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$POST_BODY" \
        -o "$TEMP_FILE" \
        --max-time 30 \
        "$BASE_URL/getDataFromVectorsAndLatestNPeriods" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_FILE" ]]; then
        # Check for success status
        STATUS=$(jq -r '.[0].status // "FAILED"' "$TEMP_FILE" 2>/dev/null)

        if [[ "$STATUS" == "SUCCESS" ]]; then
            # Extract data points and convert to JSONL
            NEW_COUNT=$(jq -r '.[0].object.vectorDataPoint | length' "$TEMP_FILE" 2>/dev/null || echo 0)

            jq -c --arg desc "$description" '
                .[0].object as $obj |
                $obj.vectorDataPoint[] |
                {
                    product_id: ($obj.productId | tostring),
                    vector_id: ($obj.vectorId | tostring),
                    coordinate: $obj.coordinate,
                    description: $desc,
                    ref_period: .refPer,
                    value: .value,
                    decimals: .decimals,
                    scalar_factor: .scalarFactorCode,
                    status_code: .statusCode,
                    symbol_code: .symbolCode,
                    release_time: .releaseTime,
                    frequency_code: .frequencyCode,
                    fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
                    source: "statcan_api"
                }
            ' "$TEMP_FILE" >> "$OUTPUT_JSONL" 2>/dev/null

            TOTAL_COUNT=$((TOTAL_COUNT + NEW_COUNT))
            echo "  OK: $NEW_COUNT records"
        else
            ERROR_MSG=$(jq -r '.[0].object // "Unknown error"' "$TEMP_FILE" 2>/dev/null)
            echo "  API Error: $ERROR_MSG" >&2
        fi
    else
        echo "  Failed (HTTP $HTTP_CODE)" >&2
    fi

    rm -f "$TEMP_FILE"
    sleep 0.3
done

echo ""
echo "=== Fetch completed ==="

if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_COUNT -gt 0 ]]; then
    FINAL_COUNT=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')
    echo "Total: $FINAL_COUNT records"
    echo "Output: $OUTPUT_JSONL"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"
else
    echo "Warning: No data fetched" >&2
    touch "$OUTPUT_JSONL"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"
    exit 1
fi

echo "End: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Fetch completed: $LAYER_NAME"
