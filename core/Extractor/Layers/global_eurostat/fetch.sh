#!/bin/bash
# global_eurostat 資料擷取腳本
# 職責：從 Eurostat API 下載就業市場統計數據

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/time.sh"

LAYER_NAME="global_eurostat"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# === Eurostat API 設定 ===
BASE_URL="https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data"

# 計算起始時間（取最近 12 個月）
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
START_YEAR=$((CURRENT_YEAR - 1))
START_PERIOD="${START_YEAR}M${CURRENT_MONTH}"

echo "開始擷取 Eurostat 資料（起始時間：$START_PERIOD）"

# === 1. 失業率（月度）===
echo "擷取失業率數據（une_rt_m）..."
DATASET="une_rt_m"
OUTPUT_FILE="$RAW_DIR/unemployment-$(date +%Y%m%d).json"

# 擷取歐盟整體失業率
curl -s "${BASE_URL}/${DATASET}?format=JSON&geo=EU27_2020&sinceTimePeriod=${START_PERIOD}" \
  -H "Accept: application/json" \
  -o "$OUTPUT_FILE" || {
  echo "警告：失業率數據擷取失敗" >&2
  rm -f "$OUTPUT_FILE"
}

if [[ -f "$OUTPUT_FILE" ]]; then
  # 驗證 JSON 格式
  if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "錯誤：失業率數據 JSON 格式無效" >&2
    rm -f "$OUTPUT_FILE"
  else
    echo "失業率數據擷取成功：$(wc -c < "$OUTPUT_FILE") bytes"
  fi
fi

# === 2. 就業率（年度）===
echo "擷取就業率數據（lfsi_emp_a）..."
DATASET="lfsi_emp_a"
OUTPUT_FILE="$RAW_DIR/employment-$(date +%Y%m%d).json"

# 擷取最近 3 年的就業率
YEAR_START=$((CURRENT_YEAR - 3))

curl -s "${BASE_URL}/${DATASET}?format=JSON&geo=EU27_2020&sinceTimePeriod=${YEAR_START}" \
  -H "Accept: application/json" \
  -o "$OUTPUT_FILE" || {
  echo "警告：就業率數據擷取失敗" >&2
  rm -f "$OUTPUT_FILE"
}

if [[ -f "$OUTPUT_FILE" ]]; then
  if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "錯誤：就業率數據 JSON 格式無效" >&2
    rm -f "$OUTPUT_FILE"
  else
    echo "就業率數據擷取成功：$(wc -c < "$OUTPUT_FILE") bytes"
  fi
fi

# === 3. 薪資結構統計（年度）===
echo "擷取薪資統計數據（earn_ses_annual）..."
DATASET="earn_ses_annual"
OUTPUT_FILE="$RAW_DIR/wage-$(date +%Y%m%d).json"

curl -s "${BASE_URL}/${DATASET}?format=JSON&geo=EU27_2020&sinceTimePeriod=${YEAR_START}" \
  -H "Accept: application/json" \
  -o "$OUTPUT_FILE" || {
  echo "警告：薪資統計數據擷取失敗" >&2
  rm -f "$OUTPUT_FILE"
}

if [[ -f "$OUTPUT_FILE" ]]; then
  if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "錯誤：薪資統計數據 JSON 格式無效" >&2
    rm -f "$OUTPUT_FILE"
  else
    echo "薪資統計數據擷取成功：$(wc -c < "$OUTPUT_FILE") bytes"
  fi
fi

# === 轉換為 JSONL ===
echo "轉換為 JSONL 格式..."

for json_file in "$RAW_DIR"/*.json; do
  [[ -f "$json_file" ]] || continue

  base_name=$(basename "$json_file" .json)
  jsonl_file="$RAW_DIR/${base_name}.jsonl"

  # Eurostat JSON-stat 格式需要特殊處理
  # 將每個時間點的數據展開為一筆 JSONL 記錄
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
    echo "警告：$json_file 轉換失敗，可能格式不符" >&2
    continue
  }

  line_count=$(wc -l < "$jsonl_file" 2>/dev/null || echo 0)
  echo "已轉換：$jsonl_file（$line_count 筆記錄）"
done

# === 記錄擷取時間 ===
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$RAW_DIR/.last_fetch"

echo "Fetch completed: $LAYER_NAME"
echo "資料位置：$RAW_DIR"
echo "下一步：執行萃取流程處理 JSONL 檔案"
