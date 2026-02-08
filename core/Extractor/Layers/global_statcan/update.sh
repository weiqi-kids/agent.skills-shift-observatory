#!/bin/bash
# global_statcan 資料更新腳本
# 職責: Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意: 不處理 index.json (由 GitHub Actions 產生)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="global_statcan"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# Category enum 值
CATEGORIES=(
    "labour_force"
    "employment_by_occupation"
    "unemployment"
)

# 確保分類子目錄存在
for category in "${CATEGORIES[@]}"; do
    mkdir -p "$DOCS_DIR/$category"
done

echo "=== global_statcan 資料更新 ==="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"

# 取得要更新的 .md 檔案
if [[ $# -gt 0 ]]; then
    # 從參數取得檔案清單
    MD_FILES=("$@")
else
    # 掃描所有 category 子目錄下的 .md 檔
    MD_FILES=()
    for category in "${CATEGORIES[@]}"; do
        if [[ -d "$DOCS_DIR/$category" ]]; then
            while IFS= read -r -d '' file; do
                MD_FILES+=("$file")
            done < <(find "$DOCS_DIR/$category" -name "*.md" -type f -print0 2>/dev/null)
        fi
    done
fi

TOTAL_FILES=${#MD_FILES[@]}
echo "待更新檔案數: $TOTAL_FILES"

if [[ $TOTAL_FILES -eq 0 ]]; then
    echo "沒有檔案需要更新"
    exit 0
fi

# === Qdrant 更新 ===
QDRANT_SUCCESS=0
QDRANT_FAILED=0

if [[ -n "${QDRANT_URL:-}" ]]; then
    echo ""
    echo "正在連線 Qdrant..."

    if qdrant_init_env; then
        echo "Qdrant 連線成功,開始更新向量資料庫..."

        for md_file in "${MD_FILES[@]}"; do
            # 萃取 source_url (用於去重)
            SOURCE_URL=$(grep -m1 '^source_url:' "$md_file" 2>/dev/null | sed 's/^source_url: *"\?\([^"]*\)"\?/\1/' || echo "")

            if [[ -z "$SOURCE_URL" ]]; then
                echo "  ⚠️  跳過 (無 source_url): $(basename "$md_file")" >&2
                QDRANT_FAILED=$((QDRANT_FAILED + 1))
                continue
            fi

            # 檢查是否已存在 (by source_url)
            # 這裡簡化處理,實際應透過 qdrant.sh 提供的去重函式
            # 假設 qdrant.sh 有 qdrant_upsert_markdown 函式

            if command -v qdrant_upsert_markdown >/dev/null 2>&1; then
                if qdrant_upsert_markdown "$md_file" "$LAYER_NAME"; then
                    QDRANT_SUCCESS=$((QDRANT_SUCCESS + 1))
                else
                    echo "  ✗ Qdrant 寫入失敗: $(basename "$md_file")" >&2
                    QDRANT_FAILED=$((QDRANT_FAILED + 1))
                fi
            else
                echo "  ⚠️  qdrant_upsert_markdown 函式不存在,跳過 Qdrant 更新" >&2
                break
            fi
        done

        echo ""
        echo "Qdrant 更新完成:"
        echo "  成功: $QDRANT_SUCCESS"
        echo "  失敗: $QDRANT_FAILED"
    else
        echo "Qdrant 連線失敗,跳過向量資料庫更新" >&2
    fi
else
    echo "未設定 QDRANT_URL,跳過向量資料庫更新"
fi

# === REVIEW_NEEDED 檢查 ===
echo ""
echo "正在檢查 [REVIEW_NEEDED] 標記..."

REVIEW_FILES=()
for f in "${MD_FILES[@]}"; do
    if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
        REVIEW_FILES+=("$f")
    fi
done

REVIEW_COUNT=${#REVIEW_FILES[@]}

if [[ $REVIEW_COUNT -gt 0 ]]; then
    echo ""
    echo "⚠️  發現 $REVIEW_COUNT 個需要審核的檔案:"
    for f in "${REVIEW_FILES[@]}"; do
        echo "  - $f"
    done

    # 嘗試建立 GitHub Issue (若有安裝 gh CLI)
    if command -v gh >/dev/null 2>&1; then
        ISSUE_BODY="偵測到 \`[REVIEW_NEEDED]\` 標記,請人工審核以下檔案:\n\n"
        for f in "${REVIEW_FILES[@]}"; do
            REL_PATH="${f#$PROJECT_ROOT/}"
            ISSUE_BODY+="\n- \`$REL_PATH\`"
        done
        ISSUE_BODY+="\n\n---\n自動產生時間: $(date '+%Y-%m-%d %H:%M:%S')"

        gh issue create \
            --title "[Extractor] $LAYER_NAME - 需要人工審核 ($REVIEW_COUNT 筆)" \
            --label "review-needed,extractor" \
            --body "$ISSUE_BODY" 2>/dev/null || echo "  (GitHub Issue 建立失敗或已存在)" >&2
    fi
else
    echo "✓ 無需審核的檔案"
fi

echo ""
echo "=== 更新完成 ==="
echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
