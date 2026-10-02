# EXP 001 — Aspect Relegation

## Results and Further Investigations

This document records observations made while running the Aspect Relegation experiment. It is not intended to establish Aspect Relegation Theory by construction. The program is an operational model designed to expose assumptions, transitions, failure conditions, and possible extensions of the theory.

The important result of the prototype is therefore not that the programmed system behaves as programmed. It is that making the proposed distinction executable reveals questions that are less obvious in the verbal formulation.

---

## 1. Initial Experimental Configuration

The prototype represents two control states:

- `explicit`
- `automatic`

and two environments:

- `A` — the initially stable environment
- `B` — a perturbed environment

Two parameters can be manipulated:

1. the number of successful repetitions required before an operation is relegated to automatic control;
2. the accumulated prediction error required before an automatic operation returns to explicit control.

The experiment records each significant transition in an append-only event ledger.

The principal event types are:

- `SUCCESS`
- `RELEGATE`
- `PERTURB`
- `MISMATCH`
- `RETURN`
- `ADAPT`
- `RESTORE`

This makes the trajectory of the controller observable independently of its terminal state.

---

## 2. Observed Run

One representative run used:

- relegation threshold: `5`
- return-to-explicit threshold: `0.35`
- mismatch increment: `0.18`
- explicit adaptation decrement: `0.15`

The observed trajectory was:

```text
explicit A
    ↓
5 successful repetitions
    ↓
automatic A
    ↓
continued successful automatic execution
    ↓
perturb A → B
    ↓
automatic B
    ↓
mismatch: error 0.18
    ↓
mismatch: error 0.36
    ↓
return to explicit control
    ↓
explicit adaptation in B
    ↓
error 0.21
    ↓
error 0.06
    ↓
error 0.00
    ↓
restore B → A
    ↓
explicit A
    ↓
5 successful repetitions
    ↓
automatic A
```

The event ledger contained 35 events over the complete trajectory.

---

## 3. Perturbation Is Not Error

The first implementation coupled environmental perturbation directly to prediction error. Changing the environment from A to B immediately assigned an error of `0.18`.

This was revised.

In the revised experiment:

```text
PERTURB
```

changes the environment but produces no prediction error by itself.

Prediction error appears only when the currently relegated operation is subsequently executed under conditions with which it is incompatible:

```text
PERTURB   automatic   B   0.00
MISMATCH  automatic   B   0.18
MISMATCH  automatic   B   0.36
RETURN    explicit    B   0.36
```

This distinction is important.

Environmental novelty is not identical to task-relevant error. A world can change without the change mattering to a particular relegated operation.

The revised prototype therefore suggests a useful distinction:

> A change in conditions is not sufficient for de-relegation. The change must become operationally relevant.

This may be one of the first useful consequences exposed by the implementation.

---

## 4. Relegation Is Not Deletion

The experiment was originally motivated by the idea that automatic execution should not be represented as the disappearance of an operation.

The transition

```text
explicit → automatic
```

does not remove the operation from the system. Instead, it changes how the operation participates in control.

The subsequent trajectory demonstrates why this matters:

```text
automatic
    ↓
mismatch
    ↓
automatic
    ↓
mismatch
    ↓
explicit
```

The possibility of `RETURN` is part of what distinguishes relegation from deletion.

An operation that has disappeared cannot be returned to explicit control. A relegated operation remains available under altered control conditions.

---

## 5. Relegation and Return Are Asymmetric

The experiment revealed an asymmetry between relegation and return.

Relegation requires accumulated evidence:

```text
SUCCESS
SUCCESS
SUCCESS
SUCCESS
SUCCESS
RELEGATE
```

Return to explicit control also requires accumulated evidence:

```text
MISMATCH
MISMATCH
RETURN
```

But the two accumulations have different meanings.

The first establishes sufficient stability to stop spending explicit control on an operation.

The second establishes sufficient incompatibility to make continued automatic execution inadmissible.

This suggests that relegation and return should not necessarily be modeled as opposite movements along a single scalar.

They may instead be different decisions governed by different evidence.

---

## 6. The Event Is Not the Trial

The implementation also exposed a useful representational distinction.

In the prototype, the number of ledger events can exceed the number of trials. For example, the trial that reaches the relegation threshold can produce both:

```text
SUCCESS
RELEGATE
```

Similarly, a mismatch can produce:

```text
MISMATCH
RETURN
```

The state transition is therefore recorded independently from the trial that caused it.

This makes the event ledger more informative than a sequence containing only task outcomes.

