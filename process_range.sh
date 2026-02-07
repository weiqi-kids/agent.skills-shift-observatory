#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSONL_FILE="$SCRIPT_DIR/docs/Extractor/global_hn_hiring/raw/hn-hiring-20260204_235436.jsonl"
OUTPUT_DIR="$SCRIPT_DIR/docs/Extractor/global_hn_hiring"
EXTRACTOR="$SCRIPT_DIR/extract_hn_jobs.py"

START=${1:-1}
END=${2:-170}

echo "Processing lines $START to $END"

total=0
success=0
failed=0

for ((i=START; i<=END; i++)); do
    if result=$(python3 "$EXTRACTOR" "$i" "$JSONL_FILE" "$OUTPUT_DIR" 2>&1); then
        ((success++))
        if (( i % 50 == 0 )); then
            echo "Progress: $i/$END lines processed"
        fi
    else
        ((failed++))
        echo "Failed line $i" >&2
    fi
    ((total++))
done

echo ""
echo "=== Processing Complete ==="
echo "Total: $total"
echo "Success: $success"
echo "Failed: $failed"
