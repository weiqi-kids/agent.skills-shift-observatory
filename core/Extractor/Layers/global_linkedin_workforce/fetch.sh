#!/bin/bash
# global_linkedin_workforce 資料擷取腳本
# 職責：從 LinkedIn Economic Graph 與 Workforce Reports 擷取公開報告

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/rss.sh"

require_cmd curl
require_cmd jq

LAYER_NAME="global_linkedin_workforce"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$RAW_DIR/linkedin-${TIMESTAMP}.jsonl"

echo "=== global_linkedin_workforce 資料擷取開始 ==="
echo "時間戳: $TIMESTAMP"
echo ""

TOTAL_RECORDS=0

# LinkedIn 公開報告與部落格來源
# 注意：LinkedIn 可能封鎖爬蟲，需要 User-Agent 偽裝
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# === 策略 1：LinkedIn Economic Graph Blog ===
echo "策略 1：爬取 LinkedIn Economic Graph Blog..."

LINKEDIN_PAGES=(
  "https://economicgraph.linkedin.com/blog"
  "https://economicgraph.linkedin.com/research"
  "https://economicgraph.linkedin.com/resources/linkedin-workforce-report"
  "https://www.linkedin.com/business/talent/blog/talent-strategy"
  "https://www.linkedin.com/pulse/topics/workforce-and-economy/"
)

# 就業/勞動力相關關鍵字（用於 URL 和標題過濾）
KEYWORDS="workforce|talent|hiring|employment|skill|labor|labour|remote-work|future-of-work|job-market|economic-graph|salary|wage|career"

