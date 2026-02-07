#!/bin/bash
# global_ilo_stats 資料擷取腳本
# 職責：從 ILO ILOSTAT SDMX REST API 擷取全球勞動市場統計數據

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

require_cmd curl
require_cmd jq

LAYER_NAME="global_ilo_stats"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$RAW_DIR/ilostat-${TIMESTAMP}.jsonl"

# ILOSTAT SDMX REST API
# 文件: https://sdmx.ilo.org/
BASE_URL="https://sdmx.ilo.org/rest/data"

# 主要指標 Dataflow ID => 標籤（使用平行陣列，相容 bash 3.2）
DF_IDS=("UNE_2EAP_SEX_AGE_RT" "EMP_2EMP_SEX_ECO_DT" "EAR_4MTH_SEX_ECO_CUR_NB")
DF_LABELS=("Unemployment rate by sex and age" "Employment distribution by sex and economic activity" "Mean monthly earnings by sex and economic activity")

# 感興趣的國家（ISO3 codes）
COUNTRIES="ARG+AUS+BRA+CHN+DEU+FRA+GBR+IDN+IND+JPN+KOR+MEX+NGA+USA+ZAF"

CURRENT_YEAR=$(date +%Y)
START_PERIOD=$((CURRENT_YEAR - 3))

TOTAL_RECORDS=0

echo "=== global_ilo_stats 資料擷取開始 ==="
echo "時間戳: $TIMESTAMP"
echo "API: $BASE_URL"
echo ""

