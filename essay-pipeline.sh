#!/usr/bin/env bash

# essay-pipeline.sh
#
# Resumable four-stage theory-driven essay pipeline:
#
#   1. outline   — DRAFT_MODEL
#   2. draft     — DRAFT_MODEL
#   3. review    — REVIEW_MODEL
#   4. revision  — DRAFT_MODEL
#
# Each completed stage is cached on disk. If the pipeline is interrupted,
# running the same topic again resumes from the first incomplete stage.
#
# Usage:
#
#   ./essay-pipeline.sh "essay topic"
#
# Force a complete regeneration:
#
#   FORCE=1 ./essay-pipeline.sh "essay topic"
#
# Keep rendered prompts for inspection:
#
#   KEEP_PROMPTS=1 ./essay-pipeline.sh "essay topic"

set -Eeuo pipefail

###############################################################################
# Bootstrap
###############################################################################

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${ROOT}/scripts/common.sh"

check_environment

###############################################################################
# Arguments
###############################################################################

if (( $# == 0 )); then
    echo "Usage:"
    echo
    echo '    ./essay-pipeline.sh "essay topic"'
    exit 1
fi

TOPIC="$*"
SLUG="$(slugify "$TOPIC")"

WORK="${OUTPUT_DIR}/${SLUG}"

mkdir -p "$WORK"

###############################################################################
# Configuration
###############################################################################

FORCE="${FORCE:-0}"
KEEP_PROMPTS="${KEEP_PROMPTS:-0}"

# Very small outputs usually indicate a failed or malformed generation.
# These can be overridden from the environment.

MIN_OUTLINE_BYTES="${MIN_OUTLINE_BYTES:-500}"
MIN_DRAFT_BYTES="${MIN_DRAFT_BYTES:-3000}"
MIN_REVIEW_BYTES="${MIN_REVIEW_BYTES:-1000}"
MIN_FINAL_BYTES="${MIN_FINAL_BYTES:-3000}"

###############################################################################
# Files
###############################################################################

TOPIC_FILE="${WORK}/topic.txt"

OUTLINE="${WORK}/outline.md"
DRAFT="${WORK}/draft.md"
REVIEW="${WORK}/review.md"
FINAL="${WORK}/essay.md"

PROMPT_DIR="${WORK}/prompts"
STATE_DIR="${WORK}/.state"

mkdir -p "$PROMPT_DIR"
mkdir -p "$STATE_DIR"

LOG_FILE="${WORK}/pipeline.log"

###############################################################################
# Topic
###############################################################################

printf '%s\n' "$TOPIC" > "$TOPIC_FILE"

###############################################################################
# Helpers
###############################################################################

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log() {
    printf '[%s] %s\n' "$(timestamp)" "$*" >> "$LOG_FILE"
}

elapsed_string() {
    local total="$1"
    local hours
    local minutes
    local seconds

    hours="$((total / 3600))"
    minutes="$(((total % 3600) / 60))"
    seconds="$((total % 60))"

    if (( hours > 0 )); then
        printf '%dh %dm %ds' "$hours" "$minutes" "$seconds"
    elif (( minutes > 0 )); then
        printf '%dm %ds' "$minutes" "$seconds"
    else
        printf '%ds' "$seconds"
    fi
}

file_size() {
    local file="$1"

    if [[ -f "$file" ]]; then
        wc -c < "$file" | tr -d ' '
    else
        printf '0'
    fi
}

valid_output() {
    local file="$1"
    local minimum="$2"
    local size

    [[ -s "$file" ]] || return 1

    size="$(file_size "$file")"

    (( size >= minimum ))
}

stage_done() {
    local stage="$1"
    local output="$2"
    local minimum="$3"
    local marker="${STATE_DIR}/${stage}.done"

    (( FORCE == 0 )) || return 1

    [[ -f "$marker" ]] || return 1

    valid_output "$output" "$minimum"
}

mark_done() {
    local stage="$1"
    local output="$2"
    local elapsed="$3"
    local marker="${STATE_DIR}/${stage}.done"

    {
        printf 'stage=%s\n' "$stage"
        printf 'completed=%s\n' "$(timestamp)"
        printf 'elapsed_seconds=%s\n' "$elapsed"
        printf 'bytes=%s\n' "$(file_size "$output")"
        printf 'output=%s\n' "$output"
    } > "$marker"
}

invalidate_from() {
    local stage="$1"

    case "$stage" in
        outline)
            rm -f \
                "${STATE_DIR}/outline.done" \
                "${STATE_DIR}/draft.done" \
                "${STATE_DIR}/review.done" \
                "${STATE_DIR}/revision.done"
            ;;
        draft)
            rm -f \
                "${STATE_DIR}/draft.done" \
                "${STATE_DIR}/review.done" \
                "${STATE_DIR}/revision.done"
            ;;
        review)
            rm -f \
                "${STATE_DIR}/review.done" \
                "${STATE_DIR}/revision.done"
            ;;
        revision)
            rm -f \
                "${STATE_DIR}/revision.done"
            ;;
    esac
}

banner() {
    local label="$1"
    local model="$2"

    echo
    echo "============================================================"
    printf ' %s — %s\n' "$label" "$model"
    echo "============================================================"
    echo
}

###############################################################################
# Generic stage runner
###############################################################################

