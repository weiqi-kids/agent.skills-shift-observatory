#!/bin/bash
# global_stackoverflow 資料擷取腳本
# 職責：從 Stack Overflow Developer Survey 擷取公開資料集摘要與結果頁面

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

require_cmd curl
require_cmd jq

LAYER_NAME="global_stackoverflow"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$RAW_DIR/stackoverflow-survey-${TIMESTAMP}.jsonl"

echo "=== global_stackoverflow 資料擷取開始 ==="
echo "時間戳: $TIMESTAMP"
echo ""

TOTAL_RECORDS=0
CURRENT_YEAR=$(date +%Y)

# === 策略 1：爬取 Survey 結果頁面 ===
echo "策略 1：爬取 Stack Overflow Survey 結果頁面..."

# 嘗試最近幾年的 survey 頁面
SURVEY_YEARS=()
for y in $(seq "$CURRENT_YEAR" -1 $((CURRENT_YEAR - 3))); do
  SURVEY_YEARS+=("$y")
done

for year in "${SURVEY_YEARS[@]}"; do
  echo "  檢查 ${year} 年度調查..."

  SURVEY_URL="https://survey.stackoverflow.co/${year}/"
  TEMP_HTML="$RAW_DIR/temp-so-${year}-${TIMESTAMP}.html"

  HTTP_CODE=$(curl -sS -L \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    -H "Accept: text/html" \
    --connect-timeout 15 \
    --max-time 30 \
    -w '%{http_code}' \
    -o "$TEMP_HTML" \
    "$SURVEY_URL" 2>/dev/null) || HTTP_CODE="000"

  if [[ "$HTTP_CODE" == "200" ]] && [[ -s "$TEMP_HTML" ]]; then
    echo "  ✓ ${year} 調查頁面可達"

    # 從 HTML 提取各節（sections）的連結
    # Stack Overflow survey 頁面通常有 #technology, #salary, #work 等區段
    SECTIONS=$(grep -oE 'href="(/'"${year}"'/[^"]*)"' "$TEMP_HTML" 2>/dev/null | \
      sed 's/href="//;s/"$//' | \
      sort -u || true)

    # 也提取 anchor links（如 #technology-most-popular-technologies）
    ANCHORS=$(grep -oE 'href="#([^"]+)"' "$TEMP_HTML" 2>/dev/null | \
      sed 's/href="#//;s/"$//' | \
      grep -iE 'technology|salary|work|developer|learn|ai|tool' | \
      sort -u || true)

    # 建立主頁面記錄
    jq -n \
      --arg year "$year" \
      --arg link "$SURVEY_URL" \
      --arg title "Stack Overflow Annual Developer Survey ${year}" \
      '{
        survey_year: ($year | tonumber),
        question: "Survey Overview",
        response: "",
        percentage: "",
        sample_size: null,
        link: $link,
        title: $title,
        section: "overview",
        category_hint: "developer_profile"
      }' >> "$OUTPUT_FILE"

    # 為每個主要區段建立記錄
    SECTION_MAPPINGS=(
      "technology:language_framework:Programming languages, frameworks, and tools usage"
      "salary:salary_survey:Developer compensation and salary distribution"
      "work:work_satisfaction:Work environment, satisfaction, and preferences"
      "developer-profile:developer_profile:Developer demographics, experience, and education"
      "ai:language_framework:AI tools usage and attitudes"
      "learning:learning_path:Learning resources and education paths"
    )

    for mapping in "${SECTION_MAPPINGS[@]}"; do
      IFS=':' read -r section_key category description <<< "$mapping"

      # 檢查此區段是否存在於頁面中
      if echo "$ANCHORS $SECTIONS" | grep -qi "$section_key" 2>/dev/null; then
        SECTION_URL="${SURVEY_URL}#${section_key}"

        jq -n \
          --arg year "$year" \
          --arg link "$SECTION_URL" \
          --arg title "Stack Overflow ${year} — ${description}" \
          --arg section "$section_key" \
          --arg category "$category" \
          --arg desc "$description" \
          '{
            survey_year: ($year | tonumber),
            question: $desc,
            response: "",
            percentage: "",
            sample_size: null,
            link: $link,
            title: $title,
            section: $section,
            category_hint: $category
          }' >> "$OUTPUT_FILE"
      fi
    done

    RECORD_COUNT=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
    NEW=$((RECORD_COUNT - TOTAL_RECORDS))
    TOTAL_RECORDS=$RECORD_COUNT
    echo "  ✓ ${year}: 新增 $NEW 筆區段記錄"
  else
    echo "  ✗ ${year} 調查頁面不可達 (HTTP $HTTP_CODE)" >&2
  fi

  rm -f "$TEMP_HTML"
  sleep 2
