#!/bin/bash
# match_role.sh - Match job titles to predefined job roles
# Usage: match_role.sh "job title"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLES_FILE="$SCRIPT_DIR/job_roles.json"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed" >&2
    exit 1
fi

# Check if roles file exists
if [[ ! -f "$ROLES_FILE" ]]; then
    echo "Error: job_roles.json not found at $ROLES_FILE" >&2
    exit 1
fi

# Get job title from argument
JOB_TITLE="${1:-}"

if [[ -z "$JOB_TITLE" ]]; then
    echo "Usage: $0 \"job title\"" >&2
    echo "Example: $0 \"軟體工程師\"" >&2
    exit 1
fi

# Convert to lowercase for case-insensitive matching
JOB_TITLE_LOWER=$(echo "$JOB_TITLE" | tr '[:upper:]' '[:lower:]')

# Function to calculate match score
calculate_match_score() {
    local role_id=$1
    local keywords_json=$2
    local score=0
    local max_keyword_score=0

    # Extract keywords array
    local keywords=$(echo "$keywords_json" | jq -r '.[]' 2>/dev/null || echo "")

    # Check each keyword against job title
    while IFS= read -r keyword; do
        [[ -z "$keyword" ]] && continue

        keyword_lower=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
        keyword_score=0

        # Calculate keyword length for better scoring
        keyword_len=${#keyword_lower}
        title_len=${#JOB_TITLE_LOWER}

        # Exact match: +1000 points (highest priority)
        if [[ "$JOB_TITLE_LOWER" == "$keyword_lower" ]]; then
            keyword_score=1000
        # Job title contains keyword (weighted by keyword length)
        elif [[ "$JOB_TITLE_LOWER" == *"$keyword_lower"* ]]; then
            # Longer keywords get higher scores (more specific match)
            keyword_score=$((keyword_len * 10))
        # Keyword contains job title (lower priority)
        elif [[ "$keyword_lower" == *"$JOB_TITLE_LOWER"* ]]; then
            keyword_score=$((title_len * 5))
        fi

        # Keep track of the highest scoring keyword for this role
        if [[ $keyword_score -gt $max_keyword_score ]]; then
            max_keyword_score=$keyword_score
        fi

        score=$((score + keyword_score))
    done <<< "$keywords"

    # Bonus: if the best keyword match is very high, add extra points
    if [[ $max_keyword_score -gt 500 ]]; then
        score=$((score + 500))
    fi

    echo "$score"
}

# Find best matching role
best_score=0
best_role_id=""
best_role_name_en=""
best_role_name_zh=""
best_industry=""
best_ai_vector=""

# Iterate through all roles
total_roles=$(jq '.roles | length' "$ROLES_FILE")

for ((i=0; i<total_roles; i++)); do
    role=$(jq ".roles[$i]" "$ROLES_FILE")

    role_id=$(echo "$role" | jq -r '.id')
    role_name_en=$(echo "$role" | jq -r '.name_en')
    role_name_zh=$(echo "$role" | jq -r '.name_zh')
    industry=$(echo "$role" | jq -r '.industry')
    ai_vector=$(echo "$role" | jq -r '.ai_vector')
    keywords=$(echo "$role" | jq -c '.keywords')

    # Calculate match score
    score=$(calculate_match_score "$role_id" "$keywords")

    # Update best match if this score is higher
    if [[ $score -gt $best_score ]]; then
        best_score=$score
        best_role_id=$role_id
        best_role_name_en=$role_name_en
        best_role_name_zh=$role_name_zh
        best_industry=$industry
        best_ai_vector=$ai_vector
    fi
done

# Output result
if [[ $best_score -gt 0 ]]; then
    # Get AI vector description
    ai_vector_desc=$(jq -r ".ai_replacement_vectors.$best_ai_vector.description" "$ROLES_FILE")
    ai_vector_risk=$(jq -r ".ai_replacement_vectors.$best_ai_vector.risk_level" "$ROLES_FILE")

    # Output as JSON
    cat <<EOF
{
  "matched": true,
  "score": $best_score,
  "role": {
    "id": $best_role_id,
    "name_en": "$best_role_name_en",
    "name_zh": "$best_role_name_zh",
    "industry": "$best_industry",
    "ai_vector": "$best_ai_vector",
    "ai_vector_description": "$ai_vector_desc",
    "ai_risk_level": "$ai_vector_risk"
  },
  "input": "$JOB_TITLE"
}
EOF
else
    # No match found
    cat <<EOF
{
  "matched": false,
  "score": 0,
  "role": null,
  "input": "$JOB_TITLE",
  "message": "No matching role found. Consider using 'unknown' or creating a new role mapping."
}
EOF
fi