The distinction should be preserved in later versions.

---

## 7. A Limitation Exposed by Environment B

The current prototype allows relegation only in environment A.

After the controller returns to explicit control in environment B, repeated `ADAPT` events reduce prediction error to zero:

```text
ADAPT   explicit   B   0.21
ADAPT   explicit   B   0.06
ADAPT   explicit   B   0.00
```

Further successful adaptation continues, but B never becomes automatic.

This is not a result of Aspect Relegation Theory. It is an artifact of the current implementation.

The prototype therefore exposes an assumption that should not be silently retained:

> Is relegation attached to an operation globally, or to an operation under a particular set of conditions?

The present experiment cannot answer this because its implementation privileges environment A.

---

## 8. A Limitation Exposed by Restoration

When environment B is restored to A, the current prototype resets accumulated stable successes:

```text
RESTORE   explicit   A   0.00   0
```

The controller must then accumulate five new successes before A is relegated again.

This effectively treats restoration as forgetting.

That behavior was not derived from the theory. It was an implementation choice.

The experiment therefore raises another question:

> Does a relegated aspect survive periods in which its enabling context is absent?

If it does, returning to a previously mastered environment may reactivate an existing relegated disposition rather than require complete reacquisition.

This distinction should be investigated rather than decided by the prototype.

---

## 9. Relegation May Be Context-Specific

The preceding limitation suggests that a single global variable such as

```text
control = explicit | automatic
```

may be too coarse.

A later experiment could instead represent dispositions by context:

```text
A:
    learned: true
    relegated: true

B:
    learned: true
    relegated: false
```

or eventually:

```text
operation × context → control disposition
```

This would permit several experimentally distinct cases:

```text
A → learned → relegated
B → novel → explicit
B → learned → relegated
A → restored → previously relegated
```

The important question is not merely whether automaticity exists, but what identifies the conditions under which a relegated aspect remains admissible.

---

## 10. Further Investigation: Relevant and Irrelevant Perturbations

The current experiment has only one perturbation, and that perturbation necessarily produces mismatch when automatic execution continues.

A stronger experiment should distinguish at least two kinds of environmental change:

```text
irrelevant perturbation
relevant perturbation
```

An irrelevant perturbation would change observable environmental state without changing the conditions required by the relegated operation.

Expected trajectory:

```text
automatic
    ↓
irrelevant perturbation
    ↓
automatic
```

A relevant perturbation would invalidate an assumption required by the operation:

```text
automatic
    ↓
relevant perturbation
    ↓
mismatch
    ↓
return
```

This would test the stronger proposition suggested by the first prototype:

> Novelty alone should not recruit explicit control. Operationally relevant mismatch should.

---

## 11. Further Investigation: Persistence Versus Relegation

The current state machine can be reproduced using conventional threshold logic.

That creates an important competing interpretation.

Perhaps nothing specifically resembling "relegation" is required. The observed behavior may simply be:

```text
cached behavior
+
error accumulation
+
threshold switching
```

A later experiment should therefore implement competing controllers against the same perturbation sequence.

For example:

```text
Controller A — Aspect Relegation
Controller B — Cached Persistence
Controller C — Always Explicit
Controller D — Immediate Novelty Response
```

The useful question would then become whether these architectures generate distinguishable trajectories under carefully selected conditions.

This is preferable to constructing only systems that instantiate the theory by definition.

---

## 12. Further Investigation: Hysteresis

The current experiment already suggests a possible hysteresis structure.

The conditions required to enter automatic control need not be identical to the conditions required to leave it.

For example:

```text
relegate after:
    5 stable successes

return after:
    prediction error > 0.35
```

This means that the system's present control state depends partly on its trajectory, not merely on its instantaneous environment.

Two systems occupying apparently identical external conditions could therefore behave differently because one arrived there through explicit acquisition and the other through prior relegation.

This deserves a dedicated experiment.

---

## 13. Further Investigation: Partial Relegation

The present prototype relegates the entire operation.

Aspect Relegation Theory may be more interesting if relegation applies to aspects rather than whole tasks.

A compound operation could contain:

```text
perception
classification
selection
execution
verification
```

Different components might become relegated at different rates.

For example:

```text
perception       automatic
classification   automatic
selection        explicit
execution        automatic
verification     explicit
```

A perturbation could then selectively invalidate one aspect while leaving the others automatic.

This would provide a much stronger operational interpretation of the word *aspect* in Aspect Relegation Theory.

---

## 14. Further Investigation: False Fluency

