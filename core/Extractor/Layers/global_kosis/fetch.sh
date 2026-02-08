#!/bin/bash
# global_kosis 資料擷取腳本
# 從韓國統計廳 (KOSIS) Open API 擷取就業統計資料
# API 文件：https://kosis.kr/openapi/openApiIntro.do

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

LAYER_NAME="global_kosis"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# 設定檔案路徑
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_JSONL="$RAW_DIR/stats-$TIMESTAMP.jsonl"

# KOSIS Open API
BASE_URL="https://kosis.kr/openapi/Param/statisticsParameterData.do"

echo "=== global_kosis 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: KOSIS (Korea Statistical Information Service)"
echo ""

# 檢查 API key
if [[ -z "${KOSIS_API_KEY:-}" ]]; then
    echo "錯誤: 需要在 .env 設定 KOSIS_API_KEY" >&2
    echo "請至 https://kosis.kr/openapi/ 申請 API key" >&2
    exit 1
fi

# 檢查 jq 是否可用
if ! command -v jq >/dev/null 2>&1; then
    echo "錯誤: 需要 jq 來解析 JSON" >&2
    exit 1
fi

# 初始化計數器
TOTAL_COUNT=0

# 計算日期範圍（擷取最近 12 個月的資料）
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
START_YEAR=$((CURRENT_YEAR - 1))
START_MONTH=$CURRENT_MONTH

START_PERIOD=$(printf "%04d%02d" $START_YEAR $START_MONTH)
END_PERIOD=$(printf "%04d%02d" $CURRENT_YEAR $CURRENT_MONTH)

echo "擷取時期範圍: $START_PERIOD ~ $END_PERIOD"
echo ""

# === 擷取經濟活動人口調查（月度）===
echo "擷取統計表: 經濟活動人口調查 (DT_1DA7012S)"

STAT_CODE="DT_1DA7012S"
ORG_ID="101"

# 擷取三個主要指標：T10（就業人數）、T20（就業率）、T30（失業人數）、T40（失業率）、T50（勞動參與率）
ITEM_IDS="T10+T20+T30+T40+T50"

API_URL="${BASE_URL}?method=getList&apiKey=${KOSIS_API_KEY}&itmId=${ITEM_IDS}&objL1=ALL&format=json&jsonVD=Y&prdSe=M&startPrdDe=${START_PERIOD}&endPrdDe=${END_PERIOD}&orgId=${ORG_ID}&tblId=${STAT_CODE}"

TEMP_JSON="$RAW_DIR/temp-$TIMESTAMP.json"

HTTP_CODE=$(curl -s -w "%{http_code}" -o "$TEMP_JSON" \
    --max-time 60 \
    "$API_URL" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_JSON" ]]; then
    echo "  ✓ API 回應成功，正在轉換為 JSONL..."

    # KOSIS API 回傳格式範例：
    # [
    #   {
    #     "TBL_ID": "DT_1DA7012S",
    #     "TBL_NM": "경제활동인구조사",
    #     "PRD_DE": "202412",
    #     "PRD_SE": "M",
    #     "ITM_ID": "T10",
    #     "ITM_NM": "취업자",
    #     "DT": "28500",
    #     "UNIT_NM": "천명",
    #     "ORG_ID": "101",
    #     "C1": "전국",
    #     "C1_NM": "전국"
    #   },
    #   ...
    # ]

    # 轉換為標準化 JSONL 格式
    jq -c '.[] | {
        stat_code: .TBL_ID,
        stat_name: .TBL_NM,
        period: .PRD_DE,
        period_type: .PRD_SE,
        item_code: .ITM_ID,
        item_name: .ITM_NM,
        value: (.DT | tonumber? // 0),
        unit: .UNIT_NM,
        org_id: .ORG_ID,
        obj_l1: .C1,
        obj_l1_name: .C1_NM,
        fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
        source: "kosis_api"
    }' "$TEMP_JSON" >> "$OUTPUT_JSONL" 2>/dev/null || {
        echo "  ✗ JSON 解析失敗" >&2
        echo "  原始回應（前 500 字元）：" >&2
        head -c 500 "$TEMP_JSON" >&2
        rm -f "$TEMP_JSON"
        exit 1
    }

    # 計算筆數
    STAT_COUNT=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')
    echo "  找到 $STAT_COUNT 筆資料"
    ((TOTAL_COUNT += STAT_COUNT))