done

echo ""

# === 策略 2：檢查 CSV 資料集下載連結 ===
echo "策略 2：檢查 CSV 資料集可用性..."

for year in "${SURVEY_YEARS[@]}"; do
  # Stack Overflow 公開資料集通常在這個路徑
  CSV_URLS=(
    "https://cdn.stackoverflow.co/files/jo7n4k8s/production/${year}-developer-survey-results.zip"
    "https://info.stackoverflowsolutions.com/rs/719-EMH-566/images/stack-overflow-developer-survey-${year}.zip"
  )

  for csv_url in "${CSV_URLS[@]}"; do
    HTTP_CODE=$(curl -sS -L -o /dev/null -w '%{http_code}' \
      --connect-timeout 10 --max-time 15 \
      -H "User-Agent: SkillsShiftObservatory/1.0" \
      "$csv_url" 2>/dev/null) || HTTP_CODE="000"

    if [[ "$HTTP_CODE" == "200" ]]; then
      echo "  ✓ ${year} CSV 資料集可下載: $csv_url"

      # 記錄 CSV 下載連結
      jq -n \
        --arg year "$year" \
        --arg link "$csv_url" \
        --arg title "Stack Overflow ${year} Survey Raw Dataset (CSV)" \
        '{
          survey_year: ($year | tonumber),
          question: "Raw Dataset Download",
          response: "CSV dataset available for download",
          percentage: "",
          sample_size: null,
          link: $link,
          title: $title,
          section: "dataset",
          category_hint: "developer_profile"
        }' >> "$OUTPUT_FILE"

      TOTAL_RECORDS=$((TOTAL_RECORDS + 1))
      break  # 找到一個可用的就夠了
    fi
  done
done

echo ""

# === 策略 3：Stack Overflow Blog RSS（補充）===
echo "策略 3：檢查 Stack Overflow Blog..."

SO_BLOG_URL="https://stackoverflow.blog/feed/"
TEMP_XML="$RAW_DIR/temp-so-blog-${TIMESTAMP}.xml"

if rss_fetch "$SO_BLOG_URL" "$TEMP_XML" 2>/dev/null; then
  TEMP_JSONL="$RAW_DIR/temp-so-blog-${TIMESTAMP}.jsonl"
  rss_extract_items_jsonl "$TEMP_XML" > "$TEMP_JSONL" 2>/dev/null || true

  if [[ -s "$TEMP_JSONL" ]]; then
    # 過濾 developer survey 或技能/薪資相關文章
    jq -c 'select(
      (.title | ascii_downcase | test("survey|developer survey|salary|skills|hiring|workforce|career"))
    ) | {
      survey_year: null,
      question: .title,
      response: .description,
      percentage: "",
      sample_size: null,
      link: .link,
      title: .title,
      section: "blog",
      category_hint: "developer_profile"
    }' "$TEMP_JSONL" >> "$OUTPUT_FILE" 2>/dev/null || true

    RECORD_COUNT=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
    NEW=$((RECORD_COUNT - TOTAL_RECORDS))
    TOTAL_RECORDS=$RECORD_COUNT
    echo "  ✓ Blog RSS: 新增 $NEW 筆相關文章"
  fi

  rm -f "$TEMP_JSONL"
fi

rm -f "$TEMP_XML"

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
  echo "=== global_stackoverflow 資料擷取完成 ==="
  echo "Fetch completed: $LAYER_NAME"
  echo "Output: $OUTPUT_FILE"
  echo "Records: $TOTAL"
else
  echo "=== global_stackoverflow 資料擷取完成（無資料）==="
  echo "警告：未擷取到任何資料。Stack Overflow Survey 通常於每年 5 月發布。"
  touch "$OUTPUT_FILE"
fi

# 記錄最後擷取時間
date -u +%s > "$RAW_DIR/.last_fetch"
