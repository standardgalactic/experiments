#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXP="$ROOT/programming/experiments/aspect-relegation"

mkdir -p "$EXP"

echo
echo "========================================"
echo " EXP / 001"
echo " Aspect Relegation"
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

  <meta name="viewport"
        content="width=device-width, initial-scale=1">

  <meta name="description"
        content="Interactive experiment in explicit control, automatic execution, perturbation, and return to explicit control.">

  <title>Aspect Relegation — EXP 001</title>

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
      Programming Experiment / 001
    </div>

    <h1>Aspect Relegation</h1>

    <p class="lede">
      When can an explicitly controlled operation disappear into
      automatic execution, and what forces it back into explicit
      control?
    </p>

    <div class="experiment-meta">
      <span>Theory: Aspect Relegation Theory</span>
      <span class="status status-prototype">prototype</span>
    </div>

  </header>


  <section>

    <div class="section-title">
      Experimental Claim
    </div>

    <div class="lab-panel">

      <p>
        Repeated successful handling of a stable operation permits
        aspects of that operation to be relegated from explicit
        control to automatic execution. Relegation is therefore not
        simple deletion. The relegated operation remains conditionally
        available to explicit control when prediction error,
        environmental change, or failure exceeds an admissible
        threshold.
      </p>

    </div>

  </section>


  <section>

    <div class="section-title">
      Apparatus
    </div>

    <div class="apparatus">

      <div class="state-panel">

        <div class="state-label">
          CURRENT CONTROL STATE
        </div>

        <div id="control-state"
             class="control-state explicit">
          EXPLICIT
        </div>

        <div id="state-description"
             class="state-description">
          Operation is under explicit control.
        </div>

      </div>


      <div class="metrics">

        <div class="metric">
          <span id="trial-value"
                class="metric-value">0</span>
          <span class="metric-label">trial</span>
        </div>

        <div class="metric">
          <span id="success-value"
                class="metric-value">0</span>
          <span class="metric-label">stable successes</span>
        </div>

        <div class="metric">
          <span id="error-value"
                class="metric-value">0.00</span>
          <span class="metric-label">prediction error</span>
        </div>

        <div class="metric">
          <span id="environment-value"
                class="metric-value">A</span>
          <span class="metric-label">environment</span>
        </div>

      </div>

    </div>

  </section>


  <section>

    <div class="section-title">
      Experimental Controls
    </div>

    <div class="control-grid">

      <div class="control-box">

        <label for="relegation-threshold">
          Successful repetitions before relegation
        </label>

        <input
          id="relegation-threshold"
          type="range"
          min="1"
          max="12"
          value="5">

        <output id="relegation-output">
          5
        </output>

      </div>


      <div class="control-box">

        <label for="return-threshold">
          Error threshold for return to explicit control
        </label>

        <input
          id="return-threshold"
          type="range"
          min="0"
          max="100"
          value="35">

        <output id="return-output">
          0.35
        </output>

      </div>

    </div>


    <div class="button-row">

      <button id="run-trial">
        Run Stable Trial
      </button>

      <button id="run-series">
        Run 10 Trials
      </button>

      <button id="perturb">
        Perturb Environment
      </button>

      <button id="restore">
        Restore Environment
      </button>

      <button id="reset">
        Reset Experiment
      </button>

    </div>

  </section>


  <section>

    <div class="section-title">
      Control Trajectory
    </div>

    <div id="trajectory"
         class="trajectory">

      <div class="trajectory-empty">
        No trials recorded.
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
            <th>control</th>
            <th>environment</th>
            <th>error</th>
            <th>successes</th>
          </tr>
        </thead>

        <tbody id="ledger-body">
        </tbody>

      </table>

      <div id="ledger-empty"
           class="ledger-empty">
        No events recorded.
      </div>

    </div>

  </section>


  <section>

    <div class="section-title">
      Manipulation
    </div>

    <div class="lab-panel">

      <p>
        Relegation threshold and return threshold are independently
        adjustable. Stable trials reinforce the currently successful
        operation. Perturbation changes the environment while leaving
        the automatic operation initially unchanged. This creates a
        mismatch between the learned operation and its conditions.
      </p>

    </div>

  </section>


  <section>

    <div class="section-title">
      Observation
    </div>

    <div class="lab-panel">

      <p id="observation">
        No observation yet. Run repeated stable trials and watch for
        the transition from explicit to automatic control.
      </p>

    </div>

  </section>


  <section>

    <div class="section-title">
      Competing Interpretation
    </div>

    <div class="lab-panel">

      <p>
        The behavior could be explained without invoking a distinct
        relegation process. A sufficiently ordinary thresholded
        controller with cached behavior can produce the same state
        transitions. The experiment therefore operationalizes a
        distinction proposed by Aspect Relegation Theory; it does not
        by itself establish that human cognition implements this
        particular mechanism.
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
        automatic execution cannot be distinguished experimentally
        from simple persistence, if environmental mismatch provides
        no principled reason for return to explicit control, or if
        the same observations are explained equally well without
        distinguishing explicit and relegated aspects.
      </p>

    </div>

  </section>


  <footer>
    <span>
      standardgalactic / experiments / programming
    </span>

    <span>
      EXP 001 / prototype
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
  grid-template-columns: 1.2fr 2fr;
  gap: 1px;
  background: var(--line);
  border: 1px solid var(--line);
}

