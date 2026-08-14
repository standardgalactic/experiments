#!/usr/bin/env bash

# many-essays.sh
#
# Run a batch of theory-driven essay experiments sequentially through
# essay-pipeline.sh (v2), tee'd live to the terminal AND recorded to a
# persistent batch log, since a batch spanning "a number of theories"
# can run far longer than anyone will watch scroll by in real time.
#
# Replaces three-essays.sh: instead of a hardcoded TOPICS array, reads
# topics from a file — one topic per line, blank lines and lines
# starting with # ignored — so adding a 30th essay is an edit to a
# text file, not to this script.
#
# Each essay's own resumability (per-stage, per-round caching) comes
# for free from essay-pipeline.sh — re-running this wrapper after an
# interruption naturally resumes every essay from its first
# incomplete stage, with no extra bookkeeping needed here.
#
# Usage:
#
#   ./many-essays.sh topics.txt
#
# topics.txt:
#
#   # comments and blank lines are ignored
#   Why repair that eliminates difference can be a form of system failure
#   Why admissibility is a stronger concept than optimization
#   Why continuation should be treated as a property of trajectories
#
# Every review/revision round per essay (ROUNDS), FORCE, and
# KEEP_PROMPTS all pass straight through to essay-pipeline.sh:
#
#   ROUNDS=4 ./many-essays.sh topics.txt
#   FORCE=1 ROUNDS=3 ./many-essays.sh topics.txt

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE="${ROOT}/essay-pipeline.sh"

###############################################################################
# Preflight
###############################################################################

if [[ ! -x "$PIPELINE" ]]; then
    echo "ERROR: Cannot execute:"
    echo
    echo "    $PIPELINE"
    echo
    echo "Try:"
    echo
    echo "    chmod +x essay-pipeline.sh"
    exit 1
fi

if (( $# == 0 )) || [[ ! -f "$1" ]]; then
    echo "Usage:"
    echo
    echo "    ./many-essays.sh topics.txt"
    echo
    echo "topics.txt: one topic per line; blank lines and lines"
    echo "starting with # are ignored."
    exit 1
fi

TOPICS_FILE="$1"

###############################################################################
# Batch-level logging — tee the ENTIRE run (including everything
# essay-pipeline.sh itself prints/tees per stage) to a persistent file,
# in addition to showing it live, so a long unattended batch leaves a
# full transcript rather than only whatever scrolled past.
###############################################################################

LOG_DIR="${ROOT}/batch-logs"
mkdir -p "$LOG_DIR"
BATCH_LOG="${LOG_DIR}/batch-$(date '+%Y%m%d-%H%M%S').log"

exec > >(tee -a "$BATCH_LOG") 2>&1

###############################################################################
# Load topics
###############################################################################

mapfile -t TOPICS < <(
    grep -v -E '^\s*(#|$)' "$TOPICS_FILE"
)

if (( ${#TOPICS[@]} == 0 )); then
    echo "ERROR: No topics found in $TOPICS_FILE"
    exit 1
fi

TOTAL="${#TOPICS[@]}"

###############################################################################
# Report
###############################################################################

echo
echo "============================================================"
echo " ESSAY BATCH"
echo "============================================================"
echo

echo "Pipeline:"
echo "    $PIPELINE"
echo

echo "Topics file:"
echo "    $TOPICS_FILE"
echo

echo "Batch log:"
echo "    $BATCH_LOG"
echo

echo "Rounds per essay:"
echo "    ${ROUNDS:-2} (default; override with ROUNDS=N)"
echo

echo "Experiments:"
echo
for i in "${!TOPICS[@]}"; do
    printf '    %d. %s\n' "$((i + 1))" "${TOPICS[$i]}"
done
echo
echo "Each experiment runs to completion before the next begins."
echo

###############################################################################
# Run experiments
###############################################################################

START_TIME="$(date +%s)"

PASSED=0
FAILED=0
declare -a FAILED_TOPICS

for i in "${!TOPICS[@]}"; do

    NUMBER="$((i + 1))"
    TOPIC="${TOPICS[$i]}"

    echo
    echo "############################################################"
    echo "#"
    echo "# ESSAY ${NUMBER} / ${TOTAL}"
    echo "#"
    echo "# $TOPIC"
    echo "#"
    echo "############################################################"
    echo

    ESSAY_START="$(date +%s)"

    if "$PIPELINE" "$TOPIC"; then

        ESSAY_END="$(date +%s)"
        ELAPSED="$((ESSAY_END - ESSAY_START))"

        ((PASSED += 1))

        echo
        echo "------------------------------------------------------------"
        echo " ESSAY ${NUMBER} COMPLETE"
        echo "------------------------------------------------------------"
        echo
        echo "Elapsed: ${ELAPSED} seconds"
        echo

    else

        ESSAY_END="$(date +%s)"
        ELAPSED="$((ESSAY_END - ESSAY_START))"

        ((FAILED += 1))
        FAILED_TOPICS+=("$TOPIC")

        echo
        echo "------------------------------------------------------------"
        echo " ESSAY ${NUMBER} FAILED"
        echo "------------------------------------------------------------"
        echo
        echo "Topic:"
        echo "    $TOPIC"
        echo
        echo "Elapsed: ${ELAPSED} seconds"
        echo
        echo "This essay's own progress is still cached under its"
        echo "workspace — re-running this batch (or the pipeline"
        echo "directly on this topic) will resume from the first"
        echo "incomplete stage rather than starting over."
        echo

    fi

done

###############################################################################
# Final report
###############################################################################

END_TIME="$(date +%s)"
TOTAL_ELAPSED="$((END_TIME - START_TIME))"

MINUTES="$((TOTAL_ELAPSED / 60))"
SECONDS="$((TOTAL_ELAPSED % 60))"

echo
echo "============================================================"
echo " BATCH COMPLETE"
echo "============================================================"
echo

echo "Successful:  $PASSED"
echo "Failed:      $FAILED"
echo "Total:       $TOTAL"
echo
printf 'Elapsed:     %dm %ds\n' "$MINUTES" "$SECONDS"
echo

if (( FAILED > 0 )); then
    echo "Failed topics:"
    for t in "${FAILED_TOPICS[@]}"; do
        echo "    - $t"
    done
    echo
fi

echo "Results are under:"
echo
echo "    ${ROOT}/output/"
echo
echo "Full batch transcript:"
echo
echo "    $BATCH_LOG"
echo

if (( FAILED == 0 )); then
    echo "All ${TOTAL} essay experiment(s) completed successfully."
else
    echo "$FAILED experiment(s) failed."
    exit 1
fi
