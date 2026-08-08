#!/usr/bin/env bash

# hundred-essays.sh
#
# Run one hundred theory-driven essay experiments sequentially through
# the existing Granite essay pipeline.
#
# Each essay completes:
#
# 3B outline
# ->
# 3B draft
# ->
# 8B review
# ->
# 3B revision
#
# before the next essay begins.
#
# The batch is resumable. Successfully completed essays are recorded
# under .essay-batch-state/. Running this script again automatically
# skips completed essays and retries incomplete or failed essays.
#
# Usage:
#
# chmod +x hundred-essays.sh
# ./hundred-essays.sh
#
# To start the entire experiment over:
#
# rm -rf .essay-batch-state
# ./hundred-essays.sh

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE="${ROOT}/essay-pipeline.sh"

STATE_DIR="${ROOT}/.essay-batch-state"
COMPLETED_DIR="${STATE_DIR}/completed"
FAILED_DIR="${STATE_DIR}/failed"
LOG_FILE="${STATE_DIR}/batch.log"

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

mkdir -p "$COMPLETED_DIR"
mkdir -p "$FAILED_DIR"

touch "$LOG_FILE"

###############################################################################
# Logging
###############################################################################

log() {
    printf '[%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$*" >> "$LOG_FILE"
}

###############################################################################
# Theory-driven essay topics
###############################################################################

TOPICS=(

"Why repair that eliminates difference can be a form of system failure"

"Why admissibility is a stronger concept than optimization for understanding persistent systems"

"Why continuation should be treated as a property of trajectories rather than states"

"Why persistent distinctions are a better starting point for ontology than isolated objects"

"How identity can emerge from recursively repaired distinctions"

"Why a system must preserve some differences in order to remain itself"

"How repair converts temporary distinctions into persistent identities"

"Why perfect equilibrium can be incompatible with continued organization"

"Why persistence requires selective resistance to change rather than simple stability"

"How the survival of distinctions creates the conditions for information"

"Why information should be understood through constrained differences rather than symbolic representation"

"How entropy measures uncertainty about distinctions rather than disorder alone"

"Why information becomes meaningful only relative to admissible continuation"

"How observation creates diagnostic boundaries around persistent processes"

"Why a diagnostic boundary is more general than a Markov blanket"

"How partial observability constrains what a system can know about its own continuation"

"Why ignorance should be treated as a structural property of observation"

"How uncertainty propagates outside the region available to a diagnostic observer"

"Why a representation is useful only when it preserves distinctions relevant to action"

"How lossy representations can nevertheless support reliable continuation"

"Why reachability is more fundamental than abstract possibility"

"How unreachable states differ from merely improbable states"

"Why the future of a system is defined by its reachable trajectories"

"How constraints carve an admissible region out of possibility space"

"Why feasibility should precede optimality in theories of action"

"How systems fail when their desired states leave the reachable set"

"Why an unreachable goal can reorganize a society even after hope disappears"

"How catastrophe changes from an event into a geometry of restricted reachability"

"Why adaptation requires discovering new reachable futures rather than restoring the past"

"How the loss of a destination transforms the meaning of continuation"

"Why optimization assumes too much about the existence of a meaningful objective"

"How admissibility allows systems to survive without possessing a global objective function"

"Why local repair can outperform global optimization in changing environments"

"How optimization can destroy the very distinctions that define the optimizing system"

"Why maximization is often the wrong metaphor for biological persistence"

"How satisficing can be reinterpreted as navigation within an admissible region"

"Why constraint satisfaction provides a richer model of agency than utility maximization"

"How multi-objective systems can persist without reducing values to a single scalar"

"Why a system may rationally reject an apparently superior state"

"How irreversible commitments transform an optimization problem into a reachability problem"

"Why repair should be treated as a primitive operation in theories of organization"

"How repair differs from reversal, restoration, and replacement"

"Why successful repair need not return a system to its previous state"

"How repair can preserve identity while changing nearly every component"

"Why maintenance is an active process rather than the absence of failure"

"How accumulated repairs become part of a system's history"

"Why repaired systems carry information about the disturbances they survived"

"How repair creates path dependence"

"Why the cost of repair can determine whether a distinction remains viable"

"How recursive repair generates higher-order organization"

"Why biological organisms are better understood as repair processes than static machines"

"How homeostasis can be interpreted as constrained continuation"

"Why physiological health is a region of admissible trajectories rather than a single normal state"

"How disease can be modeled as progressive loss of reachable physiological states"

"Why biological robustness depends on preserving multiple repair pathways"

"How redundancy becomes meaningful when viewed through continuation"

"Why aging can be understood as contraction of the repairable state space"

"How organisms remain identical despite continuous material replacement"

"Why death marks a failure of continuation rather than merely a change of state"

"How ecological resilience depends on preserving distinctions at multiple scales"

"Why cognition should be understood as the maintenance of actionable distinctions"

"How perception constructs distinctions that matter for continuation"

"Why memory is a repair mechanism for temporal identity"

"How forgetting can sometimes preserve cognitive admissibility"

"Why consciousness may depend on the integration of distinctions across competing processes"

"How attention alters the reachable space of cognition"

"Why prediction is useful only insofar as it supports admissible action"

"How error correction can provide a more general account of learning than optimization"

"Why intelligence may consist in finding viable continuations under changing constraints"

"How cognitive flexibility depends on preserving alternative reachable trajectories"

"Why computation can be understood as controlled transformation of distinctions"

"How program state acquires meaning through permitted continuations"

"Why type systems describe admissible computational trajectories"

"How ownership in Rust can be interpreted as constrained reachability"

"Why lifetimes function as proofs of admissible continuation"

"How a panic represents departure from an expected computational manifold"

"Why error handling is a form of computational repair"

"How stacks can emerge from primitive operations on distinctions"

"Why control flow is fundamentally about restricting possible continuations"

"How programming languages encode different geometries of reachable computation"

"Why physical law can be interpreted as a constraint on admissible trajectories"

"How conservation laws preserve distinctions across transformation"

"Why fields are better understood dynamically than as containers of static properties"

"How classical mechanics can be reconstructed around reachable trajectories"

"Why thermodynamics concerns constraints on continuation as much as energy exchange"

"How entropy production limits the reversibility of repair"

"Why phase transitions create new spaces of admissible organization"

"How persistent physical structures arise from constrained flows"

"Why stability in physics should be distinguished from mere persistence"

"How boundary conditions participate in defining physical identity"

"Why economic solvency is a reachability problem rather than a static balance-sheet property"

"How fiscal systems fail when future obligations leave the reachable set"

"Why liquidity represents access to continuation rather than wealth alone"

"How economic resilience depends on preserving optionality"

"Why institutions survive through repeated repair rather than permanent equilibrium"

"How social norms create admissible regions of collective behavior"

"Why organizations lose identity when repair eliminates the distinctions that defined them"

"How societies respond when their founding futures become unreachable"

"Why archives matter even when the expected audience disappears"

"How an epistemology of repair changes what it means to know"
)

