#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXP="$ROOT/programming/experiments/admissible-degradation"
REGISTRY="$ROOT/programming/experiments.json"

mkdir -p "$EXP"

echo
echo "========================================"
echo " EXP / 002"
echo " Admissible Degradation"
echo "========================================"
echo

# ============================================================
# Experiment page
# ============================================================

cat > "$EXP/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1">

  <meta
    name="description"
    content="Interactive experiment in degradation, capability loss, admissible continuation, shedding, compensation, and refusal.">

  <title>Admissible Degradation — EXP 002</title>

  <link rel="stylesheet" href="../../../assets/site.css">
  <link rel="stylesheet" href="experiment.css">
</head>

<body>
<main>

  <nav>
    <a href="../../">← programming experiments</a>
    <a href="../../../">laboratory</a>
  </nav>


  <header class="experiment-header">

    <div class="eyebrow">
      Programming Experiment / 002
    </div>

    <h1>Admissible Degradation</h1>

    <p class="lede">
      How much damage can a system absorb while preserving the
      conditions required for legitimate continuation?
    </p>

    <div class="experiment-meta">
      <span>Theory: Admissible Degradation</span>
      <span class="status status-prototype">prototype</span>
    </div>

  </header>


  <section>

    <div class="section-title">
      Experimental Claim
    </div>

    <div class="lab-panel">

      <p>
        System health and continuation admissibility are not the same
        quantity. A system may lose substantial capability while
        remaining entitled to continue if its required obligations
        remain satisfiable. Conversely, loss of a single critical
        obligation may make continuation inadmissible even when most
        of the system remains operational.
      </p>

      <p>
        Degradation should therefore be evaluated structurally rather
        than as a scalar percentage of surviving components.
      </p>

    </div>

  </section>


  <section>

    <div class="section-title">
      Current System State
    </div>

    <div class="apparatus">

      <div class="state-panel">

        <div class="state-label">
          CONTINUATION STATUS
        </div>

        <div
          id="system-state"
          class="system-state normal">
          NORMAL
        </div>

        <div
          id="state-description"
          class="state-description">
          All required and optional capabilities are available.
        </div>

      </div>


      <div class="metrics">

        <div class="metric">
          <span
            id="health-value"
            class="metric-value">
            100%
          </span>

          <span class="metric-label">
            physical health
          </span>
        </div>


        <div class="metric">
          <span
            id="required-value"
            class="metric-value">
            4 / 4
          </span>

          <span class="metric-label">
            required obligations
          </span>
        </div>


        <div class="metric">
          <span
            id="optional-value"
            class="metric-value">
            3 / 3
          </span>

          <span class="metric-label">
            optional capabilities
          </span>
        </div>


        <div class="metric">
          <span
            id="continuations-value"
            class="metric-value">
            0
          </span>

          <span class="metric-label">
            successful continuations
          </span>
        </div>

      </div>

    </div>

  </section>


  <section>

    <div class="section-title">
      Capability Structure
    </div>

    <p class="section-note">
      Required obligations determine whether continuation remains
      admissible. Optional capabilities may be lost or deliberately
      shed without necessarily invalidating continuation.
    </p>

    <div
      id="capability-grid"
      class="capability-grid">
    </div>

  </section>


  <section>

    <div class="section-title">
      Experimental Controls
    </div>

    <div class="button-row">

      <button id="random-failure">
        Apply Random Failure
      </button>

      <button id="shed-optional">
        Shed Optional Capability
      </button>

      <button id="break-required">
        Break Required Capability
      </button>

      <button id="attempt-continuation">
        Attempt Continuation
      </button>

      <button id="compensate">
        Attempt Compensation
      </button>

      <button id="reset">
        Reset Experiment
      </button>

    </div>

  </section>


  <section>

    <div class="section-title">
      Admissibility Evaluation
    </div>

    <div class="evaluation-grid">

      <div class="evaluation-box">

        <span class="evaluation-label">
          SYSTEM RUNNING
        </span>

        <strong id="running-evaluation">
          YES
        </strong>

        <p>
          Whether enough machinery remains for the program to execute.
        </p>

      </div>


      <div class="evaluation-box">

        <span class="evaluation-label">
          REQUIRED OBLIGATIONS SATISFIABLE
        </span>

        <strong id="obligation-evaluation">
          YES
        </strong>

        <p>
          Whether the capabilities required for legitimate
          continuation remain available.
        </p>

      </div>


      <div class="evaluation-box">

        <span class="evaluation-label">
          CONTINUATION ADMISSIBLE
        </span>

        <strong id="admissibility-evaluation">
          YES
        </strong>

        <p>
          Whether the system may legitimately continue in its current
          configuration.
        </p>

      </div>

    </div>

  </section>


  <section>

    <div class="section-title">
      Degradation Trajectory
    </div>

    <div
      id="trajectory"
      class="trajectory">

      <div class="trajectory-empty">
        No events recorded.
      </div>

    </div>

  </section>


  <section>

    <div class="section-title">
      Event Ledger
    </div>

    <div class="ledger-wrap">

      <table class="ledger">

        <thead>
          <tr>
            <th>#</th>
            <th>event</th>
            <th>target</th>
            <th>health</th>
            <th>required</th>
            <th>optional</th>
            <th>status</th>
          </tr>
        </thead>

        <tbody id="ledger-body">
        </tbody>

      </table>

      <div
        id="ledger-empty"
        class="ledger-empty">
        No events recorded.
      </div>

    </div>

  </section>


  <section>

    <div class="section-title">
      Observation
    </div>

    <div class="lab-panel">

      <p id="observation">
        No degradation has yet been introduced.
      </p>

    </div>

  </section>


  <section>

    <div class="section-title">
      Manipulation
    </div>

    <div class="lab-panel">

      <p>
        Individual capabilities can fail. Optional capabilities can
        also be deliberately shed. Required capabilities determine
        continuation admissibility, while optional capabilities
        contribute to physical system health without independently
        determining whether continuation is legitimate.
      </p>

      <p>
        Compensation attempts to restore a failed required obligation
        through a designated surviving fallback capability. A
        successful compensation does not erase the original failure:
        both events remain in the ledger.
      </p>

    </div>

  </section>


  <section>

    <div class="section-title">
      Competing Interpretation
    </div>

    <div class="lab-panel">

      <p>
        The observed behavior could be represented as ordinary fault
        tolerance with critical and noncritical components. The
        experiment therefore does not establish that admissible
        degradation requires a novel computational mechanism.
      </p>

      <p>
        Its purpose is narrower: to test whether separating physical
        survival from continuation admissibility exposes distinctions
        that disappear under a scalar health model.
      </p>

    </div>

  </section>


  <section>

    <div class="section-title">
      Embarrassment Condition
    </div>

    <div class="lab-panel">

      <p>
        The motivating interpretation becomes less useful if
        continuation admissibility can be predicted adequately from
        aggregate component survival alone, if required and optional
        losses never produce meaningfully different trajectories, or
        if compensation and shedding add no distinctions beyond a
        conventional health score.
      </p>

    </div>

  </section>


  <footer>

    <span>
      standardgalactic / experiments / programming
    </span>

    <span>
      EXP 002 / prototype
    </span>

  </footer>

