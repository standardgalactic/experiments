#!/usr/bin/env bash

# essay-pipeline.sh (v2)
#
# Resumable multi-round theory-driven essay pipeline:
#
#   1. outline           — DRAFT_MODEL
#   2. draft              — DRAFT_MODEL
#   3. review-1           — REVIEW_MODEL   \
#      revision-1          — DRAFT_MODEL    | one round
#      review-2           — REVIEW_MODEL   \
#      revision-2          — DRAFT_MODEL    | another round
#      ...                                  ) ROUNDS total
#
# Each round's review reads the PREVIOUS round's revision (round 1
# reviews the draft; round 2 reviews round 1's fix; and so on), so
# later rounds critique the essay's actual current state rather than
# repeatedly re-critiquing the original draft. The final round's
# revision is copied to essay.md, same filename as v1, so anything
# downstream that expects that name keeps working.
#
# Each completed stage is cached on disk exactly as in v1. If the
# pipeline is interrupted, running the same topic again resumes from
# the first incomplete stage.
#
# Usage:
#
#   ./essay-pipeline.sh "essay topic"
#
# More or fewer review/revision rounds:
#
#   ROUNDS=4 ./essay-pipeline.sh "essay topic"
#
# Force a complete regeneration:
#
#   FORCE=1 ./essay-pipeline.sh "essay topic"
#
# Keep rendered prompts for inspection:
#
#   KEEP_PROMPTS=1 ./essay-pipeline.sh "essay topic"
#
# NOTE: if you re-run an existing topic with a DIFFERENT ROUNDS value
# than the run that produced its cached state, the stage-cascade logic
# below only knows about the round count you pass THIS time — pass
# FORCE=1 when deliberately changing ROUNDS for a topic you've already
# run, rather than trying to resume across a round-count change.

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
ROUNDS="${ROUNDS:-2}"

if ! [[ "$ROUNDS" =~ ^[0-9]+$ ]] || (( ROUNDS < 1 )); then
    echo "ERROR: ROUNDS must be a positive integer (got: ${ROUNDS})"
    exit 1
fi

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
FINAL="${WORK}/essay.md"

# Per-round files, 1-indexed to match ROUNDS.
declare -a REVIEW_FILES REVISION_FILES
for ((r = 1; r <= ROUNDS; r++)); do
    REVIEW_FILES[r]="${WORK}/review-${r}.md"
    REVISION_FILES[r]="${WORK}/revision-${r}.md"
done

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
# Stage order (drives cascade invalidation — see invalidate_from)
###############################################################################

STAGE_ORDER=(outline draft)
for ((r = 1; r <= ROUNDS; r++)); do
    STAGE_ORDER+=("review-${r}" "revision-${r}")
done

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

# Invalidate the given stage and every stage that comes after it in
# STAGE_ORDER. Generalizes v1's fixed four-case switch to an arbitrary
# number of review/revision rounds.
invalidate_from() {
    local stage="$1"
    local found=0
    local s

    for s in "${STAGE_ORDER[@]}"; do
        if [[ "$s" == "$stage" ]]; then
            found=1
        fi
        if (( found == 1 )); then
            rm -f "${STATE_DIR}/${s}.done"
        fi
    done
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
# Generic stage runner (unchanged from v1)
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
        printf '[cached] %-14s %8s bytes\n' "$label" "$bytes"

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

log "pipeline started: ${TOPIC} (ROUNDS=${ROUNDS})"

echo
echo "============================================================"
echo " ESSAY PIPELINE"
echo "============================================================"
echo
echo "Topic:"
echo "    $TOPIC"
echo
echo "Rounds:"
echo "    $ROUNDS"
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
# Stages 3..N — Review / revision rounds
#
# Round r's review reads the essay as it stood after round (r-1)'s
# revision (round 1 reads the draft), so each round critiques the
# essay's current state rather than re-critiquing the original draft
# every time.
###############################################################################

PREV_ESSAY="$DRAFT"

for ((r = 1; r <= ROUNDS; r++)); do

    run_stage \
        "review-${r}" \
        "REVIEW ${r}/${ROUNDS}" \
        "$REVIEW_MODEL" \
        "$ROOT/prompts/review.txt" \
        "${REVIEW_FILES[r]}" \
        "$MIN_REVIEW_BYTES" \
        "ESSAY=$PREV_ESSAY"

    run_stage \
        "revision-${r}" \
        "REVISION ${r}/${ROUNDS}" \
        "$DRAFT_MODEL" \
        "$ROOT/prompts/revise.txt" \
        "${REVISION_FILES[r]}" \
        "$MIN_FINAL_BYTES" \
        "ESSAY=$PREV_ESSAY" \
        "REVIEW=${REVIEW_FILES[r]}"

    PREV_ESSAY="${REVISION_FILES[r]}"

done

cp "$PREV_ESSAY" "$FINAL"

###############################################################################
# Complete
###############################################################################

PIPELINE_END="$(date +%s)"
PIPELINE_ELAPSED="$((PIPELINE_END - PIPELINE_START))"

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
echo "    $(file_size "$OUTLINE") bytes"
echo

echo "Draft:"
echo "    $DRAFT"
echo "    $(file_size "$DRAFT") bytes"
echo

for ((r = 1; r <= ROUNDS; r++)); do
    echo "Round ${r} review:"
    echo "    ${REVIEW_FILES[r]}"
    echo "    $(file_size "${REVIEW_FILES[r]}") bytes"
    echo
    echo "Round ${r} revision:"
    echo "    ${REVISION_FILES[r]}"
    echo "    $(file_size "${REVISION_FILES[r]}") bytes"
    echo
done

echo "Final essay:"
echo "    $FINAL"
echo "    $(file_size "$FINAL") bytes"
echo

printf 'Pipeline time: %s\n' "$(elapsed_string "$PIPELINE_ELAPSED")"
echo

log "pipeline complete: ${TOPIC} (${PIPELINE_ELAPSED}s)"
