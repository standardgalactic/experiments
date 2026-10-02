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
