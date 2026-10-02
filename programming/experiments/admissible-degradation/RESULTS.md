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

## First Findings

1. Physical survival and continuation admissibility diverge.

2. Inadmissibility and refusal are distinct:
   inadmissibility is a condition;
   refusal is an event produced when continuation is attempted.

3. Failed compensation has multiple causes:
   nothing requires compensation;
   an obligation is unsatisfied but no compensation path exists.

4. Shedding and failure both reduce available capability but have
   different histories and potentially different meanings.

5. "Physical health" currently conflates physical integrity with
   available capability.

6. Compensation appears to be obligation-relative rather than a
   generic system operation.

7. A compact trajectory loses distinctions that the event ledger
   preserves.
