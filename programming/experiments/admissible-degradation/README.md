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
