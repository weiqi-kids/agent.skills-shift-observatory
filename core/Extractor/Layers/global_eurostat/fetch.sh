#!/bin/bash
# global_eurostat data fetcher
# Fetches employment statistics from Eurostat API

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_eurostat"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# Eurostat API endpoint
BASE_URL="https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data"

# Calculate start period (last 12 months)
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
START_YEAR=$((CURRENT_YEAR - 1))
START_PERIOD="${START_YEAR}M${CURRENT_MONTH}"

echo "=== global_eurostat fetch ==="
echo "Start period: $START_PERIOD"

# 1. Unemployment rate (monthly)
echo "Fetching unemployment rate (une_rt_m)..."
DATASET="une_rt_m"
OUTPUT_FILE="$RAW_DIR/unemployment-$(date +%Y%m%d).json"

curl -s "${BASE_URL}/${DATASET}?format=JSON&geo=EU27_2020&sinceTimePeriod=${START_PERIOD}" \
  -H "Accept: application/json" \
  -o "$OUTPUT_FILE" || {
  echo "Warning: Failed to fetch unemployment data" >&2
  rm -f "$OUTPUT_FILE"
}

if [[ -f "$OUTPUT_FILE" ]]; then
  if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "Error: Invalid JSON in unemployment data" >&2
    rm -f "$OUTPUT_FILE"
  else
    echo "  OK: $(wc -c < "$OUTPUT_FILE") bytes"
  fi
fi

# 2. Employment rate (annual)
echo "Fetching employment rate (lfsi_emp_a)..."
DATASET="lfsi_emp_a"
OUTPUT_FILE="$RAW_DIR/employment-$(date +%Y%m%d).json"
YEAR_START=$((CURRENT_YEAR - 3))

curl -s "${BASE_URL}/${DATASET}?format=JSON&geo=EU27_2020&sinceTimePeriod=${YEAR_START}" \
  -H "Accept: application/json" \
  -o "$OUTPUT_FILE" || {
  echo "Warning: Failed to fetch employment data" >&2
  rm -f "$OUTPUT_FILE"
}

if [[ -f "$OUTPUT_FILE" ]]; then
  if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "Error: Invalid JSON in employment data" >&2
    rm -f "$OUTPUT_FILE"
  else
    echo "  OK: $(wc -c < "$OUTPUT_FILE") bytes"
  fi
fi

# 3. Wage statistics (annual)
echo "Fetching wage statistics (earn_ses_annual)..."
DATASET="earn_ses_annual"
OUTPUT_FILE="$RAW_DIR/wage-$(date +%Y%m%d).json"

curl -s "${BASE_URL}/${DATASET}?format=JSON&geo=EU27_2020&sinceTimePeriod=${YEAR_START}" \
  -H "Accept: application/json" \
  -o "$OUTPUT_FILE" || {
  echo "Warning: Failed to fetch wage data" >&2
  rm -f "$OUTPUT_FILE"
}

if [[ -f "$OUTPUT_FILE" ]]; then
  if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "Error: Invalid JSON in wage data" >&2
    rm -f "$OUTPUT_FILE"
  else
    echo "  OK: $(wc -c < "$OUTPUT_FILE") bytes"
  fi
fi

# Convert to JSONL
echo "Converting to JSONL..."

for json_file in "$RAW_DIR"/*.json; do
  [[ -f "$json_file" ]] || continue

  base_name=$(basename "$json_file" .json)
  jsonl_file="$RAW_DIR/${base_name}.jsonl"

  jq -c '
    .dimension.time.category.index as $timeIndex |
    .dimension.geo.category.index as $geoIndex |
    .dimension.geo.category.label as $geoLabel |
    .value as $values |
    .id as $dimensions |
    $timeIndex | to_entries[] |
    {
      dataset: ($dimensions | join(",")),
      time: .key,
      time_index: .value,
      geo: ($geoIndex | keys[0]),
      geo_label: ($geoLabel[($geoIndex | keys[0])]),
      value: $values[(.value | tostring)],
      fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
      source_file: "'"$base_name"'"
    }
  ' "$json_file" > "$jsonl_file" 2>/dev/null || {
    echo "Warning: Failed to convert $json_file" >&2
    continue
  }

  line_count=$(wc -l < "$jsonl_file" 2>/dev/null || echo 0)
  echo "  Converted: $jsonl_file ($line_count records)"
done

# Record fetch time
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$RAW_DIR/.last_fetch"

echo "=== Fetch completed: $LAYER_NAME ==="