else
    echo "  ✗ API 請求失敗 (HTTP $HTTP_CODE)" >&2
    if [[ -s "$TEMP_JSON" ]]; then
        echo "  錯誤訊息：" >&2
        head -c 500 "$TEMP_JSON" >&2
    fi
fi

# 清理暫存檔
rm -f "$TEMP_JSON"

echo ""

# === 擷取就業動向（月度）===
echo "擷取統計表: 就業動向 (DT_1DA7102S)"

STAT_CODE="DT_1DA7102S"

# 使用相同的指標代碼
API_URL="${BASE_URL}?method=getList&apiKey=${KOSIS_API_KEY}&itmId=${ITEM_IDS}&objL1=ALL&format=json&jsonVD=Y&prdSe=M&startPrdDe=${START_PERIOD}&endPrdDe=${END_PERIOD}&orgId=${ORG_ID}&tblId=${STAT_CODE}"

TEMP_JSON="$RAW_DIR/temp-2-$TIMESTAMP.json"

HTTP_CODE=$(curl -s -w "%{http_code}" -o "$TEMP_JSON" \
    --max-time 60 \
    "$API_URL" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_JSON" ]]; then
    echo "  ✓ API 回應成功，正在轉換為 JSONL..."

    jq -c '.[] | {
        stat_code: .TBL_ID,
        stat_name: .TBL_NM,
        period: .PRD_DE,
        period_type: .PRD_SE,
        item_code: .ITM_ID,
        item_name: .ITM_NM,
        value: (.DT | tonumber? // 0),
        unit: .UNIT_NM,
        org_id: .ORG_ID,
        obj_l1: .C1,
        obj_l1_name: .C1_NM,
        fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
        source: "kosis_api"
    }' "$TEMP_JSON" >> "$OUTPUT_JSONL" 2>/dev/null || echo "  ⚠️  JSON 解析失敗，跳過此統計表" >&2

    STAT_COUNT=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')
    NEW_COUNT=$((STAT_COUNT - TOTAL_COUNT))
    echo "  找到 $NEW_COUNT 筆資料"
    TOTAL_COUNT=$STAT_COUNT

else
    echo "  ⚠️  API 請求失敗 (HTTP $HTTP_CODE)，跳過此統計表" >&2
fi

# 清理暫存檔
rm -f "$TEMP_JSON"

echo ""

# === 去重（依 stat_code + item_code + period + obj_l1 組合）===
if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_COUNT -gt 0 ]]; then
    BEFORE=$TOTAL_COUNT
    TEMP_DEDUP="$RAW_DIR/temp-dedup-$TIMESTAMP.jsonl"

    # 依唯一鍵組合去重
    jq -sc 'group_by(.stat_code + .item_code + .period + .obj_l1) | map(.[0])[]' "$OUTPUT_JSONL" > "$TEMP_DEDUP" 2>/dev/null && \
        mv "$TEMP_DEDUP" "$OUTPUT_JSONL" || rm -f "$TEMP_DEDUP"

    AFTER=$(wc -l < "$OUTPUT_JSONL" | tr -d ' ')

    if [[ "$BEFORE" -ne "$AFTER" ]]; then
        echo "去重: $BEFORE → $AFTER 筆"
        TOTAL_COUNT=$AFTER
    fi
fi

# === 最終結果 ===
echo "=== 擷取完成 ==="
if [[ -f "$OUTPUT_JSONL" ]] && [[ $TOTAL_COUNT -gt 0 ]]; then
    echo "總筆數: $TOTAL_COUNT"
    echo "輸出檔案: $OUTPUT_JSONL"

    # 記錄最後擷取時間
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"
else
    echo "⚠️  未擷取到任何統計資料" >&2
    echo "可能原因:" >&2
    echo "  1. KOSIS API key 無效或過期" >&2
    echo "  2. 網路連線問題" >&2
    echo "  3. 指定的統計表代碼或時期範圍無資料" >&2
    echo "建議: 檢查 API key 或至 https://kosis.kr/openapi/ 確認 API 狀態" >&2

    # 仍建立空檔案並記錄時間
    touch "$OUTPUT_JSONL"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$RAW_DIR/.last_fetch"
    exit 1
fi

echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Fetch completed: $LAYER_NAME"