###############################################################################
# Validate experiment
###############################################################################

TOTAL="${#TOPICS[@]}"

if (( TOTAL != 100 )); then
    echo "ERROR: Expected exactly 100 topics, but found $TOTAL."
    exit 1
fi

###############################################################################
# Determine existing state
###############################################################################

ALREADY_COMPLETE=0

for i in "${!TOPICS[@]}"; do

    NUMBER="$((i + 1))"
    MARKER="${COMPLETED_DIR}/$(printf '%03d' "$NUMBER").done"

    if [[ -f "$MARKER" ]]; then
        ((ALREADY_COMPLETE += 1))
    fi

done

REMAINING="$((TOTAL - ALREADY_COMPLETE))"

###############################################################################
# Report
###############################################################################

echo
echo "============================================================"
echo " ONE HUNDRED GRANITE ESSAY EXPERIMENTS"
echo "============================================================"
echo

echo "Pipeline:"
echo "    $PIPELINE"
echo

echo "State:"
echo "    $STATE_DIR"
echo

echo "Batch log:"
echo "    $LOG_FILE"
echo

echo "Total essays:"
echo "    $TOTAL"
echo

echo "Already complete:"
echo "    $ALREADY_COMPLETE"
echo

echo "Remaining:"
echo "    $REMAINING"
echo

if (( ALREADY_COMPLETE > 0 )); then
    echo "Existing progress detected."
    echo "Completed essays will be skipped automatically."
    echo
fi

log "Batch invocation started: ${ALREADY_COMPLETE}/${TOTAL} already complete"

###############################################################################
# Run experiments
###############################################################################

START_TIME="$(date +%s)"

PASSED=0
FAILED=0
SKIPPED=0
PROCESSED=0

