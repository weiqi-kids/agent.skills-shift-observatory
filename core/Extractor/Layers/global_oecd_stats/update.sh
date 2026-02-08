#!/bin/bash
# global_oecd_stats update script
# Writes to Qdrant and checks for REVIEW_NEEDED

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="global_oecd_stats"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# Ensure category directories exist
for category in unemployment_rate employment_rate participation_rate; do
    mkdir -p "$DOCS_DIR/$category"
done

# Qdrant update
if [[ -n "${QDRANT_URL:-}" ]]; then
    qdrant_init_env || echo "Qdrant connection failed" >&2
fi

# Check for REVIEW_NEEDED
REVIEW_FILES=""
for f in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
    if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
        REVIEW_FILES+="  - $f\n"
    fi
done

if [[ -n "$REVIEW_FILES" ]]; then
    echo "Files needing review:" && echo -e "$REVIEW_FILES"
fi

echo "Update completed: $LAYER_NAME"
