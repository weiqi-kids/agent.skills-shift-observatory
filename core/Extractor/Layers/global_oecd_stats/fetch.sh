#!/bin/bash
# global_oecd_stats data fetcher
# Fetches labour statistics from OECD.Stat SDMX-JSON API

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_oecd_stats"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d)
OUTPUT_JSONL="$RAW_DIR/oecd-$TIMESTAMP.jsonl"

BASE_URL="https://stats.oecd.org/SDMX-JSON/data"

echo "=== global_oecd_stats fetch ==="
echo "Start: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Source: OECD.Stat"
echo ""

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq required" >&2
    exit 1
fi

TOTAL_COUNT=0
CURRENT_YEAR=$(date +%Y)

# Simple dataset - get just the headline figures for each country
# Countries and their names
fetch_country() {
    local country=$1
    local country_name=$2
    local indicator=$3
    local indicator_name=$4

    API_URL="${BASE_URL}/LFS_SEXAGE_I_R/${country}.${indicator}.Y.MW.Y_GE15/all?startTime=$((CURRENT_YEAR - 2))&dimensionAtObservation=allDimensions"

    TEMP_FILE="$RAW_DIR/temp-${indicator}-${country}.json"

    HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$TEMP_FILE" --max-time 30 "$API_URL" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_FILE" ]]; then
        # Get time periods
        local time_periods
        time_periods=$(jq -r '.structure.dimensions.observation[] | select(.id == "TIME_PERIOD") | .values | map(.id) | join(",")' "$TEMP_FILE" 2>/dev/null)

        # Get the 15+ age group series (index 0:0:1:0:0:0)
        local obs
        obs=$(jq -r '.data.dataSets[0].series["0:0:1:0:0:0"].observations // {} | to_entries[] | "\(.key)|\(.value[0])"' "$TEMP_FILE" 2>/dev/null)

        IFS=',' read -ra TIMES <<< "$time_periods"

        echo "$obs" | while IFS='|' read -r time_idx value; do
            if [[ -n "$time_idx" ]] && [[ -n "$value" ]]; then
                local period="${TIMES[$time_idx]:-UNK}"
                jq -nc \
                    --arg dataset "LFS_SEXAGE_I_R" \
                    --arg indicator "$indicator" \
                    --arg indicator_name "$indicator_name" \
                    --arg country "$country" \
                    --arg country_name "$country_name" \
                    --arg time_period "$period" \
                    --arg value "$value" \
                    '{
                        dataset: $dataset,
                        indicator: $indicator,
                        indicator_name: $indicator_name,
                        country: $country,
                        country_name: $country_name,
                        time_period: $time_period,
                        value: ($value | tonumber),
                        unit: "%",
                        fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
                        source: "oecd_stat"
                    }' 2>/dev/null
            fi
        done >> "$OUTPUT_JSONL"
    fi

    rm -f "$TEMP_FILE"
}

echo "Fetching OECD labour statistics..."
echo ""

# Unemployment rate
echo "Indicator: Unemployment rate"
fetch_country "KOR" "South Korea" "UR" "Unemployment rate"
fetch_country "JPN" "Japan" "UR" "Unemployment rate"
fetch_country "USA" "United States" "UR" "Unemployment rate"
fetch_country "DEU" "Germany" "UR" "Unemployment rate"
fetch_country "GBR" "United Kingdom" "UR" "Unemployment rate"
fetch_country "FRA" "France" "UR" "Unemployment rate"
fetch_country "CAN" "Canada" "UR" "Unemployment rate"
fetch_country "AUS" "Australia" "UR" "Unemployment rate"
echo "  Done"

# Employment rate
echo "Indicator: Employment rate"
fetch_country "KOR" "South Korea" "ER" "Employment rate"
fetch_country "JPN" "Japan" "ER" "Employment rate"
fetch_country "USA" "United States" "ER" "Employment rate"
fetch_country "DEU" "Germany" "ER" "Employment rate"
fetch_country "GBR" "United Kingdom" "ER" "Employment rate"
fetch_country "FRA" "France" "ER" "Employment rate"
fetch_country "CAN" "Canada" "ER" "Employment rate"
fetch_country "AUS" "Australia" "ER" "Employment rate"
echo "  Done"

# Labour force participation rate
echo "Indicator: Labour force participation rate"
fetch_country "KOR" "South Korea" "LFP" "Labour force participation rate"
fetch_country "JPN" "Japan" "LFP" "Labour force participation rate"
fetch_country "USA" "United States" "LFP" "Labour force participation rate"
fetch_country "DEU" "Germany" "LFP" "Labour force participation rate"
fetch_country "GBR" "United Kingdom" "LFP" "Labour force participation rate"
fetch_country "FRA" "France" "LFP" "Labour force participation rate"
fetch_country "CAN" "Canada" "LFP" "Labour force participation rate"
fetch_country "AUS" "Australia" "LFP" "Labour force participation rate"
echo "  Done"

echo ""
echo "=== Fetch completed ==="

if [[ -f "$OUTPUT_JSONL" ]] && [[ -s "$OUTPUT_JSONL" ]]; then
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
