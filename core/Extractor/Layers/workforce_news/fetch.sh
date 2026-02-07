#!/bin/bash
# workforce_news 資料擷取腳本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/rss.sh"

LAYER_NAME="workforce_news"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# RSS feeds to fetch（使用平行陣列，相容 bash 3.2）
FEED_NAMES=("techcrunch" "reuters_business")
FEED_URLS=("https://techcrunch.com/tag/layoffs/feed/" "https://www.reutersagency.com/feed/?best-topics=business-finance")

echo "=== workforce_news 資料擷取開始 ==="
echo "時間戳: $TIMESTAMP"
echo ""

for i in $(seq 0 $((${#FEED_NAMES[@]} - 1))); do
  feed_name="${FEED_NAMES[$i]}"
  feed_url="${FEED_URLS[$i]}"
  xml_file="$RAW_DIR/rss-${feed_name}-${TIMESTAMP}.xml"
  jsonl_file="$RAW_DIR/rss-${feed_name}-${TIMESTAMP}.jsonl"

  echo "正在擷取: $feed_name"
  echo "  來源: $feed_url"

  if rss_fetch "$feed_url" "$xml_file"; then
    echo "  XML 已下載: $xml_file"

    if rss_extract_items_jsonl "$xml_file" > "$jsonl_file"; then
      item_count=$(wc -l < "$jsonl_file")
      echo "  JSONL 已產生: $jsonl_file"
      echo "  項目數: $item_count"
    else
      echo "  警告: JSONL 轉換失敗" >&2
    fi
  else
    echo "  錯誤: 無法擷取 $feed_name" >&2
  fi

  # 避免頻繁請求
  sleep 2
  echo ""
done

echo "=== workforce_news 資料擷取完成 ==="
echo "原始資料位置: $RAW_DIR"
