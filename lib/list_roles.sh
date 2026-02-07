#!/bin/bash
# list_roles.sh - List all predefined job roles
# Usage: list_roles.sh [--by-vector|--by-industry|--summary]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLES_FILE="$SCRIPT_DIR/job_roles.json"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed" >&2
    exit 1
fi

MODE="${1:-list}"

case "$MODE" in
    --by-vector)
        echo "=== Roles grouped by AI Replacement Vector ==="
        echo ""

        for vector in cognitive_routine cognitive_nonroutine physical_routine physical_nonroutine interpersonal; do
            vector_desc=$(jq -r ".ai_replacement_vectors.$vector.description" "$ROLES_FILE")
            risk=$(jq -r ".ai_replacement_vectors.$vector.risk_level" "$ROLES_FILE")

            echo "## $vector (Risk: $risk)"
            echo "   $vector_desc"
            echo ""

            jq -r ".roles[] | select(.ai_vector == \"$vector\") | \"   [\(.id)] \(.name_zh) (\(.name_en))\"" "$ROLES_FILE"
            echo ""
        done
        ;;

    --by-industry)
        echo "=== Roles grouped by Industry ==="
        echo ""

        industries=$(jq -r '.roles[].industry' "$ROLES_FILE" | sort -u)

        while IFS= read -r industry; do
            echo "## $industry"
            jq -r ".roles[] | select(.industry == \"$industry\") | \"   [\(.id)] \(.name_zh) (\(.name_en)) - \(.ai_vector)\"" "$ROLES_FILE"
            echo ""
        done <<< "$industries"
        ;;

    --summary)
        total=$(jq '.metadata.total_roles' "$ROLES_FILE")
        industries=$(jq '.metadata.industries' "$ROLES_FILE")
        vectors=$(jq '.metadata.ai_vectors' "$ROLES_FILE")

        echo "=== Job Role Mapping Summary ==="
        echo ""
        echo "Total Roles: $total"
        echo "Industries: $industries"
        echo "AI Vectors: $vectors"
        echo ""

        echo "AI Replacement Vectors:"
        jq -r '.ai_replacement_vectors | to_entries[] | "  - \(.key): \(.value.description) (Risk: \(.value.risk_level))"' "$ROLES_FILE"
        echo ""

        echo "Distribution by AI Vector:"
        for vector in cognitive_routine cognitive_nonroutine physical_routine physical_nonroutine interpersonal; do
            count=$(jq "[.roles[] | select(.ai_vector == \"$vector\")] | length" "$ROLES_FILE")
            echo "  - $vector: $count roles"
        done
        ;;

    list|*)
        echo "=== All Job Roles ==="
        echo ""
        jq -r '.roles[] | "[\(.id)] \(.name_zh) (\(.name_en))\n    Industry: \(.industry) | AI Vector: \(.ai_vector)\n    Keywords: \(.keywords | join(", "))\n"' "$ROLES_FILE"
        ;;
esac