for i in $(seq 0 $((${#DF_IDS[@]} - 1))); do
  df_id="${DF_IDS[$i]}"
  df_label="${DF_LABELS[$i]}"
  echo "正在擷取: $df_label ($df_id)"

  # SDMX REST API query
  # Format: /ILO,DF_{id},1.0/{countries}.A....
  # - A = Annual frequency
  # - format=jsondata for SDMX-JSON
  # - lastNObservations=3 to limit data volume
  API_URL="${BASE_URL}/ILO,DF_${df_id},1.0/${COUNTRIES}.A....?format=jsondata&startPeriod=${START_PERIOD}&detail=full"

  TEMP_FILE="$RAW_DIR/temp_${df_id}_${TIMESTAMP}.json"

  if curl -sS -L \
       -H "Accept: application/vnd.sdmx.data+json;version=2.0.0" \
       -H "User-Agent: SkillsShiftObservatory/1.0" \
       --connect-timeout 30 \
       --max-time 120 \
       -o "$TEMP_FILE" \
       "$API_URL" 2>/dev/null; then

    # 檢查是否為有效 JSON
    if jq empty "$TEMP_FILE" 2>/dev/null; then
      # 解析 SDMX-JSON 格式，將 observations 展平為 JSONL
      # SDMX-JSON 結構:
      #   .structure.dimensions.observation[] => 維度定義（REF_AREA, TIME_PERIOD 等）
      #   .dataSets[0].observations => {"0:0:0:0:0": [value], ...}
      #   observation key 的每個數字對應 dimensions 陣列中的 values index

      PARSED_COUNT=$(jq -c --arg df_id "$df_id" --arg df_label "$df_label" --arg api_url "$API_URL" '
        # 取得維度定義
        .structure.dimensions.observation as $dims |

        # 遍歷所有觀測值
        .dataSets[0].observations | to_entries[] |
        (
          # 解析 observation key（如 "0:1:2:0:3"）
          (.key | split(":") | map(tonumber)) as $indices |
          .value[0] as $obs_value |

          # 將索引解析為實際維度值
          (reduce range(0; $dims | length) as $i (
            {};
            . + {($dims[$i].id): ($dims[$i].values[$indices[$i]] // {id: "unknown", name: "Unknown"})}
          )) as $dim_values |

          # 建構輸出記錄
          {
            indicator: $df_id,
            indicator_label: $df_label,
            country_code: ($dim_values.REF_AREA.id // $dim_values.ref_area.id // "unknown"),
            country: ($dim_values.REF_AREA.name // $dim_values.ref_area.name // "Unknown"),
            year: ($dim_values.TIME_PERIOD.id // $dim_values.time_period.id // "unknown"),
            value: $obs_value,
            sex: ($dim_values.SEX.id // $dim_values.sex.id // "total"),
            sex_label: ($dim_values.SEX.name // $dim_values.sex.name // "Total"),
            age_group: ($dim_values.AGE.id // $dim_values.age.id // null),
            age_label: ($dim_values.AGE.name // $dim_values.age.name // null),
            classif1: ($dim_values.CLASSIF1.id // $dim_values.classif1.id // null),
            classif1_label: ($dim_values.CLASSIF1.name // $dim_values.classif1.name // null),
            unit: ($dim_values.UNIT_MEASURE.id // $dim_values.unit_measure.id // null),
            dataset: $df_id,
            source_url: $api_url
          }
        )
      ' "$TEMP_FILE" >> "$OUTPUT_FILE" 2>/dev/null)

      RECORD_COUNT=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
      NEW_RECORDS=$((RECORD_COUNT - TOTAL_RECORDS))
      TOTAL_RECORDS=$RECORD_COUNT
      echo "  ✓ 成功：新增 $NEW_RECORDS 筆記錄"
    else
      echo "  ✗ 回應非有效 JSON，嘗試檢查 HTTP 錯誤..." >&2
      # 檢查是否為 HTTP 錯誤頁面
      head -c 200 "$TEMP_FILE" >&2 2>/dev/null || true
    fi

    rm -f "$TEMP_FILE"
  else
    echo "  ✗ 無法連線至 ILOSTAT API ($df_id)" >&2
  fi

  # API rate limiting
  sleep 3
  echo ""
done

# === 備援方案：若 API 完全無法使用，嘗試 ILOSTAT Bulk Download ===
if [[ ! -s "$OUTPUT_FILE" ]]; then
  echo "警告：SDMX API 未回傳任何資料，嘗試 ILOSTAT Bulk Download..."

  BULK_URL="https://rplumber.ilo.org/data/indicator"

  # 簡化的 bulk download（較少指標）
  BULK_INDICATORS=("UNE_2EAP_SEX_AGE_RT" "EMP_2EMP_SEX_ECO_DT")

  for indicator in "${BULK_INDICATORS[@]}"; do
    echo "  嘗試 bulk download: $indicator"

    BULK_TEMP="$RAW_DIR/temp_bulk_${indicator}_${TIMESTAMP}.csv"

    if curl -sS -L \
         -H "User-Agent: SkillsShiftObservatory/1.0" \
         --connect-timeout 30 \
         --max-time 180 \
         -o "$BULK_TEMP" \
         "${BULK_URL}/?id=${indicator}&timefrom=${START_PERIOD}&type=label&format=csv" 2>/dev/null; then

      # CSV 轉 JSONL（使用 awk 解析 CSV header + rows）
      if [[ -s "$BULK_TEMP" ]] && head -1 "$BULK_TEMP" | grep -q "ref_area\|REF_AREA" 2>/dev/null; then
        # 讀取 CSV header 找出欄位索引
        awk -F',' '
          NR==1 {
            for (i=1; i<=NF; i++) {
              gsub(/"/, "", $i)
              header[i] = tolower($i)
              if (header[i] == "ref_area.label" || header[i] == "ref_area") col_country = i
              if (header[i] == "ref_area") col_country_code = i
              if (header[i] == "time") col_year = i
              if (header[i] == "obs_value") col_value = i
              if (header[i] == "sex.label" || header[i] == "sex") col_sex = i
              if (header[i] == "classif1.label" || header[i] == "classif1") col_classif = i
            }
            next
          }
          NR>1 && $col_value != "" {
            gsub(/"/, "", $col_country)
            gsub(/"/, "", $col_country_code)
            gsub(/"/, "", $col_year)
            gsub(/"/, "", $col_value)
            gsub(/"/, "", $col_sex)
            gsub(/"/, "", $col_classif)
            printf "{\"indicator\":\"%s\",\"indicator_label\":\"%s\",\"country\":\"%s\",\"country_code\":\"%s\",\"year\":\"%s\",\"value\":%s,\"sex\":\"%s\",\"classif1\":\"%s\",\"dataset\":\"%s\",\"source_url\":\"https://ilostat.ilo.org/data/\"}\n", \
              "'$indicator'", "'$indicator'", $col_country, $col_country_code, $col_year, $col_value, $col_sex, $col_classif, "'$indicator'"
          }
        ' "$BULK_TEMP" >> "$OUTPUT_FILE" 2>/dev/null

        BULK_COUNT=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
        echo "  ✓ Bulk download 成功：共 $BULK_COUNT 筆"
      else
        echo "  ✗ Bulk download 回應非預期格式" >&2
      fi

      rm -f "$BULK_TEMP"
    else
      echo "  ✗ Bulk download 失敗: $indicator" >&2
    fi

    sleep 2
  done
fi

# === 最終檢查 ===
if [[ -s "$OUTPUT_FILE" ]]; then
  TOTAL=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
  echo "=== global_ilo_stats 資料擷取完成 ==="
  echo "Fetch completed: $LAYER_NAME"
  echo "Output: $OUTPUT_FILE"
  echo "Records: $TOTAL"
else
  echo "=== global_ilo_stats 資料擷取完成（無資料）==="
  echo "警告：未擷取到任何資料。可能原因："
  echo "  1. ILOSTAT API 暫時無法存取"
  echo "  2. API 端點或格式已變更"
  echo "  3. 網路連線問題"
  echo "建議：手動確認 API 可達性 — curl -I ${BASE_URL}/ILO,DF_UNE_2EAP_SEX_AGE_RT,1.0/"
  # 建立空檔案以標記已執行
  touch "$OUTPUT_FILE"
fi

# 記錄最後擷取時間
date -u +%s > "$RAW_DIR/.last_fetch"
