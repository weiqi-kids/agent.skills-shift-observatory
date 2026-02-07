#!/bin/bash
# batch_match_roles.sh - Match multiple job titles in batch
# Usage: batch_match_roles.sh < input_file.txt
#        echo -e "軟體工程師\n前端工程師\n護理師" | batch_match_roles.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATCH_SCRIPT="$SCRIPT_DIR/match_role.sh"

# Check if match_role.sh exists
if [[ ! -x "$MATCH_SCRIPT" ]]; then
    echo "Error: match_role.sh not found or not executable" >&2
    exit 1
fi

# Output format option (default: json)
OUTPUT_FORMAT="${1:-json}"

# Statistics
total=0
matched=0
unmatched=0

# Start JSON array if needed
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    echo "["
fi

# Read job titles from stdin
first=true
while IFS= read -r job_title; do
    # Skip empty lines
    [[ -z "$job_title" ]] && continue

    total=$((total + 1))

    # Match the role
    result=$("$MATCH_SCRIPT" "$job_title")

    # Check if matched
    if [[ $(echo "$result" | jq -r '.matched') == "true" ]]; then
        matched=$((matched + 1))
    else
        unmatched=$((unmatched + 1))
    fi

    # Output based on format
    case "$OUTPUT_FORMAT" in
        json)
            # Add comma separator for JSON array
            if [[ "$first" == "false" ]]; then
                echo ","
            fi
            first=false
            echo "$result" | jq -c '.'
            ;;

        csv)
            if [[ $total -eq 1 ]]; then
                # Header
                echo "input,matched,role_id,role_name_zh,role_name_en,industry,ai_vector,ai_risk_level,score"
            fi

            # Parse result
            input=$(echo "$result" | jq -r '.input')
            is_matched=$(echo "$result" | jq -r '.matched')

            if [[ "$is_matched" == "true" ]]; then
                role_id=$(echo "$result" | jq -r '.role.id')
                role_name_zh=$(echo "$result" | jq -r '.role.name_zh')
                role_name_en=$(echo "$result" | jq -r '.role.name_en')
                industry=$(echo "$result" | jq -r '.role.industry')
                ai_vector=$(echo "$result" | jq -r '.role.ai_vector')
                ai_risk=$(echo "$result" | jq -r '.role.ai_risk_level')
                score=$(echo "$result" | jq -r '.score')
            else
                role_id=""
                role_name_zh=""
                role_name_en=""
                industry=""
                ai_vector=""
                ai_risk=""
                score="0"
            fi

            echo "\"$input\",$is_matched,\"$role_id\",\"$role_name_zh\",\"$role_name_en\",\"$industry\",\"$ai_vector\",\"$ai_risk\",$score"
            ;;

        tsv)
            if [[ $total -eq 1 ]]; then
                # Header
                echo -e "input\tmatched\trole_id\trole_name_zh\trole_name_en\tindustry\tai_vector\tai_risk_level\tscore"
            fi

            # Parse result
            input=$(echo "$result" | jq -r '.input')
            is_matched=$(echo "$result" | jq -r '.matched')

            if [[ "$is_matched" == "true" ]]; then
                role_id=$(echo "$result" | jq -r '.role.id')
                role_name_zh=$(echo "$result" | jq -r '.role.name_zh')
                role_name_en=$(echo "$result" | jq -r '.role.name_en')
                industry=$(echo "$result" | jq -r '.role.industry')
                ai_vector=$(echo "$result" | jq -r '.role.ai_vector')
                ai_risk=$(echo "$result" | jq -r '.role.ai_risk_level')
                score=$(echo "$result" | jq -r '.score')
            else
                role_id="-"
                role_name_zh="-"
                role_name_en="-"
                industry="-"
                ai_vector="-"
                ai_risk="-"
                score="0"
            fi

            echo -e "$input\t$is_matched\t$role_id\t$role_name_zh\t$role_name_en\t$industry\t$ai_vector\t$ai_risk\t$score"
            ;;

        summary)
            # Just collect stats, output at the end
            ;;

        *)
            echo "Error: Unknown output format: $OUTPUT_FORMAT" >&2
            echo "Supported formats: json, csv, tsv, summary" >&2
            exit 1
            ;;
    esac

done

# Close JSON array if needed
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    echo ""
    echo "]"
fi

# Output statistics if summary mode or to stderr for other modes
if [[ "$OUTPUT_FORMAT" == "summary" ]] || [[ "$OUTPUT_FORMAT" != "json" ]]; then
    output_stream="/dev/stderr"
    [[ "$OUTPUT_FORMAT" == "summary" ]] && output_stream="/dev/stdout"

    {
        echo ""
        echo "=== Batch Matching Summary ==="
        echo "Total processed: $total"
        if [[ $total -gt 0 ]]; then
            matched_pct=$(awk "BEGIN {printf \"%.1f\", ($matched*100)/$total}")
            unmatched_pct=$(awk "BEGIN {printf \"%.1f\", ($unmatched*100)/$total}")
            echo "Matched: $matched ($matched_pct%)"
            echo "Unmatched: $unmatched ($unmatched_pct%)"
        else
            echo "Matched: 0"
            echo "Unmatched: 0"
        fi
    } > "$output_stream"
fi
