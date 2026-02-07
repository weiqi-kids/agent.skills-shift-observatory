#!/bin/bash
# global_oecd_employment 資料擷取腳本
# 職責：從 OECD SDMX REST API 擷取就業統計數據

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

require_cmd curl
require_cmd jq

LAYER_NAME="global_oecd_employment"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$RAW_DIR/oecd-${TIMESTAMP}.jsonl"

# OECD SDMX REST API (new endpoint since 2024)
# Docs: https://data-explorer.oecd.org/
BASE_URL="https://sdmx.oecd.org/public/rest/data"

# OECD 成員國代碼
COUNTRIES="USA+JPN+DEU+GBR+FRA+CAN+AUS+KOR+NLD+CHE+SWE+NOR+DNK+FIN+NZL+IRL+BEL+AUT+ESP+ITA+PRT+POL+CZE+HUN+MEX+CHL+COL+TUR"

CURRENT_YEAR=$(date +%Y)
START_PERIOD=$((CURRENT_YEAR - 2))

# OECD 資料集定義（使用平行陣列，相容 bash 3.2）
DS_IDS=(
  "OECD.SDD.TPS,DSD_LFS@DF_IALFS_UNE_M,1.0"
  "OECD.SDD.TPS,DSD_LFS@DF_IALFS_EMP_M,1.0"
  "OECD.SDD.TPS,DSD_EARNINGS@DF_AV_AN_WAGE,1.0"
)
DS_LABELS=(
  "Monthly unemployment rate"
  "Monthly employment rate"
  "Average annual wages"
)

# 備援 OECD.Stat v3 端點（舊版 API）
LEGACY_BASE_URL="https://stats.oecd.org/SDMX-JSON/data"

TOTAL_RECORDS=0

echo "=== global_oecd_employment 資料擷取開始 ==="
echo "時間戳: $TIMESTAMP"
echo ""

