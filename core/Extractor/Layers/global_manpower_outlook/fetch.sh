#!/bin/bash
# global_manpower_outlook 資料擷取腳本
# 職責：從 ManpowerGroup MEOS 頁面擷取季度就業展望報告元數據

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

require_cmd curl
require_cmd jq

LAYER_NAME="global_manpower_outlook"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$RAW_DIR/meos-${TIMESTAMP}.jsonl"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

echo "=== global_manpower_outlook 資料擷取開始 ==="
echo "時間戳: $TIMESTAMP"
echo ""

TOTAL_RECORDS=0

# === 策略 1：MEOS 主頁面爬取 ===
echo "策略 1：爬取 ManpowerGroup MEOS 主頁面..."

MEOS_URLS=(
  "https://go.manpowergroup.com/meos"
  "https://www.manpowergroup.com/workforce-insights/world-of-work/employment-outlook-survey"
  "https://go.manpowergroup.com/talent-shortage"
)

for meos_url in "${MEOS_URLS[@]}"; do
  echo "  頁面: $meos_url"
  TEMP_HTML="$RAW_DIR/temp-meos-${TIMESTAMP}.html"

  HTTP_CODE=$(curl -sS -L \
    -H "User-Agent: $UA" \
    -H "Accept: text/html,application/xhtml+xml" \
    --connect-timeout 15 \
    --max-time 30 \
    -w '%{http_code}' \
    -o "$TEMP_HTML" \
    "$meos_url" 2>/dev/null) || HTTP_CODE="000"

  if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_HTML" ]]; then
    echo "  ✓ 頁面已下載"

    # 搜尋報告連結（PDF 或子頁面）
    # ManpowerGroup 報告連結模式：
    # - /meos/ 子路徑
    # - employment-outlook, talent-shortage, workforce 相關
    # - PDF 下載連結
    grep -oE 'href="[^"]*"' "$TEMP_HTML" 2>/dev/null | \
      sed 's/href="//;s/"$//' | \
      grep -iE '(employment-outlook|meos|talent-shortage|workforce-insight|quarterly|survey|\.pdf)' | \
      grep -vE '(\.css|\.js|\.png|\.jpg|\.ico|#|javascript:|mailto:)' | \
      sort -u | \
      while IFS= read -r link; do
        # 處理相對路徑
        if [[ ! "$link" =~ ^https?:// ]]; then
          # 提取 base URL (scheme + host)
          base_url=$(echo "$meos_url" | sed -E 's|(https?://[^/]+).*|\1|')
          if [[ "$link" =~ ^/ ]]; then
            link="${base_url}${link}"
          else
            link="${meos_url%/}/${link#./}"
          fi
        fi

        # 嘗試從 HTML 提取標題
        ESCAPED_LINK=$(echo "$link" | sed 's/[\/&]/\\&/g')
        TITLE=$(grep -oP "href=\"${ESCAPED_LINK}\"[^>]*>([^<]*)" "$TEMP_HTML" 2>/dev/null | \
          head -1 | sed 's/.*>//' | sed 's/^[[:space:]]*//' || echo "")

        if [[ -z "$TITLE" ]]; then
          # 從 URL 推導標題
          TITLE="ManpowerGroup Report — $(echo "$link" | sed 's/.*\///;s/-/ /g;s/\?.*//;s/\.pdf$//')"
        fi

        # 判斷類型
        TYPE="quarterly_report"
        if echo "$link" | grep -qi "talent-shortage"; then
          TYPE="talent_shortage"
        elif echo "$link" | grep -qi "\.pdf"; then
          TYPE="pdf_report"
        fi

        jq -n \
          --arg source_url "$link" \
          --arg fetched "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
          --arg source "ManpowerGroup MEOS" \
          --arg title "$TITLE" \
          --arg type "$TYPE" \
          --arg origin "$meos_url" \
          '{
            source_url: $source_url,
            fetched_at: $fetched,
            source: $source,
            title: $title,
            type: $type,
            origin_page: $origin
          }' >> "$OUTPUT_FILE" 2>/dev/null
      done

    RECORD_COUNT=$(wc -l < "$OUTPUT_FILE" 2>/dev/null | tr -d ' ')
    NEW=$((RECORD_COUNT - TOTAL_RECORDS))
    TOTAL_RECORDS=$RECORD_COUNT
    echo "  ✓ 新增 $NEW 筆報告連結"
  else
    echo "  ✗ HTTP $HTTP_CODE — 頁面無法存取" >&2
  fi

  rm -f "$TEMP_HTML"
  sleep 2
done

echo ""

# === 策略 2：已知報告 URL 直接檢查 ===
echo "策略 2：檢查已知報告 URL..."

# ManpowerGroup MEOS 報告通常有固定的季度模式
CURRENT_YEAR=$(date +%Y)
CURRENT_QUARTER=$(( ($(date +%-m) - 1) / 3 + 1 ))

# 建構可能的報告 URL
KNOWN_URLS=(
  "https://go.manpowergroup.com/meos"
  "https://go.manpowergroup.com/talent-shortage"
  "https://www.manpowergroup.com/workforce-insights/world-of-work/employment-outlook-survey"
)

# 嘗試近幾季的報告
for q in $(seq "$CURRENT_QUARTER" -1 1) $(seq 4 -1 "$((CURRENT_QUARTER + 1))"); do
  year=$CURRENT_YEAR
  if [[ "$q" -gt "$CURRENT_QUARTER" ]]; then
    year=$((CURRENT_YEAR - 1))
  fi

  # ManpowerGroup 報告 URL 模式（可能的變體）
  QUARTERLY_URLS=(
    "https://go.manpowergroup.com/meos-q${q}-${year}"
    "https://go.manpowergroup.com/hubfs/MEOS/MEOS_Q${q}_${year}.pdf"
    "https://www.manpowergroup.com/workforce-insights/world-of-work/employment-outlook-survey-q${q}-${year}"
  )

  for url in "${QUARTERLY_URLS[@]}"; do
    # 去重
    if [[ -s "$OUTPUT_FILE" ]] && grep -qF "$url" "$OUTPUT_FILE" 2>/dev/null; then
      continue
    fi

    HTTP_CODE=$(curl -sS -L -o /dev/null -w '%{http_code}' \
      --connect-timeout 10 --max-time 15 \
      -H "User-Agent: $UA" \
      "$url" 2>/dev/null) || HTTP_CODE="000"

    if [[ "$HTTP_CODE" == "200" ]]; then
      TYPE="quarterly_report"
      echo "$url" | grep -qi "\.pdf" && TYPE="pdf_report"

      jq -n \
        --arg source_url "$url" \
        --arg fetched "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg title "ManpowerGroup MEOS Q${q} ${year}" \
        --arg type "$TYPE" \
        --arg quarter "Q${q}" \
        --arg year "$year" \
        '{
          source_url: $source_url,
          fetched_at: $fetched,
          source: "ManpowerGroup MEOS",
          title: $title,
          type: $type,
          report_quarter: $quarter,
          report_year: ($year | tonumber)
        }' >> "$OUTPUT_FILE"
      echo "  ✓ 已確認: MEOS Q${q} ${year}"
      TOTAL_RECORDS=$((TOTAL_RECORDS + 1))
    fi

    sleep 1
  done
