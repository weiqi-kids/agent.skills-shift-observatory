#!/bin/bash
# global_hays_salary 資料擷取腳本
# 職責：從 Hays 各區域網站擷取薪資指南報告元數據

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

require_cmd curl
require_cmd jq

LAYER_NAME="global_hays_salary"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$RAW_DIR/hays-${TIMESTAMP}.jsonl"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

echo "=== global_hays_salary 資料擷取開始 ==="
echo "時間戳: $TIMESTAMP"
echo ""

TOTAL_RECORDS=0

# Hays 各區域薪資指南頁面（使用平行陣列，相容 bash 3.2）
REGION_NAMES=("global" "australia" "uk" "germany" "singapore" "hong-kong" "china" "japan" "canada" "new-zealand")
REGION_URLS=("https://www.hays.com/salary-guide" "https://www.hays.com.au/salary-guide" "https://www.hays.co.uk/salary-guide" "https://www.hays.de/personaldienstleistung/gehaltsstudie" "https://www.hays.com.sg/salary-guide" "https://www.hays.com.hk/salary-guide" "https://www.hays.cn/salary-guide" "https://www.hays.co.jp/salary-guide" "https://www.hays.ca/salary-guide" "https://www.hays.net.nz/salary-guide")

# === 策略 1：逐區域爬取薪資指南頁面 ===
echo "策略 1：逐區域爬取 Hays 薪資指南頁面..."