run_stage() {
    local stage="$1"
    local label="$2"
    local model="$3"
    local template="$4"
    local output="$5"
    local minimum="$6"

    shift 6

    local prompt_file="${PROMPT_DIR}/${stage}.txt"
    local temp_file="${output}.partial"
    local start
    local end
    local elapsed
    local bytes

    ###########################################################################
    # Cached stage
    ###########################################################################

    if stage_done "$stage" "$output" "$minimum"; then

        bytes="$(file_size "$output")"

        echo
        printf '[cached] %-10s %8s bytes\n' "$label" "$bytes"

        log "${stage}: cached (${bytes} bytes)"

        return 0
    fi

    ###########################################################################
    # Regeneration invalidates dependent stages
    ###########################################################################

    invalidate_from "$stage"

    rm -f "$temp_file"

    ###########################################################################
    # Render prompt directly to disk
    ###########################################################################

    "$ROOT/scripts/render-prompt.py" \
        "$template" \
        "$@" > "$prompt_file"

    if [[ ! -s "$prompt_file" ]]; then
        echo "ERROR: Rendered prompt is empty:"
        echo
        echo "    $prompt_file"
        return 1
    fi

    ###########################################################################
    # Run model
    ###########################################################################

    banner "$label" "$model"

    log "${stage}: started with ${model}"

    start="$(date +%s)"

    if run_model "$model" "$(cat "$prompt_file")" |
        tee "$temp_file"
    then
        :
    else
        status=$?

        echo
        echo "ERROR: Model failed during ${stage}."
        echo
        echo "Partial output retained at:"
        echo
        echo "    $temp_file"
        echo

        log "${stage}: model failure (status ${status})"

        return "$status"
    fi

    end="$(date +%s)"
    elapsed="$((end - start))"

    ###########################################################################
    # Validate before committing output
    ###########################################################################

    if ! valid_output "$temp_file" "$minimum"; then

        bytes="$(file_size "$temp_file")"

        echo
        echo "ERROR: ${label} output failed validation."
        echo
        echo "Expected at least:"
        echo "    ${minimum} bytes"
        echo
        echo "Received:"
        echo "    ${bytes} bytes"
        echo
        echo "Partial output retained at:"
        echo "    $temp_file"
        echo

        log "${stage}: validation failure (${bytes} bytes)"

        return 1
    fi

    ###########################################################################
    # Atomic commit
    ###########################################################################

    mv "$temp_file" "$output"

    mark_done "$stage" "$output" "$elapsed"

    bytes="$(file_size "$output")"

    echo
    echo "------------------------------------------------------------"
    printf ' %s COMPLETE\n' "$label"
    echo "------------------------------------------------------------"
    echo
    printf 'Elapsed: %s\n' "$(elapsed_string "$elapsed")"
    printf 'Size:    %s bytes\n' "$bytes"
    echo

    log "${stage}: complete (${elapsed}s, ${bytes} bytes)"

    ###########################################################################
    # Prompt cleanup
    ###########################################################################

    if (( KEEP_PROMPTS == 0 )); then
        rm -f "$prompt_file"
    fi
}

###############################################################################
# Pipeline start
###############################################################################

PIPELINE_START="$(date +%s)"

log "pipeline started: ${TOPIC}"

echo
echo "============================================================"
echo " ESSAY PIPELINE"
echo "============================================================"
echo
echo "Topic:"
echo "    $TOPIC"
echo
echo "Workspace:"
echo "    $WORK"
echo

###############################################################################
# Stage 1 — Outline
###############################################################################

run_stage \
    "outline" \
    "OUTLINE" \
    "$DRAFT_MODEL" \
    "$ROOT/prompts/outline.txt" \
    "$OUTLINE" \
    "$MIN_OUTLINE_BYTES" \
    "TOPIC=$TOPIC_FILE"

###############################################################################
# Stage 2 — Draft
###############################################################################

run_stage \
    "draft" \
    "DRAFT" \
    "$DRAFT_MODEL" \
    "$ROOT/prompts/draft.txt" \
    "$DRAFT" \
    "$MIN_DRAFT_BYTES" \
    "TOPIC=$TOPIC_FILE" \
    "OUTLINE=$OUTLINE"

###############################################################################
# Stage 3 — Review
###############################################################################

run_stage \
    "review" \
    "REVIEW" \
    "$REVIEW_MODEL" \
    "$ROOT/prompts/review.txt" \
    "$REVIEW" \
    "$MIN_REVIEW_BYTES" \
    "ESSAY=$DRAFT"

###############################################################################
# Stage 4 — Revision
###############################################################################

run_stage \
    "revision" \
    "REVISION" \
    "$DRAFT_MODEL" \
    "$ROOT/prompts/revise.txt" \
    "$FINAL" \
    "$MIN_FINAL_BYTES" \
    "ESSAY=$DRAFT" \
    "REVIEW=$REVIEW"

###############################################################################
# Complete
###############################################################################

PIPELINE_END="$(date +%s)"
PIPELINE_ELAPSED="$((PIPELINE_END - PIPELINE_START))"

OUTLINE_SIZE="$(file_size "$OUTLINE")"
DRAFT_SIZE="$(file_size "$DRAFT")"
REVIEW_SIZE="$(file_size "$REVIEW")"
FINAL_SIZE="$(file_size "$FINAL")"

echo
echo "============================================================"
echo " ESSAY COMPLETE"
echo "============================================================"
echo

echo "Topic:"
echo "    $TOPIC"
echo

echo "Outline:"
echo "    $OUTLINE"
echo "    ${OUTLINE_SIZE} bytes"
echo

echo "Draft:"
echo "    $DRAFT"
echo "    ${DRAFT_SIZE} bytes"
echo

echo "Review:"
echo "    $REVIEW"
echo "    ${REVIEW_SIZE} bytes"
echo

echo "Final essay:"
echo "    $FINAL"
echo "    ${FINAL_SIZE} bytes"
echo

printf 'Pipeline time: %s\n' "$(elapsed_string "$PIPELINE_ELAPSED)"
echo

log "pipeline complete: ${TOPIC} (${PIPELINE_ELAPSED}s)"
