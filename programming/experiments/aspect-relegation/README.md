# EXP 001 — Aspect Relegation

An interactive programming experiment derived from Aspect Relegation
Theory.

## Question

When can an explicitly controlled operation disappear into automatic
execution, and what forces it back into explicit control?

## Results

See **[RESULTS.md](RESULTS.md)** for observed experimental trajectories,
interpretive limitations, discoveries made while implementing and running
the prototype, and proposed directions for further investigation.

The initial experiment exposed several distinctions that were not explicit
in the original implementation, including the difference between
environmental change and task-relevant prediction error, relegation and
deletion, and restoration and relearning.

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