#!/bin/bash
# global_oecd_stats data fetcher
# Fetches labour statistics from OECD.Stat using CSV bulk download

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

echo "=== global_oecd_stats fetch ==="
echo "Start: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Source: OECD.Stat (CSV bulk download)"
echo ""

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq required" >&2
    exit 1
fi

CURRENT_YEAR=$(date +%Y)
START_YEAR=$((CURRENT_YEAR - 2))

# Target countries
COUNTRIES="KOR|JPN|USA|DEU|GBR|FRA|CAN|AUS"

# Country name mapping function (bash 3.2 compatible)
get_country_name() {
    case "$1" in
        KOR) echo "South Korea" ;;
        JPN) echo "Japan" ;;
        USA) echo "United States" ;;
        DEU) echo "Germany" ;;
        GBR) echo "United Kingdom" ;;
        FRA) echo "France" ;;
        CAN) echo "Canada" ;;
        AUS) echo "Australia" ;;
        *) echo "$1" ;;
    esac
}

# Measure name mapping function
get_measure_name() {
    case "$1" in
        UNE_RATE) echo "Unemployment rate" ;;
        EMP_RATIO) echo "Employment rate" ;;
        LF_RATE) echo "Labour force participation rate" ;;
        *) echo "$1" ;;
    esac
}

# Measure to category mapping
get_category() {
    case "$1" in
        UNE_RATE) echo "unemployment_rate" ;;
        EMP_RATIO) echo "employment_rate" ;;
        LF_RATE) echo "participation_rate" ;;
        *) echo "other" ;;
    esac
}

echo "Downloading OECD labour statistics CSV..."

# Download all LFS data at once (more efficient than multiple requests)
TEMP_CSV="$RAW_DIR/temp-lfs.csv"
CSV_URL="https://stats.oecd.org/sdmx-json/data/LFS_SEXAGE_I_R/all/all?startTime=${START_YEAR}&contentType=csv"

HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$TEMP_CSV" --max-time 300 "$CSV_URL" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" != "200" ]] || [[ ! -s "$TEMP_CSV" ]]; then
    echo "Error: Failed to download CSV (HTTP $HTTP_CODE)" >&2
    rm -f "$TEMP_CSV"
    exit 1
fi

TOTAL_ROWS=$(wc -l < "$TEMP_CSV" | tr -d ' ')
echo "Downloaded $TOTAL_ROWS rows"
echo ""

echo "Filtering and converting to JSONL..."

# Clear output file
> "$OUTPUT_JSONL"

# Filter: target countries, key measures, total sex, 15-64 age group
tail -n +2 "$TEMP_CSV" | \
    grep -E ",($COUNTRIES)," | \
    grep -E ",(UNE_RATE|EMP_RATIO|LF_RATE)," | \
    grep ",_T," | \
    grep ",Y15T64," | \
    while IFS=',' read -r dataflow ref_area measure unit_measure sex age lf_status time_period obs_value rest; do
        # Skip if no value
        [[ -z "$obs_value" ]] && continue

        # Skip non-numeric values
        [[ ! "$obs_value" =~ ^[0-9.]+$ ]] && continue

        country_name=$(get_country_name "$ref_area")
        measure_name=$(get_measure_name "$measure")
        category=$(get_category "$measure")

        jq -nc \
            --arg dataset "LFS_SEXAGE_I_R" \
            --arg indicator "$measure" \
            --arg indicator_name "$measure_name" \
            --arg category "$category" \
            --arg country "$ref_area" \
            --arg country_name "$country_name" \
            --arg time_period "$time_period" \
            --arg value "$obs_value" \
            '{
                dataset: $dataset,
                indicator: $indicator,
                indicator_name: $indicator_name,
                category: $category,
                country: $country,
                country_name: $country_name,
                time_period: $time_period,
                value: ($value | tonumber),
                unit: "%",
                age_group: "Y15T64",
                sex: "Total",
                fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
                source: "oecd_stat"
            }' 2>/dev/null
    done >> "$OUTPUT_JSONL"

# Cleanup
rm -f "$TEMP_CSV"

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
