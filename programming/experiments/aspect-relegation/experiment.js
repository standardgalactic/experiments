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