for page_url in "${LINKEDIN_PAGES[@]}"; do
  echo "  頁面: $page_url"
  TEMP_HTML="$RAW_DIR/temp-li-${TIMESTAMP}.html"

  HTTP_CODE=$(curl -sS -L \
    -H "User-Agent: $UA" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9" \
    -H "Accept-Language: en-US,en;q=0.9" \
    --connect-timeout 15 \
    --max-time 30 \
    -w '%{http_code}' \
    -o "$TEMP_HTML" \
    "$page_url" 2>/dev/null) || HTTP_CODE="000"

  if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_HTML" ]]; then
    # 提取所有連結
    grep -oE 'href="(https?://[^"]*)"' "$TEMP_HTML" 2>/dev/null | \
      sed 's/href="//;s/"$//' | \
      sort -u | \
      while IFS= read -r link; do
        # 過濾：僅保留 LinkedIn 域名下的就業相關連結
        if echo "$link" | grep -qE '(linkedin\.com|economicgraph\.linkedin\.com)' && \
           echo "$link" | grep -iqE "$KEYWORDS"; then

          # 排除登入頁、個人檔案頁、通用頁面
          if echo "$link" | grep -qE '(login|signup|mynetwork|messaging|notifications|feed$|jobs/view)'; then
            continue
          fi

          # 嘗試從 HTML 提取該連結的 anchor text 作為標題
          TITLE=$(grep -oP "href=\"$(echo "$link" | sed 's/[\/&]/\\&/g')\"[^>]*>([^<]*)" "$TEMP_HTML" 2>/dev/null | \
            head -1 | sed 's/.*>//' | sed 's/^[[:space:]]*//' || echo "")

          if [[ -z "$TITLE" ]]; then
            # 從 URL 推導標題
            TITLE=$(echo "$link" | sed 's/.*\///;s/-/ /g;s/\?.*//;s/\.html$//' | \
              awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
          fi

          jq -n \
            --arg title "$TITLE" \
            --arg link "$link" \
            --arg description "" \
            --arg pubDate "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            --arg source "$page_url" \
            '{
              title: $title,
              link: $link,
              description: $description,
              pubDate: $pubDate,
              source: $source
            }' >> "$OUTPUT_FILE" 2>/dev/null
        fi
      done

    RECORD_COUNT=$(wc -l < "$OUTPUT_FILE" 2>/dev/null | tr -d ' ')
    NEW=$((RECORD_COUNT - TOTAL_RECORDS))
    TOTAL_RECORDS=$RECORD_COUNT
    echo "  ✓ 新增 $NEW 筆連結"
  else
    echo "  ✗ HTTP $HTTP_CODE — 頁面無法存取（LinkedIn 可能封鎖爬蟲）" >&2
  fi

  rm -f "$TEMP_HTML"
  sleep 3  # LinkedIn 較嚴格，間隔稍長
done

echo ""

# === 策略 2：RSS feed（若可用）===
echo "策略 2：嘗試 LinkedIn RSS feed..."

LINKEDIN_RSS_URLS=(
  "https://economicgraph.linkedin.com/blog/feed"
  "https://www.linkedin.com/blog/feed"
)

for rss_url in "${LINKEDIN_RSS_URLS[@]}"; do
  echo "  來源: $rss_url"
  XML_FILE="$RAW_DIR/temp-li-rss-${TIMESTAMP}.xml"

  if rss_fetch "$rss_url" "$XML_FILE" 2>/dev/null; then
    TEMP_JSONL="$RAW_DIR/temp-li-rss-${TIMESTAMP}.jsonl"
    rss_extract_items_jsonl "$XML_FILE" > "$TEMP_JSONL" 2>/dev/null || true

    if [[ -s "$TEMP_JSONL" ]]; then
      # 過濾就業相關項目
      jq -c "select(
        (.title | ascii_downcase | test(\"$KEYWORDS\")) or
        (.description | ascii_downcase | test(\"$KEYWORDS\"))
      ) | . + {source: \"linkedin_rss\"}" "$TEMP_JSONL" >> "$OUTPUT_FILE" 2>/dev/null || true

      RECORD_COUNT=$(wc -l < "$OUTPUT_FILE" 2>/dev/null | tr -d ' ')
      NEW=$((RECORD_COUNT - TOTAL_RECORDS))
      TOTAL_RECORDS=$RECORD_COUNT
      echo "  ✓ RSS: 新增 $NEW 筆"
    fi

    rm -f "$TEMP_JSONL"
  else
    echo "  ✗ RSS 不可用: $rss_url" >&2
  fi

  rm -f "$XML_FILE"
done

echo ""

# === 策略 3：已知報告固定 URL ===
echo "策略 3：檢查已知報告 URL..."

KNOWN_TITLES=(
  "LinkedIn Workforce Report 2025"
  "LinkedIn Global Talent Trends"
  "LinkedIn Economic Graph Overview"
  "LinkedIn Skills on the Rise"
  "LinkedIn Future of Work Report"
)
KNOWN_URLS_LIST=(
  "https://economicgraph.linkedin.com/resources/linkedin-workforce-report"
  "https://business.linkedin.com/talent-solutions/global-talent-trends"
  "https://economicgraph.linkedin.com/"
  "https://www.linkedin.com/business/talent/blog/talent-strategy/linkedin-skills-on-the-rise"
  "https://economicgraph.linkedin.com/research/future-of-work"
)

for i in $(seq 0 $((${#KNOWN_TITLES[@]} - 1))); do
  title="${KNOWN_TITLES[$i]}"
  url="${KNOWN_URLS_LIST[$i]}"

  # 去重
  if [[ -s "$OUTPUT_FILE" ]] && grep -qF "$url" "$OUTPUT_FILE" 2>/dev/null; then
    echo "  已存在，跳過: $title"
    continue
  fi

  HTTP_CODE=$(curl -sS -L -o /dev/null -w '%{http_code}' \
    --connect-timeout 10 --max-time 15 \
    -H "User-Agent: $UA" \
    "$url" 2>/dev/null) || HTTP_CODE="000"

  if [[ "$HTTP_CODE" == "200" ]]; then
    jq -n \
      --arg title "$title" \
      --arg link "$url" \
      --arg source "known_report" \
      '{
        title: $title,
        link: $link,
        description: "",
        pubDate: "",
        source: $source
      }' >> "$OUTPUT_FILE"
    echo "  ✓ 已確認: $title"
    TOTAL_RECORDS=$((TOTAL_RECORDS + 1))
  else
    echo "  ✗ HTTP $HTTP_CODE: $title" >&2
  fi

  sleep 1
done

echo ""

# === JSONL 去重（by link）===
if [[ -s "$OUTPUT_FILE" ]]; then
  BEFORE=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
  DEDUPED_FILE="$RAW_DIR/temp-dedup-${TIMESTAMP}.jsonl"

  jq -c -s 'group_by(.link) | map(.[0])[]' "$OUTPUT_FILE" > "$DEDUPED_FILE" 2>/dev/null && \
    mv "$DEDUPED_FILE" "$OUTPUT_FILE" || rm -f "$DEDUPED_FILE"

  AFTER=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
  if [[ "$BEFORE" -ne "$AFTER" ]]; then
    echo "去重: $BEFORE → $AFTER 筆"
  fi
fi

# === 最終結果 ===
if [[ -s "$OUTPUT_FILE" ]]; then
  TOTAL=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
  echo "=== global_linkedin_workforce 資料擷取完成 ==="
  echo "Fetch completed: $LAYER_NAME"
  echo "Items: $TOTAL"
  echo "Output: $OUTPUT_FILE"
else
  echo "=== global_linkedin_workforce 資料擷取完成（無資料）==="
  echo "警告：未擷取到任何 LinkedIn 報告。"
  echo "LinkedIn 經常封鎖自動存取。建議："
  echo "  1. 手動瀏覽 https://economicgraph.linkedin.com/ 收集報告 URL"
  echo "  2. 手動新增 JSONL 記錄到 $RAW_DIR/"
  touch "$OUTPUT_FILE"
fi

# 記錄最後擷取時間
date -u +%s > "$RAW_DIR/.last_fetch"