for i in "${!TOPICS[@]}"; do

    NUMBER="$((i + 1))"
    PADDED_NUMBER="$(printf '%03d' "$NUMBER")"
    TOPIC="${TOPICS[$i]}"

    COMPLETE_MARKER="${COMPLETED_DIR}/${PADDED_NUMBER}.done"
    FAILURE_MARKER="${FAILED_DIR}/${PADDED_NUMBER}.failed"

    ###########################################################################
    # Skip previously completed essays
    ###########################################################################

    if [[ -f "$COMPLETE_MARKER" ]]; then

        ((SKIPPED += 1))
        ((PROCESSED += 1))

        printf '[%03d/%03d] SKIP: %s\n' \
            "$NUMBER" \
            "$TOTAL" \
            "$TOPIC"

        continue
    fi

    ###########################################################################
    # Begin essay
    ###########################################################################

    echo
    echo "############################################################"
    echo "#"
    printf '# ESSAY %03d / %03d\n' "$NUMBER" "$TOTAL"
    echo "#"
    echo "# $TOPIC"
    echo "#"
    echo "############################################################"
    echo

    log "Essay ${PADDED_NUMBER} started: ${TOPIC}"

    ESSAY_START="$(date +%s)"

    ###########################################################################
    # Execute pipeline
    ###########################################################################

    if "$PIPELINE" "$TOPIC"; then

        ESSAY_END="$(date +%s)"
        ELAPSED="$((ESSAY_END - ESSAY_START))"

        ((PASSED += 1))
        ((PROCESSED += 1))

        #######################################################################
        # Record successful completion
        #######################################################################

        {
            echo "essay=${NUMBER}"
            echo "topic=${TOPIC}"
            echo "completed=$(date '+%Y-%m-%d %H:%M:%S')"
            echo "elapsed_seconds=${ELAPSED}"
        } > "$COMPLETE_MARKER"

        rm -f "$FAILURE_MARKER"

        log "Essay ${PADDED_NUMBER} completed in ${ELAPSED}s"

        echo
        echo "------------------------------------------------------------"
        printf ' ESSAY %03d COMPLETE\n' "$NUMBER"
        echo "------------------------------------------------------------"
        echo
        echo "Elapsed: ${ELAPSED} seconds"
        echo
        printf 'Progress: %d / %d\n' \
            "$((ALREADY_COMPLETE + PASSED))" \
            "$TOTAL"
        echo

    else

        ESSAY_END="$(date +%s)"
        ELAPSED="$((ESSAY_END - ESSAY_START))"

        ((FAILED += 1))
        ((PROCESSED += 1))

        #######################################################################
        # Record failure
        #######################################################################

        {
            echo "essay=${NUMBER}"
            echo "topic=${TOPIC}"
            echo "failed=$(date '+%Y-%m-%d %H:%M:%S')"
            echo "elapsed_seconds=${ELAPSED}"
        } > "$FAILURE_MARKER"

        log "Essay ${PADDED_NUMBER} FAILED after ${ELAPSED}s"

        echo
        echo "------------------------------------------------------------"
        printf ' ESSAY %03d FAILED\n' "$NUMBER"
        echo "------------------------------------------------------------"
        echo
        echo "Topic:"
        echo "    $TOPIC"
        echo
        echo "Elapsed: ${ELAPSED} seconds"
        echo
        echo "This essay will be retried next time the batch runs."
        echo

    fi

done

###############################################################################
# Final state
###############################################################################

TOTAL_COMPLETE=0

for i in "${!TOPICS[@]}"; do

    NUMBER="$((i + 1))"
    MARKER="${COMPLETED_DIR}/$(printf '%03d' "$NUMBER").done"

    if [[ -f "$MARKER" ]]; then
        ((TOTAL_COMPLETE += 1))
    fi

done

TOTAL_REMAINING="$((TOTAL - TOTAL_COMPLETE))"

###############################################################################
# Final report
###############################################################################

END_TIME="$(date +%s)"
TOTAL_ELAPSED="$((END_TIME - START_TIME))"

HOURS="$((TOTAL_ELAPSED / 3600))"
MINUTES="$(((TOTAL_ELAPSED % 3600) / 60))"
SECONDS="$((TOTAL_ELAPSED % 60))"

echo
echo "============================================================"
echo " BATCH INVOCATION COMPLETE"
echo "============================================================"
echo

echo "This invocation:"
echo
echo "    Successful:  $PASSED"
echo "    Failed:      $FAILED"
echo "    Skipped:     $SKIPPED"
echo

echo "Overall experiment:"
echo
echo "    Complete:    $TOTAL_COMPLETE"
echo "    Remaining:   $TOTAL_REMAINING"
echo "    Total:       $TOTAL"
echo

printf 'Runtime:         %dh %dm %ds\n' \
    "$HOURS" \
    "$MINUTES" \
    "$SECONDS"

echo
echo "Results:"
echo
echo "    ${ROOT}/output/"
echo

echo "State:"
echo
echo "    ${STATE_DIR}/"
echo

log "Batch invocation finished: ${TOTAL_COMPLETE}/${TOTAL} complete; ${FAILED} failed this invocation"

if (( TOTAL_COMPLETE == TOTAL )); then

    echo "============================================================"
    echo " ALL 100 ESSAY EXPERIMENTS COMPLETE"
    echo "============================================================"
    echo

    log "All 100 essays complete"

    exit 0

fi

echo "$TOTAL_REMAINING essay(s) remain."
echo
echo "Run the same command again to continue:"
echo
echo "    ./hundred-essays.sh"
echo

if (( FAILED > 0 )); then
    exit 1
fi
