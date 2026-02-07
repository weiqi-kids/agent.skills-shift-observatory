#!/bin/bash
# global_wef_jobs 資料擷取腳本
# 職責：處理 WEF 未來就業報告（PDF 模式）
#
# 注意：WEF 網站使用 Akamai CDN 封鎖自動化存取
# 需手動下載 PDF 到 docs/Extractor/global_wef_jobs/raw/ 目錄

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

require_cmd jq

LAYER_NAME="global_wef_jobs"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$RAW_DIR/wef-jobs-${TIMESTAMP}.jsonl"

echo "=== global_wef_jobs 資料擷取開始 ==="
echo "時間戳: $TIMESTAMP"
echo ""

TOTAL_RECORDS=0

# === 已知 WEF 報告 PDF 清單 ===
declare -A KNOWN_REPORTS=(
    ["WEF_Future_of_Jobs_Report_2025.pdf"]="Future of Jobs Report 2025|https://www.weforum.org/publications/the-future-of-jobs-report-2025/|2025-01-01"
    ["WEF_Future_of_Jobs_Report_2023.pdf"]="Future of Jobs Report 2023|https://www.weforum.org/publications/the-future-of-jobs-report-2023/|2023-05-01"
    ["WEF_Jobs_of_Tomorrow_LLM.pdf"]="Jobs of Tomorrow: Large Language Models and Jobs|https://www.weforum.org/publications/jobs-of-tomorrow-large-language-models-and-jobs/|2023-09-01"
    ["WEF_Putting_Skills_First.pdf"]="Putting Skills First|https://www.weforum.org/publications/putting-skills-first-opportunities-for-building/|2024-01-01"
)

echo "=== 檢查已下載的 PDF 報告 ==="

PDF_FOUND=0
MISSING_PDFS=""

for pdf_name in "${!KNOWN_REPORTS[@]}"; do
    pdf_path="$RAW_DIR/$pdf_name"
    IFS='|' read -r title url date <<< "${KNOWN_REPORTS[$pdf_name]}"

    if [[ -f "$pdf_path" ]]; then
        echo "  ✓ 已找到: $pdf_name"
        PDF_FOUND=$((PDF_FOUND + 1))

        # 取得檔案大小與修改時間
        FILE_SIZE=$(stat -f%z "$pdf_path" 2>/dev/null || stat -c%s "$pdf_path" 2>/dev/null || echo "0")
        FILE_MTIME=$(stat -f%m "$pdf_path" 2>/dev/null || stat -c%Y "$pdf_path" 2>/dev/null || echo "0")

        # 產生 JSONL 記錄
        jq -n -c \
            --arg title "$title" \
            --arg link "$url" \
            --arg published_date "$date" \
            --arg pdf_path "$pdf_path" \
            --arg pdf_filename "$pdf_name" \
            --arg file_size "$FILE_SIZE" \
            --arg source "pdf_local" \
            --arg fetched_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            '{
                title: $title,
                link: $link,
                published_date: $published_date,
                pdf_path: $pdf_path,
                pdf_filename: $pdf_filename,
                file_size_bytes: ($file_size | tonumber),
                source: $source,
                report_edition: $title,
                fetched_at: $fetched_at,
                extraction_method: "pdf_read"
            }' >> "$OUTPUT_FILE"

        ((TOTAL_RECORDS++))
    else
        MISSING_PDFS+="  - $pdf_name\n"
        MISSING_PDFS+="    標題: $title\n"
        MISSING_PDFS+="    下載: $url\n\n"
    fi
done

echo ""

# === 掃描其他 PDF 檔案 ===
echo "=== 掃描其他 PDF 檔案 ==="

for pdf_file in "$RAW_DIR"/*.pdf; do
    [[ -e "$pdf_file" ]] || continue

    pdf_basename=$(basename "$pdf_file")

    # 跳過已處理的已知報告
    if [[ -v "KNOWN_REPORTS[$pdf_basename]" ]]; then
        continue
    fi

    echo "  ✓ 發現額外 PDF: $pdf_basename"

    FILE_SIZE=$(stat -f%z "$pdf_file" 2>/dev/null || stat -c%s "$pdf_file" 2>/dev/null || echo "0")

    jq -n -c \
        --arg title "未知 WEF 報告: $pdf_basename" \
        --arg pdf_path "$pdf_file" \
        --arg pdf_filename "$pdf_basename" \
        --arg file_size "$FILE_SIZE" \
        --arg source "pdf_local" \
        --arg fetched_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            title: $title,
            link: "",
            published_date: "",
            pdf_path: $pdf_path,
            pdf_filename: $pdf_filename,
            file_size_bytes: ($file_size | tonumber),
            source: $source,
            report_edition: "unknown",
            fetched_at: $fetched_at,
            extraction_method: "pdf_read"
        }' >> "$OUTPUT_FILE"

    ((TOTAL_RECORDS++))
    ((PDF_FOUND++))
done

echo ""

# === 最終結果 ===
echo "=== global_wef_jobs 資料擷取完成 ==="

if [[ $PDF_FOUND -gt 0 ]]; then
    echo "找到 PDF 報告: $PDF_FOUND 份"
    echo "輸出 JSONL: $OUTPUT_FILE"
    echo "記錄數: $TOTAL_RECORDS"
    echo ""
    echo "Fetch completed: $LAYER_NAME"

    # 記錄最後擷取時間
    date -u +%s > "$RAW_DIR/.last_fetch"
else
    echo "⚠️  未找到任何 PDF 報告"
    echo ""
    echo "=== 需要手動下載 ==="
    echo ""
    echo "WEF 網站使用 CDN 封鎖自動化存取，請手動下載以下報告："
    echo ""
    echo "主要報告（建議優先下載）："
    echo "  1. Future of Jobs Report 2025"
    echo "     https://www.weforum.org/publications/the-future-of-jobs-report-2025/"
    echo "     → 存為: $RAW_DIR/WEF_Future_of_Jobs_Report_2025.pdf"
    echo ""
    echo "其他報告："
    if [[ -n "$MISSING_PDFS" ]]; then
        echo -e "$MISSING_PDFS"
    fi
    echo ""
    echo "下載完成後，請重新執行此腳本。"

    # 建立空 JSONL（表示已執行但無資料）
    touch "$OUTPUT_FILE"
    date -u +%s > "$RAW_DIR/.last_fetch"
fi

echo ""
echo "結束時間: $(date '+%Y-%m-%d %H:%M:%S')"
