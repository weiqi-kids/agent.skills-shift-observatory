#!/bin/bash
# Extract skills from job description text
# Usage: extract_skills.sh "job description text"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAXONOMY_FILE="$SCRIPT_DIR/skills_taxonomy.json"

# Read description from argument or stdin
DESC="${1:-$(cat)}"

# Use jq to search for skills in taxonomy
if [[ -f "$TAXONOMY_FILE" ]] && command -v jq >/dev/null 2>&1; then
    FOUND_SKILLS=""

    # Check each skill category
    for category in programming_languages frameworks_tools data_ai soft_skills certifications; do
        SKILLS=$(jq -r ".$category.synonyms | keys[]" "$TAXONOMY_FILE" 2>/dev/null)
        while IFS= read -r skill; do
            # Get all synonyms for this skill
            SYNONYMS=$(jq -r ".$category.synonyms[\"$skill\"][]" "$TAXONOMY_FILE" 2>/dev/null)

            # Check if skill or any synonym appears in description
            if echo "$DESC" | grep -qi "$skill"; then
                FOUND_SKILLS="$FOUND_SKILLS$skill,"
            else
                while IFS= read -r syn; do
                    if echo "$DESC" | grep -qi "$syn"; then
                        FOUND_SKILLS="$FOUND_SKILLS$skill,"
                        break
                    fi
                done <<< "$SYNONYMS"
            fi
        done <<< "$SKILLS"
    done

    # Output unique skills as JSON array
    echo "$FOUND_SKILLS" | tr ',' '\n' | sort -u | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(length > 0))'
else
    echo "[]"
fi
