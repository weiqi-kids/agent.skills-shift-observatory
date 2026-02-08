#!/bin/bash
# global_eurostat 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="global_eurostat"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# === 確保分類子目錄存在 ===
for category in unemployment_rate employment_rate wage_statistics; do
  mkdir -p "$DOCS_DIR/$category"
done

echo "開始更新 $LAYER_NAME 資料..."

# === Qdrant 更新（by source_url 去重）===
if [[ -n "${QDRANT_URL:-}" ]]; then
  echo "連接 Qdrant..."
  if qdrant_init_env; then
    echo "Qdrant 連線成功"

    # 收集所有 .md 檔案
    MD_FILES=()
    while IFS= read -r -d '' file; do
      MD_FILES+=("$file")
    done < <(find "$DOCS_DIR" -name "*.md" -type f -print0 2>/dev/null)

    if [[ ${#MD_FILES[@]} -gt 0 ]]; then
      echo "找到 ${#MD_FILES[@]} 個 Markdown 檔案"

      # 批次處理：每 10 個檔案一組
      BATCH_SIZE=10
      for ((i=0; i<${#MD_FILES[@]}; i+=BATCH_SIZE)); do
        batch=("${MD_FILES[@]:i:BATCH_SIZE}")
        echo "處理批次 $((i/BATCH_SIZE + 1))（${#batch[@]} 個檔案）..."

        for md_file in "${batch[@]}"; do
          # 提取 front matter 的 source_url
          source_url=$(sed -n '/^---$/,/^---$/p' "$md_file" | grep '^source_url:' | sed 's/source_url: *"\?\([^"]*\)"\?/\1/' || echo "")

          if [[ -z "$source_url" ]]; then
            echo "警告：$md_file 缺少 source_url，跳過" >&2
            continue
          fi

          # 檢查是否已存在
          if qdrant_point_exists_by_source_url "$source_url"; then
            echo "已存在：$source_url（跳過）"
            continue
          fi

          # 讀取完整內容
          content=$(cat "$md_file")

          # 提取 metadata
          title=$(echo "$content" | sed -n '/^---$/,/^---$/p' | grep '^title:' | sed 's/title: *"\?\([^"]*\)"\?/\1/' || echo "")
          date=$(echo "$content" | sed -n '/^---$/,/^---$/p' | grep '^date:' | sed 's/date: *//' || echo "")
          category=$(echo "$content" | sed -n '/^---$/,/^---$/p' | grep '^category:' | sed 's/category: *//' || echo "")
          geo_code=$(echo "$content" | sed -n '/^---$/,/^---$/p' | grep '^geo_code:' | sed 's/geo_code: *"\?\([^"]*\)"\?/\1/' || echo "")
          time_period=$(echo "$content" | sed -n '/^---$/,/^---$/p' | grep '^time_period:' | sed 's/time_period: *"\?\([^"]*\)"\?/\1/' || echo "")

          # 寫入 Qdrant
          if qdrant_upsert_point "$source_url" "$content" "$LAYER_NAME" "$title" "$date" "$category" ""; then
            echo "已寫入：$source_url"
          else
            echo "錯誤：寫入 Qdrant 失敗（$source_url）" >&2
          fi
        done

        # 批次間延遲，避免過載
        sleep 1
      done
    else
      echo "未找到任何 Markdown 檔案"
    fi
  else
    echo "警告：Qdrant 連線失敗，跳過向量資料庫更新" >&2
  fi
else
  echo "警告：QDRANT_URL 未設定，跳過向量資料庫更新" >&2
fi

# === REVIEW_NEEDED 檢查 ===
echo "檢查 REVIEW_NEEDED 標記..."
REVIEW_FILES=""
REVIEW_COUNT=0

while IFS= read -r -d '' file; do
  if grep -q "\[REVIEW_NEEDED\]" "$file" 2>/dev/null; then
    REVIEW_FILES+="  - $(basename "$file")\n"
    ((REVIEW_COUNT++))
  fi
done < <(find "$DOCS_DIR" -name "*.md" -type f -print0 2>/dev/null)

if [[ -n "$REVIEW_FILES" ]]; then
  echo "發現 $REVIEW_COUNT 個需要審核的檔案："
  echo -e "$REVIEW_FILES"

  # 嘗試建立 GitHub Issue（若 gh CLI 可用）
  if command -v gh >/dev/null 2>&1; then
    gh issue create \
      --title "[Extractor] $LAYER_NAME - 需要人工審核 ($REVIEW_COUNT 個檔案)" \
      --label "review-needed" \
      --body "偵測到 [REVIEW_NEEDED] 標記，請檢查以下檔案：

$REVIEW_FILES

**Layer**: $LAYER_NAME
**檢查時間**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" 2>/dev/null && echo "已建立 GitHub Issue" || echo "GitHub Issue 建立失敗" >&2
  else
    echo "gh CLI 不可用，無法自動建立 Issue" >&2
  fi
else
  echo "未發現需要審核的檔案"
fi

# === 統計資訊 ===
echo ""
echo "=== 更新統計 ==="
echo "Layer: $LAYER_NAME"
echo "文檔總數: $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null | wc -l)"
echo "需審核: $REVIEW_COUNT"
echo "分類分佈:"
for category in unemployment_rate employment_rate wage_statistics; do
  count=$(find "$DOCS_DIR/$category" -name "*.md" -type f 2>/dev/null | wc -l || echo 0)
  echo "  - $category: $count"
done

echo ""
echo "Update completed: $LAYER_NAME"
