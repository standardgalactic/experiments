#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/scripts/common.sh"

check_environment

if (( $# == 0 )); then
    echo "Usage:"
    echo
    echo "    ./compare-models.sh \"prompt\""
    exit 1
fi

PROMPT="$*"

STAMP="$(date +%Y%m%d-%H%M%S)"

SMALL="${OUTPUT_DIR}/${STAMP}-3b.md"
LARGE="${OUTPUT_DIR}/${STAMP}-8b.md"

echo "Running $DRAFT_MODEL..."

run_model "$DRAFT_MODEL" "$PROMPT" |
    tee "$SMALL"

echo
echo "Running $REVIEW_MODEL..."

run_model "$REVIEW_MODEL" "$PROMPT" |
    tee "$LARGE"

echo
echo "Saved:"
echo
echo "    $SMALL"
echo "    $LARGE"