.state-panel {
  min-height: 260px;
  padding: 1.5rem;
  background: var(--panel);
}

.state-label {
  color: var(--muted);
  font-size: 0.67rem;
  letter-spacing: 0.12em;
}

.control-state {
  margin-top: 3.5rem;
  font-size: clamp(2.2rem, 7vw, 4.7rem);
  line-height: 1;
  letter-spacing: -0.06em;
}

.control-state.explicit {
  color: var(--accent);
}

.control-state.automatic {
  color: var(--active);
}

.state-description {
  margin-top: 1rem;
  max-width: 360px;
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

.control-grid {
  display: grid;
  grid-template-columns:
    repeat(auto-fit, minmax(280px, 1fr));
  gap: 1px;
  border: 1px solid var(--line);
  background: var(--line);
}

.control-box {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 1rem;
  padding: 1.4rem;
  background: var(--panel);
}

.control-box label {
  grid-column: 1 / -1;
  color: var(--muted);
  font-size: 0.78rem;
  line-height: 1.5;
}

.control-box input {
  width: 100%;
}

.control-box output {
  min-width: 4rem;
  text-align: right;
}

.button-row {
  display: flex;
  flex-wrap: wrap;
  gap: 0.6rem;
  margin-top: 1rem;
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

.trajectory {
  display: flex;
  min-height: 90px;
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
  width: 34px;
  min-width: 34px;
  height: 34px;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--line2);
  font-size: 0.65rem;
}

.trajectory-node.explicit {
  color: var(--accent);
  border-color: var(--accent);
}

.trajectory-node.automatic {
  color: var(--active);
  border-color: var(--active);
}

.trajectory-node.perturbation {
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
  font-size: 0.72rem;
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

@media (max-width: 700px) {
  .apparatus {
    grid-template-columns: 1fr;
  }

  .metrics {
    grid-template-columns: 1fr 1fr;
  }
}
CSS


# ============================================================
# Experiment logic
# ============================================================

cat > "$EXP/experiment.js" <<'JS'
"use strict";

const state = {
  trial: 0,
  stableSuccesses: 0,
  predictionError: 0,
  environment: "A",
  control: "explicit",
  events: []
};

const els = {
  controlState: document.getElementById("control-state"),
  stateDescription: document.getElementById("state-description"),

  trial: document.getElementById("trial-value"),
  successes: document.getElementById("success-value"),
  error: document.getElementById("error-value"),
  environment: document.getElementById("environment-value"),

  relegationThreshold:
    document.getElementById("relegation-threshold"),

  relegationOutput:
    document.getElementById("relegation-output"),

  returnThreshold:
    document.getElementById("return-threshold"),

  returnOutput:
    document.getElementById("return-output"),

  runTrial:
    document.getElementById("run-trial"),

  runSeries:
    document.getElementById("run-series"),

  perturb:
    document.getElementById("perturb"),

  restore:
    document.getElementById("restore"),

  reset:
    document.getElementById("reset"),

  trajectory:
    document.getElementById("trajectory"),

  ledgerBody:
    document.getElementById("ledger-body"),

  ledgerEmpty:
    document.getElementById("ledger-empty"),

  observation:
    document.getElementById("observation")
};


function relegationThreshold() {
  return Number(
    els.relegationThreshold.value
  );
}


function returnThreshold() {
  return Number(
    els.returnThreshold.value
  ) / 100;
}


function record(event) {
  state.events.push({
    n: state.events.length + 1,
    event,
    trial: state.trial,
    control: state.control,
    environment: state.environment,
    error: state.predictionError,
    successes: state.stableSuccesses
  });
}


function updateControls() {
  els.relegationOutput.textContent =
    String(relegationThreshold());

  els.returnOutput.textContent =
    returnThreshold().toFixed(2);
}


function updateObservation() {
  if (state.events.length === 0) {
    els.observation.textContent =
      "No observation yet. Run repeated stable trials and watch " +
      "for the transition from explicit to automatic control.";

    return;
  }

  if (
    state.control === "automatic" &&
    state.environment === "A"
  ) {
    els.observation.textContent =
      "The operation is currently relegated to automatic control " +
      "after repeated successful execution under stable conditions.";

    return;
  }

  if (
    state.control === "explicit" &&
    state.environment === "B" &&
    state.predictionError >= returnThreshold()
  ) {
    els.observation.textContent =
      "Environmental change produced prediction error above the " +
      "return threshold. The operation has returned to explicit " +
      "control.";

    return;
  }

  if (
    state.control === "automatic" &&
    state.environment === "B"
  ) {
    els.observation.textContent =
      "The environment has changed, but accumulated prediction " +
      "error has not yet crossed the threshold required to return " +
      "the operation to explicit control.";

    return;
  }

  els.observation.textContent =
    "The operation remains under explicit control while stable " +
    "experience accumulates.";
}


function renderTrajectory() {
  els.trajectory.innerHTML = "";

  if (state.events.length === 0) {
    const empty = document.createElement("div");

    empty.className = "trajectory-empty";
    empty.textContent = "No trials recorded.";

    els.trajectory.appendChild(empty);
    return;
  }

  for (const event of state.events) {
    const node = document.createElement("div");

    node.className =
      "trajectory-node " +
      (
        event.event === "PERTURB"
          ? "perturbation"
          : event.control
      );

    if (event.event === "PERTURB") {
      node.textContent = "Δ";
    } else if (event.control === "automatic") {
      node.textContent = "A";
    } else {
      node.textContent = "E";
    }

    node.title =
      `${event.n}: ${event.event} / ` +
      `${event.control} / env ${event.environment}`;

    els.trajectory.appendChild(node);
  }
}


function renderLedger() {
  els.ledgerBody.innerHTML = "";

  els.ledgerEmpty.style.display =
    state.events.length === 0
      ? "block"
      : "none";

  for (const event of state.events) {
    const row = document.createElement("tr");

    const values = [
      event.n,
      event.event,
      event.control,
      event.environment,
      event.error.toFixed(2),
      event.successes
    ];

    for (const value of values) {
      const cell = document.createElement("td");

      cell.textContent = String(value);

      row.appendChild(cell);
    }

    els.ledgerBody.appendChild(row);
  }
}


function render() {
  els.trial.textContent =
    String(state.trial);

  els.successes.textContent =
    String(state.stableSuccesses);

  els.error.textContent =
    state.predictionError.toFixed(2);

  els.environment.textContent =
    state.environment;

  els.controlState.textContent =
    state.control.toUpperCase();

  els.controlState.className =
    "control-state " + state.control;

  if (state.control === "explicit") {
    els.stateDescription.textContent =
      "Operation is under explicit control.";
  } else {
    els.stateDescription.textContent =
      "Operation has been relegated to automatic execution.";
  }

  updateControls();
  updateObservation();
  renderTrajectory();
  renderLedger();
}


function maybeRelegate() {
  if (
    state.control === "explicit" &&
    state.environment === "A" &&
    state.stableSuccesses >= relegationThreshold()
  ) {
    state.control = "automatic";

    record("RELEGATE");
  }
}


function maybeReturnToExplicit() {
  if (
    state.control === "automatic" &&
    state.predictionError >= returnThreshold()
  ) {
    state.control = "explicit";
    state.stableSuccesses = 0;

    record("RETURN");
  }
}


function runTrial() {
  state.trial += 1;

  if (state.environment === "A") {
    state.predictionError =
      Math.max(
        0,
        state.predictionError - 0.12
      );

    state.stableSuccesses += 1;

    record("SUCCESS");

    maybeRelegate();

    render();
    return;
  }

  /*
   * Environment B differs from the conditions under which the
   * operation was learned.
   *
   * Explicit control adapts quickly.
   * Automatic control initially persists and accumulates error.
   */

  if (state.control === "automatic") {
    state.predictionError =
      Math.min(
        1,
        state.predictionError + 0.18
      );

    record("MISMATCH");

    maybeReturnToExplicit();

    render();
    return;
  }

  /*
   * Explicit control can inspect the changed environment and
   * gradually adapt.
   */

  state.predictionError =
    Math.max(
      0,
      state.predictionError - 0.15
    );

  state.stableSuccesses += 1;

  record("ADAPT");

  render();
}


function perturbEnvironment() {
  if (state.environment === "B") {
    return;
  }

  state.environment = "B";

  record("PERTURB");

  render();
}


function restoreEnvironment() {
  if (state.environment === "A") {
    return;
  }

  state.environment = "A";

  state.predictionError =
    Math.min(
      state.predictionError,
      0.10
    );

  state.stableSuccesses = 0;

  record("RESTORE");

  render();
}


function resetExperiment() {
  state.trial = 0;
  state.stableSuccesses = 0;
  state.predictionError = 0;
  state.environment = "A";
  state.control = "explicit";
  state.events = [];

  render();
}


els.relegationThreshold.addEventListener(
  "input",
  () => {
    updateControls();
    maybeRelegate();
    render();
  }
);


els.returnThreshold.addEventListener(
  "input",
  () => {
    updateControls();
    maybeReturnToExplicit();
    render();
  }
);


els.runTrial.addEventListener(
  "click",
  runTrial
);


els.runSeries.addEventListener(
  "click",
  () => {
    for (let i = 0; i < 10; i += 1) {
      runTrial();
    }
  }
);


els.perturb.addEventListener(
  "click",
  perturbEnvironment
);


els.restore.addEventListener(
  "click",
  restoreEnvironment
);


els.reset.addEventListener(
  "click",
  resetExperiment
);


render();
JS


# ============================================================
# Experiment README
# ============================================================

cat > "$EXP/README.md" <<'MD'
# EXP 001 — Aspect Relegation

An interactive programming experiment derived from Aspect Relegation
Theory.

## Question

When can an explicitly controlled operation disappear into automatic
execution, and what forces it back into explicit control?

## Apparatus

The experiment contains a minimal controller with two control states:

- explicit
- automatic

The controller operates in one of two environments:

- A: the stable environment under which the operation is learned
- B: a perturbed environment

Repeated successful trials accumulate stable experience.

Once the relegation threshold is reached, the operation moves from
explicit control to automatic execution.

A perturbation changes the environment without immediately changing
the automatic operation. Continued automatic execution therefore
accumulates prediction error.

When prediction error exceeds the return threshold, control returns
to the explicit state.

## Manipulated Variables

Two thresholds are exposed:

1. successful repetitions required for relegation
2. prediction error required for return to explicit control

The environment can also be directly perturbed and restored.

## Observable State

The interface exposes:

- trial count
- stable-success count
- prediction error
- environment
- control state
- control trajectory
- append-only event ledger

## Important Limitation

The program operationalizes a distinction proposed by Aspect
Relegation Theory.

It does not establish that this state machine is a model of the
mechanism used by human cognition.

A conventional thresholded controller with cached behavior can
produce similar observations.

## Embarrassment Condition

The motivating interpretation becomes less useful if:

- automatic execution cannot be experimentally distinguished from
  simple persistence;
- environmental mismatch supplies no principled reason for returning
  an operation to explicit control;
- or the observed behavior is fully captured without distinguishing
  explicit and relegated aspects.

MD


# ============================================================
# Update registry status
# ============================================================

python3 - "$ROOT/programming/experiments.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])

with path.open("r", encoding="utf-8") as f:
    data = json.load(f)

found = False

for exp in data:
    if exp.get("id") == "001":
        exp["status"] = "prototype"
        found = True
        break

if not found:
    raise SystemExit(
        "ERROR: EXP 001 not found in experiments.json"
    )

with path.open("w", encoding="utf-8") as f:
    json.dump(
        data,
        f,
        indent=2,
        ensure_ascii=False
    )
    f.write("\n")

print("Updated EXP 001 status -> prototype")
PY


echo
echo "Created:"
echo
echo "  programming/experiments/aspect-relegation/index.html"
echo "  programming/experiments/aspect-relegation/experiment.css"
echo "  programming/experiments/aspect-relegation/experiment.js"
echo "  programming/experiments/aspect-relegation/README.md"
echo
echo "Now rebuild the catalog:"
echo
echo "  ./build-site.sh"
echo
echo "Then serve:"
echo
echo "  python3 -m http.server 8000"
echo
echo "Open:"
echo
echo "  http://localhost:8000/programming/experiments/aspect-relegation/"
echo