for i in $(seq 0 $((${#REGION_NAMES[@]} - 1))); do
  region="${REGION_NAMES[$i]}"
  url="${REGION_URLS[$i]}"
  echo ""
  echo "  區域: $region ($url)"

  TEMP_HTML="$RAW_DIR/temp-hays-${region}-${TIMESTAMP}.html"

  HTTP_CODE=$(curl -sS -L \
    -H "User-Agent: $UA" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9" \
    -H "Accept-Language: en-US,en;q=0.9" \
    --connect-timeout 15 \
    --max-time 30 \
    -w '%{http_code}' \
    -o "$TEMP_HTML" \
    "$url" 2>/dev/null) || HTTP_CODE="000"

  if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_HTML" ]]; then
    echo "  ✓ 頁面已下載"

    REGION_RECORDS=0

    # 提取 PDF 下載連結和薪資指南子頁面
    # 搜尋模式：salary-guide、gehaltsstudie、.pdf、report、download
    grep -oE 'href="[^"]*"' "$TEMP_HTML" 2>/dev/null | \
      sed 's/href="//;s/"$//' | \
      grep -iE '(salary.guide|gehaltsstudie|salary.report|\.pdf|download|wage|pay|compensation)' | \
      grep -vE '(\.css|\.js|\.png|\.jpg|\.svg|\.ico|#$|javascript:|mailto:)' | \
      sort -u | \
      while IFS= read -r link; do
        # 處理相對路徑
        if [[ ! "$link" =~ ^https?:// ]]; then
          base_url=$(echo "$url" | sed -E 's|(https?://[^/]+).*|\1|')
          if [[ "$link" =~ ^/ ]]; then
            link="${base_url}${link}"
          else
            link="${url%/}/${link#./}"
          fi
        fi

        # 判斷連結類型
        TYPE="salary_guide"
        if echo "$link" | grep -qi "\.pdf"; then
          TYPE="pdf_download"
        elif echo "$link" | grep -qi "download"; then
          TYPE="download_page"
        fi

        # 嘗試從 HTML 提取標題
        ESCAPED_LINK=$(echo "$link" | sed 's/[\/&]/\\&/g')
        TITLE=$(grep -oP "href=\"${ESCAPED_LINK}\"[^>]*>([^<]*)" "$TEMP_HTML" 2>/dev/null | \
          head -1 | sed 's/.*>//' | sed 's/^[[:space:]]*//' || echo "")

        if [[ -z "$TITLE" ]]; then
          TITLE="Hays Salary Guide — ${region}"
        fi

        jq -n \
          --arg source_url "$link" \
          --arg fetched "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
          --arg region "$region" \
          --arg source "Hays Salary Guide" \
          --arg title "$TITLE" \
          --arg type "$TYPE" \
          --arg origin "$url" \
          '{
            source_url: $source_url,
            fetched_at: $fetched,
            region: $region,
            source: $source,
            title: $title,
            type: $type,
            origin_page: $origin
          }' >> "$OUTPUT_FILE" 2>/dev/null

        REGION_RECORDS=$((REGION_RECORDS + 1))
      done

    # 如果沒找到子連結，至少記錄主頁
    if [[ "$REGION_RECORDS" -eq 0 ]]; then
      jq -n \
        --arg source_url "$url" \
        --arg fetched "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg region "$region" \
        --arg source "Hays Salary Guide" \
        --arg title "Hays Salary Guide — ${region}" \
        '{
          source_url: $source_url,
          fetched_at: $fetched,
          region: $region,
          source: $source,
          title: $title,
          type: "main_page",
          origin_page: $source_url
        }' >> "$OUTPUT_FILE"
      echo "  ⚠ 未找到子連結，已記錄主頁"
    fi

    RECORD_COUNT=$(wc -l < "$OUTPUT_FILE" 2>/dev/null | tr -d ' ')
    NEW=$((RECORD_COUNT - TOTAL_RECORDS))
    TOTAL_RECORDS=$RECORD_COUNT
    echo "  ✓ $region: 新增 $NEW 筆"
  else
    echo "  ✗ HTTP $HTTP_CODE — 頁面無法存取" >&2

    # 仍記錄此區域以便後續 WebFetch 嘗試
    jq -n \
      --arg source_url "$url" \
      --arg fetched "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg region "$region" \
      --arg source "Hays Salary Guide" \
      --arg title "Hays Salary Guide — ${region} (fetch failed)" \
      '{
        source_url: $source_url,
        fetched_at: $fetched,
        region: $region,
        source: $source,
        title: $title,
        type: "main_page",
        fetch_status: "failed",
        origin_page: $source_url
      }' >> "$OUTPUT_FILE"
    TOTAL_RECORDS=$((TOTAL_RECORDS + 1))
  fi

  rm -f "$TEMP_HTML"
  sleep 2
done

echo ""

# === 策略 2：Hays 全球報告固定 URL ===
echo "策略 2：檢查 Hays 全球報告..."

CURRENT_YEAR=$(date +%Y)
HAYS_GLOBAL_URLS=(
  "https://www.hays.com/salary-guide/${CURRENT_YEAR}"
  "https://www.hays.com/salary-guide/$((CURRENT_YEAR - 1))"
  "https://www.hays.com/insights/salary-guide"
  "https://www.hays.com/research/salary-guide"
)

for url in "${HAYS_GLOBAL_URLS[@]}"; do
  # 去重
  if [[ -s "$OUTPUT_FILE" ]] && grep -qF "$url" "$OUTPUT_FILE" 2>/dev/null; then
    continue
  fi

  HTTP_CODE=$(curl -sS -L -o /dev/null -w '%{http_code}' \
    --connect-timeout 10 --max-time 15 \
    -H "User-Agent: $UA" \
    "$url" 2>/dev/null) || HTTP_CODE="000"

  if [[ "$HTTP_CODE" == "200" ]]; then
    jq -n \
      --arg source_url "$url" \
      --arg fetched "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg title "Hays Global Salary Guide" \
      '{
        source_url: $source_url,
        fetched_at: $fetched,
        region: "global",
        source: "Hays Salary Guide",
        title: $title,
        type: "global_report",
        origin_page: $source_url
      }' >> "$OUTPUT_FILE"
    echo "  ✓ 已確認: $url"
    TOTAL_RECORDS=$((TOTAL_RECORDS + 1))
  fi

  sleep 1
done

echo ""

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
echo "=== global_hays_salary 資料擷取完成 ==="
echo "Fetch completed: $LAYER_NAME"
echo "Output: $OUTPUT_FILE"
echo "Lines: $TOTAL"

# 記錄最後擷取時間
date -u +%s > "$RAW_DIR/.last_fetch"