</main>

<script src="experiment.js"></script>

</body>
</html>
HTML


# ============================================================
# Experiment-specific styles
# ============================================================

cat > "$EXP/experiment.css" <<'CSS'
.apparatus {
  display: grid;
  grid-template-columns: 1.15fr 2fr;
  gap: 1px;
  border: 1px solid var(--line);
  background: var(--line);
}

.state-panel {
  min-height: 270px;
  padding: 1.5rem;
  background: var(--panel);
}

.state-label {
  color: var(--muted);
  font-size: 0.67rem;
  letter-spacing: 0.12em;
}

.system-state {
  margin-top: 3.5rem;
  font-size: clamp(2rem, 6vw, 4.4rem);
  line-height: 1;
  letter-spacing: -0.06em;
}

.system-state.normal {
  color: var(--active);
}

.system-state.degraded {
  color: var(--accent);
}

.system-state.refused {
  color: var(--result);
}

.state-description {
  margin-top: 1rem;
  max-width: 400px;
  color: var(--muted);
  font-size: 0.8rem;
  line-height: 1.6;
}

.metrics {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1px;
  background: var(--line);
}

.metric {
  display: flex;
  min-height: 130px;
  padding: 1.2rem;
  flex-direction: column;
  justify-content: space-between;
  background: var(--panel);
}

.metric-value {
  font-size: 2rem;
}

