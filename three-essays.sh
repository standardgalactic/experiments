#!/usr/bin/env bash

# three-essays.sh
#
# Run three theory-driven essay experiments sequentially through the
# existing Granite essay pipeline.
#
# Each essay completes:
#
#   3B outline
#       ->
#   3B draft
#       ->
#   8B review
#       ->
#   3B revision
#
# before the next essay begins.
#
# Usage:
#
#   chmod +x three-essays.sh
#   ./three-essays.sh

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

###############################################################################
# Experimental topics
###############################################################################

TOPICS=(

    "Why repair that eliminates difference can be a form of system failure"

    "Why admissibility is a stronger concept than optimization for understanding persistent systems"

    "Why continuation should be treated as a property of trajectories rather than states"

)

###############################################################################
# Report
###############################################################################

TOTAL="${#TOPICS[@]}"

echo
echo "============================================================"
echo " THREE GRANITE ESSAY EXPERIMENTS"
echo "============================================================"
echo

echo "Pipeline:"
echo "    $PIPELINE"
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

echo "Results are under:"
echo
echo "    ${ROOT}/output/"
echo

if (( FAILED == 0 )); then
    echo "All three essay experiments completed successfully."
else
    echo "$FAILED experiment(s) failed."
    exit 1
fi
