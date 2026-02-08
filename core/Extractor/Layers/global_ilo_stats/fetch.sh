#!/bin/bash
# global_ilo_stats data fetcher
# Fetches labour statistics from ILO ILOSTAT API
# API: https://rplumber.ilo.org/data/indicator/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_ilo_stats"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d)
OUTPUT_JSONL="$RAW_DIR/ilo-$TIMESTAMP.jsonl"

BASE_URL="https://rplumber.ilo.org/data/indicator"

echo "=== global_ilo_stats fetch ==="
echo "Start: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Source: ILO ILOSTAT"
echo ""

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq required" >&2
    exit 1
fi

TOTAL_COUNT=0
CURRENT_YEAR=$(date +%Y)
START_YEAR=$((CURRENT_YEAR - 2))

# Indicator definitions
# Format: indicator_id|description
INDICATORS=(
    "EMP_TEMP_SEX_AGE_NB_A|Employment by sex and age (thousands)"
    "UNE_TUNE_SEX_AGE_NB_A|Unemployment by sex and age (thousands)"
    "EAP_TEAP_SEX_AGE_NB_A|Labour force by sex and age (thousands)"
    "UNE_DEAP_SEX_AGE_RT_A|Unemployment rate by sex and age (%)"
    "EAP_DWAP_SEX_AGE_RT_A|Labour force participation rate (%)"
    "EMP_DWAP_SEX_AGE_RT_A|Employment-to-population ratio (%)"
)

# Countries (ISO3 codes) - major economies for comparison
COUNTRIES=(
    "KOR|South Korea"
    "JPN|Japan"
    "CHN|China"
    "USA|United States"
    "DEU|Germany"
    "GBR|United Kingdom"
    "FRA|France"
    "CAN|Canada"
    "AUS|Australia"
)

echo "Fetching ILO statistics..."
echo ""

for indicator_def in "${INDICATORS[@]}"; do
    IFS='|' read -r indicator_id description <<< "$indicator_def"

    echo "Indicator: $description"

    for country_def in "${COUNTRIES[@]}"; do
        IFS='|' read -r country_code country_name <<< "$country_def"

        # Build API URL (SEX_T=Total, AGE_YTHADULT_YGE15=15+)
        API_URL="${BASE_URL}/?id=${indicator_id}&ref_area=${country_code}&timefrom=${START_YEAR}&sex=SEX_T&classif1=AGE_YTHADULT_YGE15&format=.csv"

        TEMP_FILE="$RAW_DIR/temp-${indicator_id}-${country_code}.csv"

        HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$TEMP_FILE" --max-time 30 "$API_URL" 2>/dev/null || echo "000")

        if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_FILE" ]]; then
            ROW_COUNT=$(tail -n +2 "$TEMP_FILE" | wc -l | tr -d ' ')

            if [[ "$ROW_COUNT" -gt 0 ]]; then
                # Convert CSV to JSONL
                tail -n +2 "$TEMP_FILE" | while IFS=',' read -r ref_area source indicator sex classif1 time obs_value obs_status note_classif note_indicator note_source; do
                    ref_area="${ref_area//\"/}"
                    indicator="${indicator//\"/}"
                    sex="${sex//\"/}"
                    classif1="${classif1//\"/}"
                    time="${time//\"/}"
                    obs_value="${obs_value//\"/}"
                    obs_status="${obs_status//\"/}"

                    jq -nc \
                        --arg ref_area "$ref_area" \
                        --arg country_name "$country_name" \
                        --arg indicator "$indicator" \
                        --arg description "$description" \
                        --arg sex "$sex" \
                        --arg age_group "$classif1" \
                        --arg time "$time" \
                        --arg value "$obs_value" \
                        --arg status "$obs_status" \
                        '{
                            ref_area: $ref_area,
                            country_name: $country_name,
                            indicator: $indicator,
                            description: $description,
                            sex: $sex,
                            age_group: $age_group,
                            time: $time,
                            value: (if $value == "" then null else ($value | tonumber) end),
                            obs_status: $status,
                            fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
                            source: "ilo_ilostat"
                        }' 2>/dev/null
                done >> "$OUTPUT_JSONL"

                TOTAL_COUNT=$((TOTAL_COUNT + ROW_COUNT))
            fi
        fi

        rm -f "$TEMP_FILE"
        sleep 0.2
    done

    echo "  Done"
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
