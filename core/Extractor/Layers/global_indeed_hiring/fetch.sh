#!/bin/bash
# global_indeed_hiring 資料擷取腳本
# 職責：從 Indeed Hiring Lab RSS feed 擷取報告

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/rss.sh"

LAYER_NAME="global_indeed_hiring"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
XML_FILE="$RAW_DIR/rss-${TIMESTAMP}.xml"
JSONL_FILE="$RAW_DIR/rss-${TIMESTAMP}.jsonl"

# Indeed Hiring Lab RSS feed URL
RSS_URL="https://www.hiringlab.org/feed/"

echo "Fetching Indeed Hiring Lab RSS feed..."

# 使用 lib/rss.sh 函式下載 RSS
if rss_fetch "$RSS_URL" "$XML_FILE"; then
  echo "RSS feed downloaded successfully"

  # 轉換為 JSONL 格式
  rss_extract_items_jsonl "$XML_FILE" > "$JSONL_FILE"

  ITEM_COUNT=$(wc -l < "$JSONL_FILE" | tr -d ' ')
  echo "Fetch completed: $LAYER_NAME"
  echo "Items: $ITEM_COUNT"
  echo "Output: $JSONL_FILE"
else
  echo "Error: Failed to fetch RSS feed from $RSS_URL" >&2
  exit 1
fi