for i in $(seq 0 $((${#DS_IDS[@]} - 1))); do
  dataset_id="${DS_IDS[$i]}"
  dataset_label="${DS_LABELS[$i]}"
  echo "正在擷取: $dataset_label"
  echo "  Dataset: $dataset_id"

  # SDMX REST API query
  # 新版 OECD API 格式: /OECD.SDD.TPS,DSD_LFS@DF_IALFS_UNE_M,1.0/{countries}...
  API_URL="${BASE_URL}/${dataset_id}/${COUNTRIES}...?format=jsondata&startPeriod=${START_PERIOD}&dimensionAtObservation=AllDimensions"

  TEMP_FILE="$RAW_DIR/temp_oecd_${TIMESTAMP}_$(echo "$dataset_id" | tr '.,@/' '____').json"

  HTTP_CODE=$(curl -sS -L \
       -H "Accept: application/vnd.sdmx.data+json;version=2.0.0" \
       -H "User-Agent: SkillsShiftObservatory/1.0" \
       --connect-timeout 30 \
       --max-time 120 \
       -w '%{http_code}' \
       -o "$TEMP_FILE" \
       "$API_URL" 2>/dev/null) || HTTP_CODE="000"

  if [[ "$HTTP_CODE" == "200" ]] && jq empty "$TEMP_FILE" 2>/dev/null; then
    echo "  HTTP 200 — 解析 SDMX-JSON..."

    # 解析 SDMX-JSON 格式 (dimensionAtObservation=AllDimensions)
    jq -c --arg ds_id "$dataset_id" --arg ds_label "$dataset_label" '
      .structure.dimensions.observation as $dims |

      .dataSets[0].observations | to_entries[] |
      (
        (.key | split(":") | map(tonumber)) as $indices |
        .value[0] as $obs_value |

        (reduce range(0; $dims | length) as $i (
          {};
          . + {($dims[$i].id): ($dims[$i].values[$indices[$i]] // {id: "unknown", name: "Unknown"})}
        )) as $dim_values |

        {
          dataset_id: $ds_id,
          dataset_label: $ds_label,
          country_code: ($dim_values.REF_AREA.id // $dim_values.LOCATION.id // "unknown"),
          country: ($dim_values.REF_AREA.name // $dim_values.LOCATION.name // "Unknown"),
          indicator: ($dim_values.MEASURE.id // $dim_values.INDICATOR.id // $dim_values.SUBJECT.id // null),
          indicator_label: ($dim_values.MEASURE.name // $dim_values.INDICATOR.name // $dim_values.SUBJECT.name // null),
          time_period: ($dim_values.TIME_PERIOD.id // "unknown"),
          value: $obs_value,
          unit: ($dim_values.UNIT_MEASURE.id // $dim_values.UNIT.id // null),
          unit_label: ($dim_values.UNIT_MEASURE.name // $dim_values.UNIT.name // null),
          frequency: ($dim_values.FREQ.id // null),
          sex: ($dim_values.SEX.id // null),
          age: ($dim_values.AGE.id // null),
          source_url: "https://data-explorer.oecd.org/"
        }
      )
    ' "$TEMP_FILE" >> "$OUTPUT_FILE" 2>/dev/null || {
      echo "  ✗ JSON 解析失敗，SDMX 結構可能不符預期" >&2
    }

    RECORD_COUNT=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
    NEW_RECORDS=$((RECORD_COUNT - TOTAL_RECORDS))
    TOTAL_RECORDS=$RECORD_COUNT
    echo "  ✓ 成功：新增 $NEW_RECORDS 筆記錄"

  elif [[ "$HTTP_CODE" =~ ^(404|500|503)$ ]]; then
    echo "  ✗ HTTP $HTTP_CODE — 嘗試舊版 API..." >&2

    # 備援：嘗試舊版 OECD.Stat API
    # 舊版使用不同的 dataset ID 格式
    LEGACY_DATASETS=("LFS_SEXAGE_I_R" "AV_AN_WAGE")
    for legacy_ds in "${LEGACY_DATASETS[@]}"; do
      LEGACY_URL="${LEGACY_BASE_URL}/${legacy_ds}/USA+JPN+DEU+GBR+FRA+CAN+AUS+KOR/all?startTime=${START_PERIOD}&json=text"

      if curl -sS -L \
           -H "User-Agent: SkillsShiftObservatory/1.0" \
           --connect-timeout 30 \
           --max-time 120 \
           -o "$TEMP_FILE" \
           "$LEGACY_URL" 2>/dev/null && jq empty "$TEMP_FILE" 2>/dev/null; then

        # 舊版 API JSON 格式不同，嘗試基本解析
        jq -c --arg ds "$legacy_ds" '
          if .dataSets then
            .structure.dimensions.observation as $dims |
            .dataSets[0].observations // {} | to_entries[] |
            (
              (.key | split(":") | map(tonumber)) as $idx |
              .value[0] as $val |
              (reduce range(0; $dims | length) as $i (
                {};
                . + {($dims[$i].id): ($dims[$i].values[$idx[$i]] // {id:"?",name:"?"})}
              )) as $dv |
              {
                dataset_id: $ds,
                country_code: ($dv.LOCATION.id // $dv.REF_AREA.id // "?"),
                country: ($dv.LOCATION.name // $dv.REF_AREA.name // "?"),
                time_period: ($dv.TIME_PERIOD.id // $dv.TIME.id // "?"),
                value: $val,
                source_url: "https://stats.oecd.org/"
              }
            )
          else empty end
        ' "$TEMP_FILE" >> "$OUTPUT_FILE" 2>/dev/null || true

        echo "  ✓ 舊版 API ($legacy_ds) 已嘗試"
      fi
      sleep 1
    done

  else
    echo "  ✗ HTTP $HTTP_CODE — 擷取失敗" >&2
  fi

  rm -f "$TEMP_FILE"
  sleep 2
  echo ""
done

# === 最終檢查 ===
if [[ -s "$OUTPUT_FILE" ]]; then
  TOTAL=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
  echo "=== global_oecd_employment 資料擷取完成 ==="
  echo "Fetch completed: $LAYER_NAME"
  echo "Output: $OUTPUT_FILE"
  echo "Records: $TOTAL"
else
  echo "=== global_oecd_employment 資料擷取完成（無資料）==="
  echo "警告：未擷取到任何資料。可能原因："
  echo "  1. OECD API 暫時無法存取"
  echo "  2. API 端點或 dataset ID 已變更"
  echo "  3. 網路連線問題"
  echo "建議：手動確認 API — https://data-explorer.oecd.org/"
  touch "$OUTPUT_FILE"
fi

# 記錄最後擷取時間
date -u +%s > "$RAW_DIR/.last_fetch"