.metric-label {
  color: var(--muted);
  font-size: 0.65rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.section-note {
  max-width: 760px;
  margin-bottom: 1rem;
  color: var(--muted);
  font-size: 0.78rem;
  line-height: 1.6;
}

.capability-grid {
  display: grid;
  grid-template-columns:
    repeat(auto-fit, minmax(230px, 1fr));
  gap: 1px;
  border: 1px solid var(--line);
  background: var(--line);
}

.capability {
  min-height: 180px;
  padding: 1.2rem;
  background: var(--panel);
}

.capability-top {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
}

.capability-code {
  color: var(--muted);
  font-size: 0.65rem;
  letter-spacing: 0.08em;
}

.capability-kind {
  font-size: 0.62rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.capability-kind.required {
  color: var(--result);
}

.capability-kind.optional {
  color: var(--accent);
}

.capability h3 {
  margin-top: 1.2rem;
  margin-bottom: 0.6rem;
  font-size: 1rem;
}

.capability p {
  color: var(--muted);
  font-size: 0.72rem;
  line-height: 1.5;
}

.capability-status {
  display: inline-block;
  margin-top: 1rem;
  padding: 0.25rem 0.45rem;
  border: 1px solid var(--line2);
  font-size: 0.62rem;
  letter-spacing: 0.08em;
}

.capability.operational .capability-status {
  color: var(--active);
}

.capability.failed {
  opacity: 0.62;
}

.capability.failed .capability-status {
  color: var(--result);
}

.capability.shed {
  opacity: 0.52;
}

.capability.shed .capability-status {
  color: var(--muted);
}

.capability.compensated .capability-status {
  color: var(--accent);
}

.button-row {
  display: flex;
  flex-wrap: wrap;
  gap: 0.6rem;
}

button {
  padding: 0.8rem 1rem;
  border: 1px solid var(--line2);
  background: var(--panel);
  color: var(--text);
  font: inherit;
  font-size: 0.75rem;
  cursor: pointer;
}

button:hover {
  background: var(--panel2);
}

button:active {
  transform: translateY(1px);
}

.evaluation-grid {
  display: grid;
  grid-template-columns:
    repeat(3, minmax(0, 1fr));
  gap: 1px;
  border: 1px solid var(--line);
  background: var(--line);
}

.evaluation-box {
  min-height: 180px;
  padding: 1.2rem;
  background: var(--panel);
}

.evaluation-label {
  display: block;
  min-height: 2.5rem;
  color: var(--muted);
  font-size: 0.63rem;
  letter-spacing: 0.08em;
  line-height: 1.4;
}

.evaluation-box strong {
  display: block;
  margin: 1.2rem 0;
  font-size: 1.7rem;
  font-weight: normal;
}

.evaluation-box p {
  color: var(--muted);
  font-size: 0.7rem;
  line-height: 1.5;
}

.trajectory {
  display: flex;
  min-height: 92px;
  padding: 1rem;
  align-items: center;
  gap: 5px;
  overflow-x: auto;
  border: 1px solid var(--line);
  background: var(--panel);
}

.trajectory-empty {
  color: var(--faint);
  font-size: 0.75rem;
}

.trajectory-node {
  display: flex;
  width: 38px;
  min-width: 38px;
  height: 38px;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--line2);
  font-size: 0.62rem;
}

.trajectory-node.normal {
  color: var(--active);
  border-color: var(--active);
}

.trajectory-node.degraded {
  color: var(--accent);
  border-color: var(--accent);
}

.trajectory-node.refused {
  color: var(--result);
  border-color: var(--result);
}

.ledger-wrap {
  overflow-x: auto;
  border: 1px solid var(--line);
  background: var(--panel);
}

.ledger {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.7rem;
}

.ledger th,
.ledger td {
  padding: 0.8rem;
  border-bottom: 1px solid var(--line);
  text-align: left;
  white-space: nowrap;
}

.ledger th {
  color: var(--muted);
  font-weight: normal;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.ledger-empty {
  padding: 1.5rem;
  color: var(--faint);
  font-size: 0.75rem;
}

@media (max-width: 760px) {
  .apparatus {
    grid-template-columns: 1fr;
  }

  .evaluation-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 520px) {
  .metrics {
    grid-template-columns: 1fr;
  }
}
CSS


# ============================================================
# Experiment logic
# ============================================================

cat > "$EXP/experiment.js" <<'JS'
"use strict";

/*
 * EXP 002 — Admissible Degradation
 *
 * This prototype deliberately separates:
 *
 *   physical survival
 *
 * from:
 *
 *   continuation admissibility
 *
 * It is not intended as a complete implementation of the
 * Admissible Degradation framework.
 */


/* ============================================================
 * Capability definitions
 * ============================================================
 *
 * Four capabilities are required.
 *
 * Three are optional.
 *
 * One optional capability can compensate for one particular
 * required failure. This is intentionally simple so that the
 * consequences remain visible in the event ledger.
 */

const capabilityDefinitions = [
  {
    id: "identity",
    name: "Preserve Identity",
    kind: "required",
    description:
      "Maintain the identity of the object or process across continuation."
  },

  {
    id: "disposition",
    name: "Record Disposition",
    kind: "required",
    description:
      "Record what happened to the accepted input or obligation."
  },

  {
    id: "transform",
    name: "Perform Transformation",
    kind: "required",
    description:
      "Perform the transformation required by the current operation."
  },

  {
    id: "verify",
    name: "Verify Result",
    kind: "required",
    description:
      "Determine whether the produced result satisfies the required condition."
  },

  {
    id: "telemetry",
    name: "Extended Telemetry",
    kind: "optional",
    description:
      "Provide additional operational measurements and diagnostic detail."
  },

  {
    id: "cache",
    name: "Acceleration Cache",
    kind: "optional",
    description:
      "Reduce repeated computational work without determining correctness."
  },

  {
    id: "fallback",
    name: "Fallback Verifier",
    kind: "optional",
    description:
      "Provide a slower alternate verification path when the primary verifier fails."
  }
];


/* ============================================================
 * Runtime state
 * ============================================================
 */

const state = {
  capabilities: {},
  events: [],
  continuations: 0,
  attempts: 0
};


/* ============================================================
 * DOM references
 * ============================================================
 */

const els = {
  systemState:
    document.getElementById("system-state"),

  stateDescription:
    document.getElementById("state-description"),

  health:
    document.getElementById("health-value"),

  required:
    document.getElementById("required-value"),

  optional:
    document.getElementById("optional-value"),

  continuations:
    document.getElementById("continuations-value"),

  capabilityGrid:
    document.getElementById("capability-grid"),

  runningEvaluation:
    document.getElementById("running-evaluation"),

  obligationEvaluation:
    document.getElementById("obligation-evaluation"),

  admissibilityEvaluation:
    document.getElementById("admissibility-evaluation"),

  trajectory:
    document.getElementById("trajectory"),

  ledgerBody:
    document.getElementById("ledger-body"),

  ledgerEmpty:
    document.getElementById("ledger-empty"),

  observation:
    document.getElementById("observation"),

  randomFailure:
    document.getElementById("random-failure"),

  shedOptional:
    document.getElementById("shed-optional"),

  breakRequired:
    document.getElementById("break-required"),

  attemptContinuation:
    document.getElementById("attempt-continuation"),

  compensate:
    document.getElementById("compensate"),

  reset:
    document.getElementById("reset")
};


/* ============================================================
 * Initialization
 * ============================================================
 */

function initializeCapabilities() {
  state.capabilities = {};

  for (const definition of capabilityDefinitions) {
    state.capabilities[definition.id] = {
      ...definition,
      state: "operational",
      compensatedBy: null
    };
  }
}


/* ============================================================
 * Queries
 * ============================================================
 */

function capabilities() {
  return Object.values(state.capabilities);
}


function requiredCapabilities() {
  return capabilities().filter(
    capability => capability.kind === "required"
  );
}


function optionalCapabilities() {
  return capabilities().filter(
    capability => capability.kind === "optional"
  );
}


function availableCapabilities() {
  return capabilities().filter(
    capability =>
      capability.state === "operational" ||
      capability.state === "compensated"
  );
}


function failedRequiredCapabilities() {
  return requiredCapabilities().filter(
    capability =>
      capability.state === "failed"
  );
}


function operationalOptionalCapabilities() {
  return optionalCapabilities().filter(
    capability =>
      capability.state === "operational"
  );
}


function physicalHealth() {
  const total = capabilities().length;

  const available = capabilities().filter(
    capability =>
      capability.state === "operational" ||
      capability.state === "compensated"
  ).length;

  return Math.round(
    (available / total) * 100
  );
}


/*
 * "Running" is deliberately weaker than "admissible".
 *
 * The prototype says the machinery is still running as long as
 * at least one capability remains physically available.
 *
 * This is intentionally permissive.
 */

function isRunning() {
  return availableCapabilities().length > 0;
}


/*
 * A required capability counts as satisfied if it is either:
 *
 *   operational
 *
 * or:
 *
 *   compensated
 */

function requiredSatisfied(capability) {
  return (
    capability.state === "operational" ||
    capability.state === "compensated"
  );
}


function satisfiedRequiredCount() {
  return requiredCapabilities().filter(
    requiredSatisfied
  ).length;
}


function activeOptionalCount() {
  return optionalCapabilities().filter(
    capability =>
      capability.state === "operational"
  ).length;
}


function obligationsSatisfiable() {
  return requiredCapabilities().every(
    requiredSatisfied
  );
}


function continuationAdmissible() {
  return (
    isRunning() &&
    obligationsSatisfiable()
  );
}


/* ============================================================
 * Overall classification
 * ============================================================
 */

function classifySystem() {
  if (!continuationAdmissible()) {
    return "refused";
  }

  const pristine =
    capabilities().every(
      capability =>
        capability.state === "operational"
    );

  if (pristine) {
    return "normal";
  }

  return "degraded";
}


function classificationLabel() {
  const classification = classifySystem();

  if (classification === "normal") {
    return "NORMAL";
  }

  if (classification === "degraded") {
    return "DEGRADED";
  }

  return "REFUSED";
}


/* ============================================================
 * Ledger
 * ============================================================
 */

function record(event, target = "—") {
  state.events.push({
    n: state.events.length + 1,
    event,
    target,
    health: physicalHealth(),
    required:
      `${satisfiedRequiredCount()} / ${requiredCapabilities().length}`,
    optional:
      `${activeOptionalCount()} / ${optionalCapabilities().length}`,
    status: classificationLabel()
  });
}


/* ============================================================
 * Failure operations
 * ============================================================
 */

function failCapability(capability, event = "FAIL") {
  if (!capability) {
    return false;
  }

  if (capability.state !== "operational") {
    return false;
  }

  capability.state = "failed";
  capability.compensatedBy = null;

  record(
    event,
    capability.name
  );

  return true;
}


function applyRandomFailure() {
  const candidates = capabilities().filter(
    capability =>
      capability.state === "operational"
  );

  if (candidates.length === 0) {
    record(
      "NO-FAILURE",
      "no operational capability available"
    );

    render();
    return;
  }

  const index = Math.floor(
    Math.random() * candidates.length
  );

  failCapability(
    candidates[index],
    "FAIL"
  );

  render();
}


function breakRequiredCapability() {
  const candidates = requiredCapabilities().filter(
    capability =>
      capability.state === "operational"
  );

  if (candidates.length === 0) {
    record(
      "NO-FAILURE",
      "no operational required capability"
    );

    render();
    return;
  }

  const index = Math.floor(
    Math.random() * candidates.length
  );

  failCapability(
    candidates[index],
    "FAIL-REQUIRED"
  );

  render();
}


/* ============================================================
 * Shedding
 * ============================================================
 */

function shedOptionalCapability() {
  const candidates =
    operationalOptionalCapabilities();

  if (candidates.length === 0) {
    record(
      "NO-SHED",
      "no optional capability available"
    );

    render();
    return;
  }

  /*
   * Deliberately choose the first available optional capability
   * rather than choosing randomly.
   *
   * This makes repeated experimental runs easier to compare.
   */

  const capability = candidates[0];

  capability.state = "shed";

  record(
    "SHED",
    capability.name
  );

  render();
}


/* ============================================================
 * Compensation
 * ============================================================
 *
 * The first prototype implements exactly one compensating path:
 *
 *   Verify Result
 *
 * may be compensated by:
 *
 *   Fallback Verifier
 *
 * This is deliberately explicit rather than generic.
 */

function attemptCompensation() {
  const verify =
    state.capabilities.verify;

  const fallback =
    state.capabilities.fallback;

  if (
    verify.state === "failed" &&
    fallback.state === "operational"
  ) {
    verify.state = "compensated";
    verify.compensatedBy = fallback.id;

    /*
     * The fallback is now committed to the compensating role.
     *
     * We mark it as shed from the optional pool because it is no
     * longer freely available as optional capacity.
     */

    fallback.state = "shed";

    record(
      "COMPENSATE",
      "Verify Result ← Fallback Verifier"
    );

    render();
    return;
  }

  record(
    "COMPENSATION-FAILED",
    "no admissible compensation available"
  );

  render();
}


/* ============================================================
 * Continuation
 * ============================================================
 */

function attemptContinuation() {
  state.attempts += 1;

  if (continuationAdmissible()) {
    state.continuations += 1;

    record(
      "CONTINUE",
      `attempt ${state.attempts}`
    );
  } else {
    record(
      "REFUSE",
      `attempt ${state.attempts}`
    );
  }

  render();
}


/* ============================================================
 * Observation
 * ============================================================
 */

function observationText() {
  if (state.events.length === 0) {
    return (
      "No degradation has yet been introduced. " +
      "The system is intact and continuation is admissible."
    );
  }

  const classification =
    classifySystem();

  const health =
    physicalHealth();

  const failedRequired =
    failedRequiredCapabilities();

  if (classification === "normal") {
    return (
      "All capabilities are operational. Physical health and " +
      "continuation admissibility currently agree."
    );
  }

  if (classification === "degraded") {
    return (
      `The system is operating at ${health}% physical health, ` +
      "but all required obligations remain satisfiable. " +
      "Continuation therefore remains admissible despite " +
      "degradation."
    );
  }

  if (failedRequired.length > 0) {
    const names =
      failedRequired
        .map(capability => capability.name)
        .join(", ");

    return (
      `The system is still ${health}% physically intact, but ` +
      `required obligation failure (${names}) makes continuation ` +
      "inadmissible. Physical survival is therefore insufficient " +
      "to establish legitimate continuation."
    );
  }

  return (
    "Continuation is currently inadmissible even though some " +
    "physical machinery remains available."
  );
}


/* ============================================================
 * Rendering — capability cards
 * ============================================================
 */

function renderCapabilities() {
  els.capabilityGrid.innerHTML = "";

  capabilities().forEach(
    (capability, index) => {
      const card =
        document.createElement("div");

      card.className =
        `capability ${capability.state}`;

      const top =
        document.createElement("div");

      top.className =
        "capability-top";

      const code =
        document.createElement("span");

      code.className =
        "capability-code";

      code.textContent =
        `CAP ${String(index + 1).padStart(2, "0")}`;

      const kind =
        document.createElement("span");

      kind.className =
        `capability-kind ${capability.kind}`;

      kind.textContent =
        capability.kind;

      top.appendChild(code);
      top.appendChild(kind);

      const heading =
        document.createElement("h3");

      heading.textContent =
        capability.name;

      const description =
        document.createElement("p");

      description.textContent =
        capability.description;

      const status =
        document.createElement("span");

      status.className =
        "capability-status";

      if (capability.state === "compensated") {
        const compensator =
          state.capabilities[
            capability.compensatedBy
          ];

        status.textContent =
          compensator
            ? `COMPENSATED BY ${compensator.name.toUpperCase()}`
            : "COMPENSATED";
      } else {
        status.textContent =
          capability.state.toUpperCase();
      }

      card.appendChild(top);
      card.appendChild(heading);
      card.appendChild(description);
      card.appendChild(status);

      els.capabilityGrid.appendChild(card);
    }
  );
}


/* ============================================================
 * Rendering — trajectory
 * ============================================================
 */

function trajectorySymbol(event) {
  switch (event.event) {
    case "FAIL":
    case "FAIL-REQUIRED":
      return "×";

    case "SHED":
      return "S";

    case "COMPENSATE":
      return "C";

    case "COMPENSATION-FAILED":
      return "!";

    case "CONTINUE":
      return "→";

    case "REFUSE":
      return "R";

    default:
      return "·";
  }
}


function renderTrajectory() {
  els.trajectory.innerHTML = "";

  if (state.events.length === 0) {
    const empty =
      document.createElement("div");

    empty.className =
      "trajectory-empty";

    empty.textContent =
      "No events recorded.";

    els.trajectory.appendChild(empty);

    return;
  }

  for (const event of state.events) {
    const node =
      document.createElement("div");

    node.className =
      `trajectory-node ${event.status.toLowerCase()}`;

    node.textContent =
      trajectorySymbol(event);

    node.title =
      `${event.n}: ${event.event} — ${event.target} — ${event.status}`;

    els.trajectory.appendChild(node);
  }
}


/* ============================================================
 * Rendering — ledger
 * ============================================================
 */

function renderLedger() {
  els.ledgerBody.innerHTML = "";

  els.ledgerEmpty.style.display =
    state.events.length === 0
      ? "block"
      : "none";

  for (const event of state.events) {
    const row =
      document.createElement("tr");

    const values = [
      event.n,
      event.event,
      event.target,
      `${event.health}%`,
      event.required,
      event.optional,
      event.status
    ];

    for (const value of values) {
      const cell =
        document.createElement("td");

      cell.textContent =
        String(value);

      row.appendChild(cell);
    }

    els.ledgerBody.appendChild(row);
  }
}


/* ============================================================
 * Rendering — global state
 * ============================================================
 */

function render() {
  const classification =
    classifySystem();

  els.systemState.textContent =
    classificationLabel();

  els.systemState.className =
    `system-state ${classification}`;

  els.health.textContent =
    `${physicalHealth()}%`;

  els.required.textContent =
    `${satisfiedRequiredCount()} / ${requiredCapabilities().length}`;

  els.optional.textContent =
    `${activeOptionalCount()} / ${optionalCapabilities().length}`;

  els.continuations.textContent =
    String(state.continuations);

  if (classification === "normal") {
    els.stateDescription.textContent =
      "All required and optional capabilities are available.";
  }

  if (classification === "degraded") {
    els.stateDescription.textContent =
      "The system has lost capability, but its required obligations remain satisfiable.";
  }

  if (classification === "refused") {
    els.stateDescription.textContent =
      "At least one required obligation cannot currently be discharged.";
  }

  els.runningEvaluation.textContent =
    isRunning()
      ? "YES"
      : "NO";

  els.obligationEvaluation.textContent =
    obligationsSatisfiable()
      ? "YES"
      : "NO";

  els.admissibilityEvaluation.textContent =
    continuationAdmissible()
      ? "YES"
      : "NO";

  els.observation.textContent =
    observationText();

  renderCapabilities();
  renderTrajectory();
  renderLedger();
}


/* ============================================================
 * Reset
 * ============================================================
 */

function resetExperiment() {
  state.events = [];
  state.continuations = 0;
  state.attempts = 0;

  initializeCapabilities();

  render();
}


/* ============================================================
 * Event listeners
 * ============================================================
 */

els.randomFailure.addEventListener(
  "click",
  applyRandomFailure
);

els.shedOptional.addEventListener(
  "click",
  shedOptionalCapability
);

els.breakRequired.addEventListener(
  "click",
  breakRequiredCapability
);

els.attemptContinuation.addEventListener(
  "click",
  attemptContinuation
);

els.compensate.addEventListener(
  "click",
  attemptCompensation
);

els.reset.addEventListener(
  "click",
  resetExperiment
);


/* ============================================================
 * Start
 * ============================================================
 */

initializeCapabilities();
render();
JS


# ============================================================
# Experiment README
# ============================================================

cat > "$EXP/README.md" <<'MD'
# EXP 002 — Admissible Degradation

An interactive programming experiment derived from the theory of
Admissible Degradation.

## Question

How much damage can a system absorb while preserving the conditions
required for legitimate continuation?

## Experimental Claim

System health and continuation admissibility are not equivalent.

A system can lose substantial capability while remaining entitled to
continue if its required obligations remain satisfiable.

Conversely, the loss of a single required capability can make
continuation inadmissible even when most of the system remains
physically operational.

The experiment therefore treats degradation structurally rather than
as a scalar measure of surviving components.

## Apparatus

The prototype contains seven capabilities.

Four are required:

1. Preserve Identity
2. Record Disposition
3. Perform Transformation
4. Verify Result

Three are optional:

1. Extended Telemetry
2. Acceleration Cache
3. Fallback Verifier

The distinction between required and optional capability is visible
in the interface and participates directly in the admissibility
decision.

## System States

The interface reports three high-level states:

### NORMAL

All required and optional capabilities are operational.

### DEGRADED

At least one capability has been lost or deliberately shed, but every
required obligation remains satisfiable.

Continuation remains admissible.

### REFUSED

At least one required obligation is unsatisfied.

The program may still be physically running, but continuation is not
admissible.

This is the central distinction investigated by the prototype:

```text
system still runs
        !=
system may legitimately continue
```

## Physical Health

Physical health is calculated from the fraction of capabilities still
available.

This is deliberately a crude scalar.

The experiment includes the scalar so that its behavior can be
compared with the structural admissibility judgment.

A principal question is whether two systems with similar health
scores can have different continuation statuses.

## Failure

`Apply Random Failure` removes one currently operational capability.

Because the selected capability can be either required or optional,
random failure can produce different consequences despite comparable
amounts of physical damage.

`Break Required Capability` selects only from currently operational
required capabilities.

This provides a direct way to test the difference between physical
survival and obligation satisfaction.

## Shedding

`Shed Optional Capability` deliberately removes an optional
capability.

Shedding is different from accidental failure in the event ledger.

The prototype therefore preserves the distinction between:

```text
FAIL
```

and:

```text
SHED
```

even when both produce a similar reduction in physical health.

This allows later experiments to investigate whether deliberate
degradation differs operationally from uncontrolled damage.

## Compensation

The first prototype contains one explicit compensation path:

```text
Verify Result
      ↓
Fallback Verifier
```

If the primary verification capability fails while the fallback
verifier remains operational, `Attempt Compensation` can satisfy the
required verification obligation through the fallback.

The original failure is not deleted from history.

The ledger therefore preserves:

```text
FAIL-REQUIRED
COMPENSATE
```

rather than rewriting the earlier failure as though it never
occurred.

The fallback verifier is consumed from the optional capability pool
when it takes on the compensating role.

## Continuation

`Attempt Continuation` evaluates the current system configuration.

If every required obligation is satisfiable, the ledger records:

```text
CONTINUE
```

If any required obligation is unsatisfied, it records:

```text
REFUSE
```

Refusal is therefore represented as an explicit event rather than as
missing output.

## Observable State

The interface exposes:

- physical health;
- required obligations satisfied;
- optional capabilities remaining;
- number of successful continuations;
- state of every capability;
- whether the machinery is still running;
- whether required obligations remain satisfiable;
- whether continuation is admissible;
- degradation trajectory;
- append-only event ledger.

## Suggested First Runs

### Run A — Optional Loss

Reset the experiment.

Shed one optional capability.

Attempt continuation.

Expected structure:

```text
SHED
CONTINUE
```

The system should be degraded but admissible.

### Run B — Required Loss

Reset the experiment.

Break a required capability.

Attempt continuation.

Expected structure:

```text
FAIL-REQUIRED
REFUSE
```

The system may retain high physical health while continuation becomes
inadmissible.

### Run C — Compensable Required Loss

Reset the experiment.

Use `Break Required Capability` until `Verify Result` is the failed
required capability, or use random failure until that condition
occurs.

If the Fallback Verifier remains operational, attempt compensation.

Expected structure:

```text
FAIL-REQUIRED
COMPENSATE
CONTINUE
```

The system remains degraded, but the required verification obligation
has become satisfiable through a different path.

### Run D — Destroy the Fallback First

Reset the experiment.

Remove or shed the Fallback Verifier.

Then fail `Verify Result`.

Attempt compensation.

Expected structure:

```text
SHED or FAIL
FAIL-REQUIRED
COMPENSATION-FAILED
REFUSE
```

This tests whether compensation depends on actual surviving capacity
rather than being treated as a magical repair operation.

## Important Limitation

This prototype does not establish that the distinction between
required and optional capabilities is independently justified.

Those classifications are supplied by the model.

A system can therefore appear to demonstrate admissible degradation
simply because its designer has already encoded the relevant
admissibility rules.

The value of the experiment lies in exposing the consequences of
those rules and making their hidden assumptions inspectable.

## Competing Interpretation

The same behavior can be described using conventional fault-tolerance
language:

- critical components;
- noncritical components;
- fallback components;
- degraded operation;
- failure states.

The experiment does not establish that Admissible Degradation is a
new fault-tolerance mechanism.

Instead, it investigates whether the framework provides useful
distinctions about continuation, obligation, disposition, and
historical preservation that are obscured when degradation is treated
only as aggregate system health.

## Embarrassment Condition

The motivating interpretation becomes less useful if:

- aggregate physical health predicts every continuation decision;
- required and optional failures produce no important difference;
- deliberate shedding is indistinguishable from uncontrolled loss;
- compensation adds no distinction beyond ordinary component repair;
- explicit refusal adds no useful information;
- or the structural representation makes no predictions that differ
  from a simpler scalar health model.

## Results

After running the experiment, observations and proposed follow-up
experiments should be recorded in:

**[RESULTS.md](RESULTS.md)**

The results file should preserve unexpected behavior and weaknesses
of the apparatus rather than reporting only trajectories that agree
with the motivating theory.
MD


# ============================================================
# Initial results notebook
# ============================================================

if [[ ! -f "$EXP/RESULTS.md" ]]; then

cat > "$EXP/RESULTS.md" <<'MD'
# EXP 002 — Admissible Degradation

## Results and Further Investigations

This document records observations from the Admissible Degradation
prototype.

The experiment is an operationalization of a theoretical distinction.
Behavior produced by construction should not be treated as empirical
confirmation of the theory.

The useful results are expected to arise from comparisons,
counterexamples, implementation difficulties, unexpected trajectories,
and distinctions that become visible only after the theory is made
executable.

---

## Initial Questions

The first experimental runs should investigate:

1. Can systems with identical physical health have different
   continuation statuses?

2. Can a heavily degraded system remain admissible while a relatively
   intact system becomes inadmissible?

3. Does deliberate shedding produce a useful distinction from
   accidental failure?

4. Can compensation restore admissibility without restoring the
   original physical state?

5. Does preserving the original failure in the ledger matter for
   subsequent interpretation?

6. Under what conditions does compensation merely disguise repair?

7. Does explicit refusal reveal information that would otherwise be
   lost if the system simply failed to produce output?

---

## Run Log

Record representative runs below.

### Run 001

Configuration:

```text
not yet recorded
```

Trajectory:

```text
not yet recorded
```

Observation:

Not yet recorded.

### Run 002

Configuration:

```text
not yet recorded
```

Trajectory:

```text
not yet recorded
```

Observation:

Not yet recorded.

---

## Candidate Comparison

A particularly important comparison is:

```text
System A
health: 86%
required obligations: satisfied
status: DEGRADED
continuation: admissible

System B
health: 86%
required obligations: unsatisfied
status: REFUSED
continuation: inadmissible
```

If the apparatus can construct this pair, the experiment demonstrates
at least one representational limitation of scalar health: equal
aggregate survival does not uniquely determine continuation
admissibility under the model.

This does not establish that the structural classification is correct.
It establishes that the two representations encode different
information.

---

## Further Investigation

Candidate extensions include:

- multiple alternative compensation paths;
- compensation with explicit cost;
- partial rather than binary capability degradation;
- dependencies between capabilities;
- obligations that become required only under certain conditions;
- exactly-once disposition;
- compensating continuation;
- irreversible loss;
- delayed failure;
- hidden degradation;
- false-positive health;
- bounded degradation budgets;
- deliberate capability shedding;
- replay after degraded continuation;
- comparison with scalar health policies;
- comparison with conventional fault-tolerance controllers;
- adversarial failure sequences;
- path-dependent admissibility.

---

## Provisional Result

No result recorded yet.

The first objective is not to demonstrate that degradation can be
survived. Conventional fault-tolerant systems already establish that.

The more specific objective is to determine whether continuation
admissibility contains information that cannot be represented
adequately by a scalar measure of surviving system capacity.
MD

fi


# ============================================================
# Update experiment registry
# ============================================================

python3 - "$REGISTRY" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])

