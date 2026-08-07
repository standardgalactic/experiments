# experiments

[The Essay as a Pipeline](https://standardgalactic.github.io/experiments/essay-as-pipeline.pdf)

`experiments` is a small command-line laboratory for experimenting with local language models as components in persistent, inspectable writing pipelines.

The project currently uses Ollama with `granite4.1:3b` and `granite4.1:8b`. Rather than asking a single model to generate a finished essay in one pass, the pipeline separates writing into explicit stages and saves the result of each stage as an ordinary Markdown file.

The basic trajectory is:

```text
topic
  ↓
outline
  ↓
draft
  ↓
review
  ↓
revision
  ↓
essay
```

The smaller 3B model performs inexpensive generative work. The larger 8B model is used where stronger critical judgment is useful, particularly during review. The resulting review is then externalized as text that can be consumed by another stage.

The point is not simply to produce essays. The repository is an experiment in whether heterogeneous models can divide cognitive labor through persistent intermediate representations.

## Requirements

The current scripts assume a Linux or WSL environment with Bash, Python 3, Ollama, and the required Granite models installed locally.

Check that Ollama is available with:

```bash
ollama --version
```

The models used by the current configuration are:

```text
granite4.1:3b
granite4.1:8b
```

They can be checked with:

```bash
ollama list
```

If necessary, pull them with:

```bash
ollama pull granite4.1:3b
ollama pull granite4.1:8b
```

The project deliberately avoids requiring a large orchestration framework. Files, shell scripts, and ordinary command-line tools provide most of the infrastructure.

## Repository Structure

A typical repository looks approximately like this:

```text
.
├── README.md
├── compare-models.sh
├── essay-pipeline.sh
├── file-list.txt
├── granite-essay.sh
├── logs/
├── output/
├── output.txt
├── prompts/
│   ├── draft.txt
│   ├── outline.txt
│   ├── review.txt
│   └── revise.txt
├── review-essay.sh
├── scripts/
│   ├── common.sh
│   └── render-prompt.py
├── test-models.sh
├── test.sh
└── three-essays.sh
```

The scripts are intentionally separated from the prompts and generated artifacts. This makes it possible to change the writing protocol without rewriting the orchestration code and to change the orchestration without silently modifying previous outputs.

## Running an Essay

The main pipeline accepts a topic and constructs a working directory for that essay.

For example:

```bash
./essay-pipeline.sh \
  "Why technological capability should diffuse rather than merely accumulate"
```

A completed run produces a directory similar to:

```text
output/
└── why-technological-capability-should-diffuse-rather-than-merely-accumulate/
    ├── topic.txt
    ├── outline.md
    ├── draft.md
    ├── review.md
    └── essay.md
```

The terminal output reports the locations of the generated artifacts when the run completes.

For example:

```text
============================================
 COMPLETE
============================================

Topic:
    Why technological capability should diffuse rather than merely accumulate

Outline:
    output/why-technological-capability-should-diffuse-rather-than-merely-accumulate/outline.md

Draft:
    output/why-technological-capability-should-diffuse-rather-than-merely-accumulate/draft.md

Review:
    output/why-technological-capability-should-diffuse-rather-than-merely-accumulate/review.md

Final essay:
    output/why-technological-capability-should-diffuse-rather-than-merely-accumulate/essay.md
```

Each file is intentionally retained. The final essay does not replace the states that produced it.

## The Pipeline

The first stage turns the topic into an argumentative outline. The outline acts as an intermediate representation rather than merely a shorter essay. It establishes the thesis, conceptual distinctions, argumentative dependencies, objections, and intended development before long-form generation begins.

The draft stage uses that outline to construct the first complete essay. Because the outline survives independently, the draft can later be inspected for drift from the original conceptual structure.

The review stage passes the draft to the stronger model. The reviewer is asked to diagnose weaknesses rather than silently rewrite the essay. This distinction is important to the experiment: recognizing a defect and repairing a defect are treated as different computational operations.

The revision stage receives the draft together with the review and attempts to produce the final `essay.md`. The resulting artifact can therefore be compared against both its predecessor and the diagnosis that motivated its modification.

The complete process can be represented as:

```text
T → O → D → R → F
```

where (T) is the topic, (O) the outline, (D) the draft, (R) the review, and (F) the revised essay.

The repository preserves the intermediate states because the trajectory itself is part of the experiment.

## Running Multiple Experiments

`three-essays.sh` runs several topics sequentially through the same pipeline.

The current experiments include topics such as:

```text
Why admissibility is a stronger concept than optimization for understanding persistent systems

Why continuation should be treated as a property of trajectories rather than states

Why repair that eliminates difference can be a form of system failure
```

Running:

```bash
./three-essays.sh
```

creates an independent output directory for each topic.

This makes it possible to observe whether the same pipeline behavior recurs across related theoretical problems rather than judging the architecture from a single essay.

## Comparing Models

`compare-models.sh` and `test-models.sh` provide simple experiments for comparing the locally installed models.

The purpose is not to assume that the larger model is universally superior. Different stages may require different capabilities. A smaller model may be entirely adequate for expanding a well-specified outline while a larger model may provide greater marginal value when detecting conceptual inconsistencies.

The present allocation should therefore be regarded as an experimental hypothesis rather than a permanent architectural rule.

Future comparisons can test configurations such as:

```text
3B → 3B → 3B → 3B

8B → 8B → 8B → 8B

3B → 3B → 8B → 3B

3B → 3B → 8B → 8B
```

Because intermediate artifacts are saved, individual stages can eventually be compared while holding their inputs fixed.

## Prompts

The `prompts/` directory contains the instructions used by the individual stages:

```text
prompts/outline.txt
prompts/draft.txt
prompts/review.txt
prompts/revise.txt
```

Prompts are stored as files rather than embedded deeply inside shell scripts because they are part of the experimental configuration.

Changing a review prompt changes the reviewer.

Changing a drafting prompt changes the transformation from outline to prose.

Keeping these representations external makes such changes visible and versionable.

`scripts/render-prompt.py` performs the small amount of prompt assembly needed to insert the current artifacts into these templates.

## Why Files Instead of an Agent Framework?

The project intentionally uses the filesystem as its primary persistent memory.

A model invocation is temporary. A file is not.

Once an outline or review has been written to disk, it can be inspected by a human, passed to another model, compared with another run, processed by a script, committed to Git, or reused after the model that produced it has been replaced.

This means that continuity belongs primarily to the repository rather than to any individual model process.

The architecture can therefore survive changes in its components. Granite can be replaced with another model. Ollama can eventually be replaced with another inference runtime. Bash scripts can be revised. Prompt protocols can change. Earlier experimental states remain ordinary files.

The working principle is:

```text
persist the project; replace the processor
```

## Why Preserve the Draft and Review?

The intermediate files are not debugging debris.

Suppose the final essay contains a conceptual error. If only `essay.md` exists, it may be impossible to determine where the error originated. With the complete trajectory, the investigator can ask whether the error already existed in the outline, appeared during drafting, was noticed by the reviewer, and was successfully or unsuccessfully addressed during revision.

For example:

```text
outline: distinction correct
draft: distinction lost
review: defect identified
essay: defect remains
```

This tells us something much more specific than saying that the model produced a bad essay.

The failure occurred during drafting, diagnosis succeeded, and repair failed.

That distinction is one of the principal reasons for the architecture.

## Git and Experimental History

Git provides another level of persistence.

The files inside an essay directory preserve the trajectory of one generation. Git preserves the trajectory of the experimental apparatus itself.

Prompts can change without erasing their predecessors. Scripts can be repaired without pretending that earlier versions never existed. Failed experiments can remain available as evidence about why later changes were made.

The current working tree is revisable while historical existence remains monotonic.

This makes the repository closer to an executable laboratory notebook than a conventional content-generation application.

## `icepick.sh`

`icepick.sh` can be used to flatten the textual state of the project into a single inspectable file.

Its purpose is to concatenate the relevant scripts, prompts, Markdown artifacts, and other text files while avoiding binary or irrelevant generated data.

This is useful for auditing the complete experiment, supplying the project to another model for analysis, creating snapshots, or simply inspecting the repository without opening every file individually.

A typical invocation is:

```bash
./icepick.sh > output.txt
```

The resulting `output.txt` provides a portable textual snapshot of the project.

## Current Experiments

The first runs have explored several recurring ideas:

```text
admissibility rather than optimization

continuation as a property of trajectories

repair that preserves difference

diffusion rather than concentration of technological capability
```

These topics are useful partly because they stress the architecture itself. They require models to preserve distinctions across long arguments, criticize definitions, identify conceptual drift, and revise without simply replacing unfamiliar concepts with more conventional language.

The essays should therefore be treated as experimental artifacts as well as potential pieces of writing.

## What This Project Does Not Claim

The existence of a review stage does not make the pipeline a factual verification system. The larger model is not an oracle, and agreement between two related Granite models is not independent confirmation.

The current pipeline also does not establish that `granite4.1:8b` is objectively better at criticism, that the asymmetric architecture is cheaper overall, or that every revision improves its draft.

Those are experimental questions.

The present system makes them easier to investigate because the relevant operations have been separated and preserved.

## Planned Experiments

The next stage of the project is comparative rather than architectural.

The same frozen draft can be reviewed independently by the 3B and 8B models. The same frozen review can be supplied to different revisers. Homogeneous 3B and 8B pipelines can be compared against the asymmetric pipeline. Multiple runs of the same topic can estimate stochastic variation.

The scripts can also begin recording model digests, inference times, context sizes, sampling parameters, and other metadata so that apparent improvements can be distinguished from uncontrolled changes in the experimental environment.

A later research stage may add external evidence retrieval and factual verification, but those operations should remain explicit rather than being hidden inside the drafting prompt.

## Design Principle

The project is built around a simple idea:

```text
capability
    ↓
externalized representation
    ↓
persistent state
    ↓
criticism and repair
    ↓
future reachability
```

A stronger model does not need to perform every future operation itself if some useful consequence of its computation can be represented in a form usable by another component.

Whether this actually works, and where it stops working, is one of the questions the repository exists to investigate.

The important object is therefore not any particular generated essay and not any particular model.

It is the continuing repository of representations, experiments, failures, and repairs from which later work can begin.

