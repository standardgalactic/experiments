#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/scripts/common.sh"

check_environment

if (( $# != 1 )); then
    echo "Usage:"
    echo
    echo "    ./review-essay.sh essay.md"
    exit 1
fi

ESSAY="$1"

[[ -f "$ESSAY" ]] ||
    die "Essay not found: $ESSAY"

BASENAME="$(basename "$ESSAY")"
NAME="${BASENAME%.*}"

REVIEW="${OUTPUT_DIR}/${NAME}-review.md"

PROMPT="$(
    "$ROOT/scripts/render-prompt.py" \
        "$ROOT/prompts/review.txt" \
        "ESSAY=$ESSAY"
)"

echo "Reviewing with $REVIEW_MODEL..."
echo

run_model "$REVIEW_MODEL" "$PROMPT" |
    tee "$REVIEW"

echo
echo "Review saved:"
echo
echo "    $REVIEW"