if not path.exists():
    raise SystemExit(
        f"ERROR: registry not found: {path}"
    )

with path.open("r", encoding="utf-8") as f:
    data = json.load(f)

if not isinstance(data, list):
    raise SystemExit(
        "ERROR: experiments.json is expected to contain a JSON array"
    )

found = False

for experiment in data:
    if experiment.get("id") == "002":
        experiment["status"] = "prototype"
        found = True
        break

if not found:
    raise SystemExit(
        "ERROR: EXP 002 not found in experiments.json"
    )

with path.open("w", encoding="utf-8") as f:
    json.dump(
        data,
        f,
        indent=2,
        ensure_ascii=False
    )
    f.write("\n")

print("Updated EXP 002 status -> prototype")
PY


# ============================================================
# Basic generated-file validation
# ============================================================

echo
echo "Validating EXP 002..."

required_files=(
  "$EXP/index.html"
  "$EXP/experiment.css"
  "$EXP/experiment.js"
  "$EXP/README.md"
  "$EXP/RESULTS.md"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "ERROR: missing generated file:"
    echo "  $file"
    exit 1
  fi
done

python3 - "$EXP" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])

checks = {
    "index.html": [
        "Admissible Degradation",
        "Experimental Claim",
        "Capability Structure",
        "Admissibility Evaluation",
        "Event Ledger",
        "Embarrassment Condition",
        'src="experiment.js"',
        'href="experiment.css"',
    ],
    "experiment.js": [
        "continuationAdmissible",
        "attemptContinuation",
        "attemptCompensation",
        "shedOptionalCapability",
        "FAIL-REQUIRED",
        "COMPENSATE",
        "REFUSE",
    ],
    "README.md": [
        "EXP 002",
        "Physical Health",
        "Compensation",
        "Embarrassment Condition",
        "RESULTS.md",
    ],
}

failures = []

for filename, strings in checks.items():
    path = root / filename
    text = path.read_text(encoding="utf-8")

    for required in strings:
        if required not in text:
            failures.append(
                f"{filename}: missing {required!r}"
            )

if failures:
    print("EXP 002 validation failed:")

    for failure in failures:
        print(f"  - {failure}")

    raise SystemExit(1)

print("EXP 002 validation passed.")
PY


# ============================================================
# Build report
# ============================================================

echo
echo "Created:"
echo
echo "  programming/experiments/admissible-degradation/index.html"
echo "  programming/experiments/admissible-degradation/experiment.css"
echo "  programming/experiments/admissible-degradation/experiment.js"
echo "  programming/experiments/admissible-degradation/README.md"
echo "  programming/experiments/admissible-degradation/RESULTS.md"
echo
echo "Registry:"
echo
echo "  EXP 002 -> prototype"
echo
echo "Next:"
echo
echo "  ./build-site.sh"
echo
echo "Then serve:"
echo
echo "  python3 -m http.server 8000"
echo
echo "Open:"
echo
echo "  http://localhost:8000/programming/experiments/admissible-degradation/"
echo
