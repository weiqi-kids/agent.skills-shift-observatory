#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSONL_FILE="$SCRIPT_DIR/docs/Extractor/global_hn_hiring/raw/hn-hiring-20260204_235436.jsonl"
OUTPUT_DIR="$SCRIPT_DIR/docs/Extractor/global_hn_hiring"
EXTRACTOR="$SCRIPT_DIR/extract_hn_jobs.py"

START=${1:-1}
END=${2:-170}
BATCH_SIZE=${3:-10}

echo "Processing lines $START to $END"

total=0
success=0
failed=0

for ((i=START; i<=END; i++)); do
    # Process in background with batch limit
    {
        result=$(python3 "$EXTRACTOR" "$i" "$JSONL_FILE" "$OUTPUT_DIR" 2>&1)
        if [ $? -eq 0 ]; then
            echo "✓ Line $i: $result"
        else
            echo "✗ Line $i failed" >&2
        fi
    } &

    # Limit parallel processes
    if (( i % BATCH_SIZE == 0 )); then
        wait
        echo "--- Processed up to line $i ---"
    fi

    ((total++))
done

wait

echo ""
echo "=== Processing Complete ==="
echo "Total lines processed: $total"
echo "Range: $START-$END"
