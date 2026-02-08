#!/bin/bash
# global_abs 資料擷取腳本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/core.sh" 2>/dev/null || true

LAYER_NAME="global_abs"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$RAW_DIR"

echo "=== $LAYER_NAME 資料擷取 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "資料來源: Australian Bureau of Statistics (ABS) Data API"

# ABS API 端點
BASE_URL="https://api.data.abs.gov.au/data"

# 輸出檔案
OUTPUT_FILE="$RAW_DIR/abs-${TIMESTAMP}.jsonl"

# 擷取勞動力調查數據
echo "擷取勞動力調查數據..."

# 簡化查詢：取得最近的勞動力數據
curl -s "${BASE_URL}/ABS,LF,1.0.0/M2+M3.1+3.1599.10+20.M?startPeriod=2024-01&format=jsondata" \
  -H "Accept: application/vnd.sdmx.data+json;version=1.0.0" \
  -o "$RAW_DIR/lf-raw-${TIMESTAMP}.json" 2>/dev/null || {
    echo "警告: 勞動力調查 API 呼叫失敗，嘗試備用端點..."
    
    # 備用：使用更簡單的查詢
    curl -s "https://api.data.abs.gov.au/data/LF/all" \
      -H "Accept: application/json" \
      -o "$RAW_DIR/lf-raw-${TIMESTAMP}.json" 2>/dev/null || {
        echo "錯誤: 無法連接 ABS API"
        echo "可能原因: API 端點變更或網路問題"
        echo "建議: 手動下載 CSV 並放入 $RAW_DIR/"
      }
  }

# 檢查是否取得資料
if [[ -f "$RAW_DIR/lf-raw-${TIMESTAMP}.json" ]]; then
  file_size=$(stat -f%z "$RAW_DIR/lf-raw-${TIMESTAMP}.json" 2>/dev/null || stat -c%s "$RAW_DIR/lf-raw-${TIMESTAMP}.json" 2>/dev/null || echo 0)
  
  if [[ $file_size -gt 100 ]]; then
    echo "  ✓ 取得資料 (${file_size} bytes)"
    
    # 轉換為 JSONL（簡化處理）
    # ABS SDMX-JSON 格式較複雜，這裡只提取基本結構
    jq -c '{
      source: "abs_labour_force",
      fetched_at: now | strftime("%Y-%m-%dT%H:%M:%SZ"),
      raw_file: input_filename
    }' "$RAW_DIR/lf-raw-${TIMESTAMP}.json" > "$OUTPUT_FILE" 2>/dev/null || {
      echo '{"source":"abs_labour_force","status":"raw_data_saved"}' > "$OUTPUT_FILE"
    }
    
    echo "  輸出: $OUTPUT_FILE"
  else
    echo "  ⚠ 資料檔案過小，可能為錯誤回應"
  fi
fi

# 記錄最後擷取時間
echo "$(date -Iseconds)" > "$RAW_DIR/.last_fetch"

echo ""
echo "=== 擷取完成 ==="
echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
