#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/scripts/common.sh"

check_environment

PROMPT='Explain in one paragraph why preserving useful distinctions can matter when repairing a system.'

echo
echo "============================================================"
echo " DRAFT MODEL"
echo "============================================================"
echo

run_model "$DRAFT_MODEL" "$PROMPT"

echo
echo "============================================================"
echo " REVIEW MODEL"
echo "============================================================"
echo

run_model "$REVIEW_MODEL" "$PROMPT"

echo