done

echo ""

# === 確保至少有 MEOS 主頁 ===
if [[ ! -s "$OUTPUT_FILE" ]] || [[ "$TOTAL_RECORDS" -eq 0 ]]; then
  echo "備援：至少記錄 MEOS 主頁面..."
  jq -n \
    --arg source_url "https://go.manpowergroup.com/meos" \
    --arg fetched "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{
      source_url: $source_url,
      fetched_at: $fetched,
      source: "ManpowerGroup MEOS",
      title: "ManpowerGroup Employment Outlook Survey (Main Page)",
      type: "main_page"
    }' >> "$OUTPUT_FILE"
  TOTAL_RECORDS=$((TOTAL_RECORDS + 1))
fi

# === JSONL 去重（by source_url）===
if [[ -s "$OUTPUT_FILE" ]]; then
  BEFORE=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
  DEDUPED_FILE="$RAW_DIR/temp-dedup-${TIMESTAMP}.jsonl"

  jq -c -s 'group_by(.source_url) | map(.[0])[]' "$OUTPUT_FILE" > "$DEDUPED_FILE" 2>/dev/null && \
    mv "$DEDUPED_FILE" "$OUTPUT_FILE" || rm -f "$DEDUPED_FILE"

  AFTER=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
  if [[ "$BEFORE" -ne "$AFTER" ]]; then
    echo "去重: $BEFORE → $AFTER 筆"
  fi
fi

# === 最終結果 ===
TOTAL=$(wc -l < "$OUTPUT_FILE" 2>/dev/null | tr -d ' ')
echo "=== global_manpower_outlook 資料擷取完成 ==="
echo "Fetch completed: $LAYER_NAME"
echo "Output: $OUTPUT_FILE"
echo "Lines: $TOTAL"

# 記錄最後擷取時間
date -u +%s > "$RAW_DIR/.last_fetch"
