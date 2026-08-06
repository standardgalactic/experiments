#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/scripts/common.sh"

check_environment

if (( $# == 0 )); then
    echo "Usage:"
    echo
    echo "    ./essay-pipeline.sh \"essay topic\""
    exit 1
fi

TOPIC="$*"
SLUG="$(slugify "$TOPIC")"

WORK="${OUTPUT_DIR}/${SLUG}"

mkdir -p "$WORK"

TOPIC_FILE="${WORK}/topic.txt"
OUTLINE="${WORK}/outline.md"
DRAFT="${WORK}/draft.md"
REVIEW="${WORK}/review.md"
FINAL="${WORK}/essay.md"

printf '%s\n' "$TOPIC" > "$TOPIC_FILE"

###############################################################################
# Stage 1
###############################################################################

echo
echo "============================================================"
echo " OUTLINE — $DRAFT_MODEL"
echo "============================================================"
echo

PROMPT="$(
    "$ROOT/scripts/render-prompt.py" \
        "$ROOT/prompts/outline.txt" \
        "TOPIC=$TOPIC_FILE"
)"

run_model "$DRAFT_MODEL" "$PROMPT" |
    tee "$OUTLINE"

###############################################################################
# Stage 2
###############################################################################

echo
echo "============================================================"
echo " DRAFT — $DRAFT_MODEL"
echo "============================================================"
echo

PROMPT="$(
    "$ROOT/scripts/render-prompt.py" \
        "$ROOT/prompts/draft.txt" \
        "TOPIC=$TOPIC_FILE" \
        "OUTLINE=$OUTLINE"
)"

run_model "$DRAFT_MODEL" "$PROMPT" |
    tee "$DRAFT"

###############################################################################
# Stage 3
###############################################################################

echo
echo "============================================================"
echo " REVIEW — $REVIEW_MODEL"
echo "============================================================"
echo

PROMPT="$(
    "$ROOT/scripts/render-prompt.py" \
        "$ROOT/prompts/review.txt" \
        "ESSAY=$DRAFT"
)"

run_model "$REVIEW_MODEL" "$PROMPT" |
    tee "$REVIEW"

###############################################################################
# Stage 4
###############################################################################

echo
echo "============================================================"
echo " REVISION — $DRAFT_MODEL"
echo "============================================================"
echo

PROMPT="$(
    "$ROOT/scripts/render-prompt.py" \
        "$ROOT/prompts/revise.txt" \
        "ESSAY=$DRAFT" \
        "REVIEW=$REVIEW"
)"

run_model "$DRAFT_MODEL" "$PROMPT" |
    tee "$FINAL"

###############################################################################
# Done
###############################################################################

echo
echo "============================================================"
echo " COMPLETE"
echo "============================================================"
echo

echo "Topic:"
echo "    $TOPIC"
echo

echo "Outline:"
echo "    $OUTLINE"

echo "Draft:"
echo "    $DRAFT"

echo "Review:"
echo "    $REVIEW"

echo "Final essay:"
echo "    $FINAL"

echo
