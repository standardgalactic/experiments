#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/scripts/common.sh"

check_environment

if (( $# == 0 )); then
    echo "Usage:"
    echo
    echo "    ./granite-essay.sh \"essay topic\""
    exit 1
fi

TOPIC="$*"

SLUG="$(slugify "$TOPIC")"

WORK="${OUTPUT_DIR}/${SLUG}"

mkdir -p "$WORK"

TOPIC_FILE="${WORK}/topic.txt"
OUTLINE="${WORK}/outline.md"
DRAFT="${WORK}/draft.md"

printf '%s\n' "$TOPIC" > "$TOPIC_FILE"

echo
echo "Topic:"
echo
echo "    $TOPIC"
echo

###############################################################################
# Outline
###############################################################################

echo "Generating outline with $DRAFT_MODEL..."
echo

OUTLINE_PROMPT="$(
    "$ROOT/scripts/render-prompt.py" \
        "$ROOT/prompts/outline.txt" \
        "TOPIC=$TOPIC_FILE"
)"

run_model "$DRAFT_MODEL" "$OUTLINE_PROMPT" |
    tee "$OUTLINE"

###############################################################################
# Draft
###############################################################################

echo
echo "Generating essay with $DRAFT_MODEL..."
echo

DRAFT_PROMPT="$(
    "$ROOT/scripts/render-prompt.py" \
        "$ROOT/prompts/draft.txt" \
        "TOPIC=$TOPIC_FILE" \
        "OUTLINE=$OUTLINE"
)"

run_model "$DRAFT_MODEL" "$DRAFT_PROMPT" |
    tee "$DRAFT"

echo
echo "Generated:"
echo
echo "    $OUTLINE"
echo "    $DRAFT"