Another useful condition would allow automatic execution to remain apparently successful despite a hidden change in task conditions.

The sequence might be:

```text
relegation
    ↓
environment changes
    ↓
output remains superficially acceptable
    ↓
no immediate prediction error
    ↓
latent divergence accumulates
```

This would test cases in which smooth execution is not evidence that relegation remains appropriate.

It would also connect Aspect Relegation Theory to the broader problem of smooth observable behavior concealing changes in the process that produces it.

---

## 15. Further Investigation: Cost of Explicit Control

The current prototype gives automaticity no computational advantage. Explicit and automatic trials are equally cheap.

That removes an important reason why relegation might exist.

A later version could assign explicit processing a measurable cost:

```text
explicit:
    higher latency
    greater computational expenditure
    greater adaptability

automatic:
    lower latency
    lower computational expenditure
    reduced sensitivity to change
```

Relegation would then create a genuine tradeoff rather than merely changing a label.

The question could become:

> Under what environmental stability does the reduced cost of relegation compensate for its increased vulnerability to unrecognized change?

---

## 16. Further Investigation: Recovery Cost

Returning to explicit control currently occurs immediately once the error threshold is crossed.

Real systems may incur a recovery cost.

Possible variables include:

- number of failed executions before mismatch is recognized;
- delay between detection and explicit recruitment;
- cost of reconstructing previously relegated distinctions;
- persistence of automatic responses after explicit control returns;
- interference between old and newly learned dispositions.

These would allow de-relegation to become an experimental object rather than a single state assignment.

---

## 17. Further Investigation: Multiple Relegated Contexts

A later version should test whether the same operation can support multiple context-specific automatic dispositions.

For example:

```text
A → automatic strategy α
B → automatic strategy β
C → explicit because novel
```

Returning from B to A could then test retrieval rather than relearning.

This would distinguish:

```text
relegation
forgetting
suppression
contextual retrieval
relearning
```

which are collapsed together in the present prototype.

---

## 18. Further Investigation: Adversarial Perturbation

The present environmental change is obvious to the simulator.

A stronger perturbation would preserve most features of environment A while altering only one condition required by the automatic operation.

This would permit measurement of how far a perturbation can depart from the learned context before explicit control is recruited.

Rather than treating environment as simply:

```text
A | B
```

a later experiment could represent it as a vector of features.

The system could then be tested across controlled distances from its learned context.

---

## 19. Further Investigation: Embarrassment Tests

Future experiments should be designed to create outcomes that would count against the usefulness of the proposed distinction.

Useful tests include conditions in which:

- irrelevant novelty repeatedly causes de-relegation;
- highly relevant mismatch fails to recruit explicit control;
- supposedly relegated and explicitly controlled operations have indistinguishable costs and sensitivities;
- context-specific memory adds no explanatory or predictive value;
- a simpler persistence controller reproduces every trajectory of interest;
- partial relegation produces no behavior distinguishable from whole-operation switching.

The aim should not be to make the theory survive every implementation.

The aim should be to discover which distinctions have computational consequences.

---

## 20. Provisional Result

EXP 001 does not provide evidence that Aspect Relegation Theory describes human cognition.

It does provide an executable operationalization that has already exposed distinctions hidden by the initial verbal formulation.

The most important are:

1. environmental change is not prediction error;
2. prediction error requires an encounter between an operation and conditions relevant to that operation;
3. relegation is distinct from deletion because return remains possible;
4. relegation and return need not be symmetric processes;
5. events and trials are different units of description;
6. a single global explicit/automatic state is probably too coarse;
7. restoration raises a distinction between forgetting, persistence, and contextual retrieval;
8. automaticity becomes more meaningful when its computational benefits and liabilities are made measurable.

The prototype therefore succeeds primarily as a **theory-discovery apparatus**.

Programming the theory has not verified it. It has made its hidden commitments inspectable.

---

## Next Experiments

The strongest immediate successors to EXP 001 are:

- **EXP 001A — Relevant vs. Irrelevant Perturbation**
- **EXP 001B — Context-Specific Relegation**
- **EXP 001C — Relegation vs. Cached Persistence**
- **EXP 001D — Partial Relegation**
- **EXP 001E — Cost of Explicit Control**
- **EXP 001F — False Fluency**
- **EXP 001G — Contextual Recall vs. Relearning**

These should remain separate experimental variants rather than being folded immediately into the original prototype. Preserving EXP 001 in its current form retains the trajectory by which the later questions became visible.
