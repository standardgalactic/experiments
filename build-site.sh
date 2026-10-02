#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ASSETS="$ROOT/assets"
PROGRAMMING="$ROOT/programming"
EXPERIMENTS="$PROGRAMMING/experiments"
DATA="$PROGRAMMING/experiments.json"

MODELS="$ROOT/models"
ARTIFACTS="$ROOT/artifacts"
PROTOCOLS="$ROOT/protocols"
HISTORY="$ROOT/history"

mkdir -p \
    "$ASSETS" \
    "$PROGRAMMING" \
    "$EXPERIMENTS" \
    "$MODELS" \
    "$ARTIFACTS" \
    "$PROTOCOLS" \
    "$HISTORY"

echo
echo "========================================"
echo " standardgalactic / experiments"
echo " static laboratory builder"
echo "========================================"
echo


# ============================================================
# Experiment registry
#
# experiments.json is authoritative for programming experiments.
# Existing registries are preserved.
# ============================================================

if [[ ! -f "$DATA" ]]; then

cat > "$DATA" <<'JSON'
[
  {
    "id": "001",
    "slug": "aspect-relegation",
    "title": "Aspect Relegation",
    "status": "scaffold",
    "theory": "Aspect Relegation Theory",
    "question": "When can an explicitly controlled operation disappear into automatic execution, and what forces it back into explicit control?"
  },
  {
    "id": "002",
    "slug": "admissible-degradation",
    "title": "Admissible Degradation",
    "status": "scaffold",
    "theory": "Admissible Degradation",
    "question": "How much damage can a system absorb while preserving the conditions required for legitimate continuation?"
  },
  {
    "id": "003",
    "slug": "continuation",
    "title": "Continuation",
    "status": "scaffold",
    "theory": "Continuation Geometry",
    "question": "What can reachable trajectories tell us that inspection of the present state cannot?"
  },
  {
    "id": "004",
    "slug": "repair-and-difference",
    "title": "Repair and Difference",
    "status": "scaffold",
    "theory": "Difference-Preserving Repair",
    "question": "Can a repair restore immediate function while destroying distinctions required for future behavior?"
  },
  {
    "id": "005",
    "slug": "refusal",
    "title": "Refusal",
    "status": "scaffold",
    "theory": "Explicit Refusal",
    "question": "What changes when refusal is represented as an explicit state transition rather than as missing output?"
  },
  {
    "id": "006",
    "slug": "replay",
    "title": "Replay",
    "status": "scaffold",
    "theory": "Persistent State",
    "question": "What information must an event history preserve for reconstruction to remain semantically adequate?"
  },
  {
    "id": "007",
    "slug": "defeat",
    "title": "Defeat",
    "status": "scaffold",
    "theory": "Adversaria",
    "question": "How does policy-relative defeat differ computationally from the structural existence of an attack?"
  },
  {
    "id": "008",
    "slug": "no-scalar",
    "title": "No Scalar",
    "status": "scaffold",
    "theory": "Scalar Inadequacy",
    "question": "Which distinctions disappear when multidimensional standing is compressed into a single score?"
  },
  {
    "id": "009",
    "slug": "projection",
    "title": "Projection",
    "status": "scaffold",
    "theory": "Projection and Interface",
    "question": "What properties survive when a richer object is exposed through a restricted interface?"
  },
  {
    "id": "010",
    "slug": "unfinishedness",
    "title": "Unfinishedness",
    "status": "scaffold",
    "theory": "Unfinishedness as Interface",
    "question": "Can deliberately retained attachment points increase future reachability compared with completed structures?"
  },
  {
    "id": "011",
    "slug": "smoothness",
    "title": "Smoothness",
    "status": "scaffold",
    "theory": "The Smoothness Paradox",
    "question": "When does smooth observable behavior conceal discontinuity or divergence in the process producing it?"
  },
  {
    "id": "012",
    "slug": "mem8",
    "title": "MEM|8",
    "status": "scaffold",
    "theory": "MEM|8",
    "question": "What becomes observable when transformation is decomposed into explicit POP, REFUSE, BIND, TRANSFORM, VERIFY, and COLLAPSE operations?"
  }
]
JSON

    echo "Created experiment registry."
else
    echo "Preserving existing experiment registry."
fi


# ============================================================
# Shared stylesheet
# ============================================================

cat > "$ASSETS/site.css" <<'CSS'
:root {
  color-scheme: dark;

  --bg: #090b0e;
  --panel: #101419;
  --panel2: #151a20;

  --line: #29313a;
  --line2: #394550;

  --text: #e8edf2;
  --muted: #8d9aa7;
  --faint: #606c77;

  --accent: #9cc7ff;
  --active: #a9e5bb;
  --result: #e6d59a;
}

* {
  box-sizing: border-box;
}

html {
  font-family:
    ui-monospace,
    SFMono-Regular,
    Menlo,
    Monaco,
    Consolas,
    "Liberation Mono",
    monospace;

  background: var(--bg);
  color: var(--text);
}

body {
  margin: 0;
}

main {
  width: min(100% - 2rem, 1120px);
  margin: 0 auto;
  padding: 4rem 0 8rem;
}

a {
  color: inherit;
}

nav {
  display: flex;
  justify-content: space-between;
  gap: 2rem;
  margin-bottom: 5rem;
  font-size: 0.78rem;
}

nav a {
  color: var(--muted);
  text-decoration: none;
}

nav a:hover {
  color: var(--text);
}

.eyebrow {
  margin-bottom: 1rem;
  color: var(--accent);
  font-size: 0.7rem;
  letter-spacing: 0.17em;
  text-transform: uppercase;
}

h1 {
  margin: 0;
  max-width: 950px;
  font-size: clamp(2.8rem, 8vw, 6rem);
  font-weight: 500;
  line-height: 0.98;
  letter-spacing: -0.07em;
}

.lede {
  max-width: 780px;
  margin-top: 1.7rem;
  color: var(--muted);
  font-size: 1rem;
  line-height: 1.8;
}

.principle {
  max-width: 760px;
  margin-top: 2.8rem;
  padding: 0.2rem 0 0.2rem 1.2rem;
  border-left: 1px solid var(--accent);
  color: var(--accent);
  line-height: 1.9;
}

section {
  margin-top: 5rem;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  color: var(--muted);
  font-size: 0.72rem;
  font-weight: 500;
  letter-spacing: 0.15em;
  text-transform: uppercase;
}

.section-title::after {
  content: "";
  flex: 1;
  height: 1px;
  background: var(--line);
}

.grid {
  display: grid;
  grid-template-columns:
    repeat(auto-fit, minmax(min(100%, 280px), 1fr));
  gap: 1px;
  background: var(--line);
  border: 1px solid var(--line);
}

.card {
  position: relative;
  display: flex;
  min-height: 250px;
  padding: 1.5rem;
  flex-direction: column;
  background: var(--panel);
  text-decoration: none;
  transition: background 120ms ease;
}

.card:hover {
  z-index: 2;
  background: var(--panel2);
  outline: 1px solid var(--line2);
}

.card-top {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
}

.number {
  color: var(--muted);
  font-size: 0.7rem;
}

.card h2,
.card h3 {
  margin: auto 0 0.8rem;
  padding-top: 3rem;
  font-size: 1.2rem;
  font-weight: 500;
}

.card p {
  margin: 0;
  color: var(--muted);
  font-size: 0.87rem;
  line-height: 1.65;
}

.theory {
  margin-top: 1.2rem;
  color: var(--faint);
  font-size: 0.7rem;
}

.status {
  display: inline-block;
  font-size: 0.64rem;
  letter-spacing: 0.11em;
  text-transform: uppercase;
}

.status-scaffold {
  color: var(--muted);
}

.status-prototype {
  color: var(--accent);
}

.status-running {
  color: var(--active);
}

.status-results {
  color: var(--result);
}

.status-retired {
  color: var(--faint);
}

.stats {
  display: grid;
  grid-template-columns:
    repeat(auto-fit, minmax(150px, 1fr));
  margin-top: 3rem;
  border: 1px solid var(--line);
}

.stat {
  padding: 1.3rem;
  border-right: 1px solid var(--line);
}

.stat:last-child {
  border-right: 0;
}

.stat-value {
  display: block;
  margin-bottom: 0.35rem;
  font-size: 1.5rem;
}

.stat-label {
  color: var(--muted);
  font-size: 0.68rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.experiment-header {
  padding-bottom: 3rem;
  border-bottom: 1px solid var(--line);
}

.experiment-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  margin-top: 2rem;
  color: var(--muted);
  font-size: 0.72rem;
}

.lab-panel {
  min-height: 180px;
  padding: 1.5rem;
  border: 1px solid var(--line);
  background: var(--panel);
}

.lab-panel p {
  max-width: 760px;
  margin: 0;
  color: var(--muted);
  line-height: 1.7;
}

.empty {
  color: var(--faint);
}

footer {
  display: flex;
  justify-content: space-between;
  gap: 2rem;
  margin-top: 7rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--line);
  color: var(--muted);
  font-size: 0.72rem;
}

@media (max-width: 600px) {
  main {
    width: min(100% - 1.2rem, 1120px);
    padding-top: 2rem;
  }

  nav {
    margin-bottom: 3rem;
  }

  .stat {
    border-right: 0;
    border-bottom: 1px solid var(--line);
  }

  .stat:last-child {
    border-bottom: 0;
  }

  footer {
    flex-direction: column;
  }
}
CSS


# ============================================================
# Root laboratory index
# ============================================================

cat > "$ROOT/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1">

  <meta name="description"
        content="A laboratory of computational experiments, model pipelines, persistent representations, failures, and repairs.">

  <title>Experiments — standardgalactic</title>

  <link rel="stylesheet" href="assets/site.css">
</head>

<body>
<main>

  <header>

    <div class="eyebrow">
      standardgalactic / laboratory
    </div>

    <h1>experiments</h1>

    <p class="lede">
      A repository of computational investigations, persistent
      representations, model pipelines, theoretical probes, failures,
      comparisons, and repairs. The repository preserves not merely
      results but the trajectories that produced them.
    </p>

    <div class="principle">
      persist the project;<br>
      replace the processor
    </div>

  </header>


  <section>

    <div class="section-title">
      Laboratories
    </div>

    <div class="grid">

      <a class="card" href="programming/">

        <div class="card-top">
          <span class="number">LAB / 01</span>
          <span class="status status-running">active</span>
        </div>

        <h2>Programming Experiments</h2>

        <p>
          Executable investigations derived from theoretical claims.
          Theory becomes state, transformation, intervention,
          observation, and possible failure.
        </p>

      </a>


      <a class="card" href="models/">

        <div class="card-top">
          <span class="number">LAB / 02</span>
          <span class="status status-running">active</span>
        </div>

        <h2>Language-Model Experiments</h2>

        <p>
          Granite and Ollama experiments involving outlines, drafts,
          criticism, revision, heterogeneous model roles, and
          persistent intermediate representations.
        </p>

      </a>


      <a class="card" href="artifacts/">

        <div class="card-top">
          <span class="number">LAB / 03</span>
          <span class="status status-results">archive</span>
        </div>

        <h2>Experimental Artifacts</h2>

        <p>
          Preserved outputs and intermediate states from experimental
          runs rather than only their terminal products.
        </p>

      </a>


      <a class="card" href="protocols/">

        <div class="card-top">
          <span class="number">LAB / 04</span>
          <span class="status status-running">active</span>
        </div>

        <h2>Protocols</h2>

        <p>
          Versionable prompts and procedures defining experimental
          transformations independently of their outputs.
        </p>

      </a>


      <a class="card" href="history/">

        <div class="card-top">
          <span class="number">LAB / 05</span>
          <span class="status status-running">record</span>
        </div>

        <h2>Experimental History</h2>

        <p>
          Changes to the apparatus, preserved trajectories, failures,
          repairs, and the evolution of experimental claims.
        </p>

      </a>

    </div>

  </section>


  <section>

    <div class="section-title">
      Method
    </div>

    <p class="lede">
      Intermediate states are experimental evidence. A successful
      terminal artifact does not erase the operations that produced
      it, and a failed artifact remains evidence about the apparatus.
      The repository therefore records trajectories rather than
      treating outputs as isolated objects.
    </p>

  </section>


  <footer>
    <span>standardgalactic / experiments</span>
    <span>persistent laboratory</span>
  </footer>

</main>
</body>
</html>
HTML


# ============================================================
# Models index
# ============================================================

cat > "$MODELS/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1">

  <meta name="description"
        content="Experiments with local language models and persistent intermediate representations.">

  <title>Language-Model Experiments</title>

  <link rel="stylesheet" href="../assets/site.css">
</head>

<body>
<main>

  <nav>
    <a href="../">← laboratory index</a>
    <a href="../programming/">programming experiments</a>
  </nav>

  <header>

    <div class="eyebrow">
      Laboratory / Models
    </div>

    <h1>
      Language-Model<br>
      Experiments
    </h1>

    <p class="lede">
      Experiments with local language models as components in
      persistent, inspectable computational pipelines. Models perform
      transformations while files preserve the intermediate states
      through which those transformations become inspectable.
    </p>

    <div class="principle">
      capability → representation → persistence → criticism → repair
    </div>

  </header>


  <section>

    <div class="section-title">
      Current Apparatus
    </div>

    <div class="grid">

      <a class="card" href="../essay-pipeline.sh">

        <div class="card-top">
          <span class="number">MODEL / 01</span>
          <span class="status status-running">active</span>
        </div>

        <h2>Essay Pipeline</h2>

        <p>
          A staged writing experiment separating topic, outline,
          draft, review, and revision into inspectable operations.
        </p>

      </a>


      <a class="card" href="../compare-models.sh">

        <div class="card-top">
          <span class="number">MODEL / 02</span>
          <span class="status status-running">active</span>
        </div>

        <h2>Model Comparison</h2>

        <p>
          Comparative experiments examining whether different model
          sizes contribute differently at different stages.
        </p>

      </a>


      <a class="card" href="../review-essay.sh">

        <div class="card-top">
          <span class="number">MODEL / 03</span>
          <span class="status status-running">active</span>
        </div>

        <h2>Independent Review</h2>

        <p>
          Separate defect recognition from defect repair by
          externalizing criticism as its own persistent artifact.
        </p>

      </a>


      <a class="card" href="../test-models.sh">

        <div class="card-top">
          <span class="number">MODEL / 04</span>
          <span class="status status-running">active</span>
        </div>

        <h2>Model Tests</h2>

        <p>
          Controlled probes of locally installed models before they
          are incorporated into longer experimental pipelines.
        </p>

      </a>

    </div>

  </section>


  <section>

    <div class="section-title">
      Pipeline
    </div>

    <div class="lab-panel">
      <p>
        T → O → D → R → F
        <br><br>
        Topic becomes outline. Outline becomes draft. Draft becomes
        an object of review. Review and draft become inputs to
        revision. No intermediate representation needs to disappear
        merely because a later representation exists.
      </p>
    </div>

  </section>


  <footer>
    <span>standardgalactic / experiments / models</span>
    <span>persistent model laboratory</span>
  </footer>

</main>
</body>
</html>
HTML


# ============================================================
# Artifacts index
# ============================================================

cat > "$ARTIFACTS/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1">

  <meta name="description"
        content="Experimental artifacts and preserved intermediate states.">

  <title>Experimental Artifacts</title>

  <link rel="stylesheet" href="../assets/site.css">
</head>

<body>
<main>

  <nav>
    <a href="../">← laboratory index</a>
    <a href="../models/">model experiments</a>
  </nav>

  <header>

    <div class="eyebrow">
      Laboratory / Artifacts
    </div>

    <h1>
      Experimental<br>
      Artifacts
    </h1>

    <p class="lede">
      The laboratory preserves intermediate representations as
      experimental evidence. Outlines, drafts, reviews, revisions,
      logs, and raw outputs record trajectories rather than merely
      terminal products.
    </p>

    <div class="principle">
      The final artifact does not supersede its history.
    </div>

  </header>


  <section>

    <div class="section-title">
      Collections
    </div>

    <div class="grid">

      <div class="card">

        <div class="card-top">
          <span class="number">ART / 01</span>
        </div>

        <h2>Output</h2>

        <p>
          Completed experimental trajectories containing retained
          intermediate representations.
        </p>

      </div>


      <div class="card">

        <div class="card-top">
          <span class="number">ART / 02</span>
        </div>

        <h2>Initial Output</h2>

        <p>
          Earlier generated material retained as part of the
          experimental history.
        </p>

      </div>


      <div class="card">

        <div class="card-top">
          <span class="number">ART / 03</span>
        </div>

        <h2>Batch Logs</h2>

        <p>
          Operational traces from larger experimental runs.
        </p>

      </div>

    </div>

  </section>


  <section>

    <div class="section-title">
      Why Preserve Intermediate States?
    </div>

    <div class="lab-panel">
      <p>
        If a final artifact contains a defect, preserved intermediate
        states make it possible to ask where that defect entered the
        trajectory, whether it was subsequently detected, and whether
        attempted repair succeeded.
      </p>
    </div>

  </section>


  <footer>
    <span>standardgalactic / experiments / artifacts</span>
    <span>preserved experimental state</span>
  </footer>

</main>
</body>
</html>
HTML


# ============================================================
# Protocols index
# ============================================================

cat > "$PROTOCOLS/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1">

  <meta name="description"
        content="Prompts, procedures, and experimental protocols.">

  <title>Experimental Protocols</title>

  <link rel="stylesheet" href="../assets/site.css">
</head>

<body>
<main>

  <nav>
    <a href="../">← laboratory index</a>
    <a href="../models/">model experiments</a>
  </nav>

  <header>

    <div class="eyebrow">
      Laboratory / Protocols
    </div>

    <h1>
      Experimental<br>
      Protocols
    </h1>

    <p class="lede">
      Instructions are part of the experimental apparatus. Prompts
      and procedures are kept external to the systems that execute
      them so changes remain visible, comparable, and versionable.
    </p>

    <div class="principle">
      Change the protocol without erasing the experiment.
    </div>

  </header>


  <section>

    <div class="section-title">
      Writing Pipeline
    </div>

    <div class="grid">

      <a class="card" href="../prompts/outline.txt">
        <div class="card-top">
          <span class="number">PROTO / 01</span>
        </div>

        <h2>Outline</h2>

        <p>
          Transform a topic into an explicit argumentative structure.
        </p>
      </a>


      <a class="card" href="../prompts/draft.txt">
        <div class="card-top">
          <span class="number">PROTO / 02</span>
        </div>

        <h2>Draft</h2>

        <p>
          Transform the preserved outline into a complete initial
          essay.
        </p>
      </a>


      <a class="card" href="../prompts/review.txt">
        <div class="card-top">
          <span class="number">PROTO / 03</span>
        </div>

        <h2>Review</h2>

        <p>
          Diagnose defects without silently replacing the artifact
          being criticized.
        </p>
      </a>


      <a class="card" href="../prompts/revise.txt">
        <div class="card-top">
          <span class="number">PROTO / 04</span>
        </div>

        <h2>Revision</h2>

        <p>
          Attempt repair using both the draft and its externalized
          diagnosis.
        </p>
      </a>

    </div>

  </section>


  <footer>
    <span>standardgalactic / experiments / protocols</span>
    <span>versionable experimental instructions</span>
  </footer>

</main>
</body>
</html>
HTML


# ============================================================
# History index
# ============================================================

cat > "$HISTORY/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1">

  <meta name="description"
        content="History, failures, revisions, and evolution of the experimental apparatus.">

  <title>Experimental History</title>

  <link rel="stylesheet" href="../assets/site.css">
</head>

<body>
<main>

  <nav>
    <a href="../">← laboratory index</a>
    <a href="../artifacts/">artifacts</a>
  </nav>

  <header>

    <div class="eyebrow">
      Laboratory / History
    </div>

    <h1>
      Experimental<br>
      History
    </h1>

    <p class="lede">
      Experimental apparatus changes. Scripts are repaired, prompts
      are revised, models are replaced, hypotheses are weakened, and
      failed approaches are abandoned. Those changes are themselves
      part of the evidence.
    </p>

    <div class="principle">
      The working tree is revisable.<br>
      Historical existence is monotonic.
    </div>

  </header>


  <section>

    <div class="section-title">
      Layers of History
    </div>

    <div class="grid">

      <a class="card"
         href="https://github.com/standardgalactic/experiments/commits/main/">

        <div class="card-top">
          <span class="number">HIST / 01</span>
        </div>

        <h2>Repository History</h2>

        <p>
          Git records changes to the experimental apparatus itself.
        </p>

      </a>


      <a class="card" href="../artifacts/">

        <div class="card-top">
          <span class="number">HIST / 02</span>
        </div>

        <h2>Artifact History</h2>

        <p>
          Intermediate files preserve trajectories within individual
          experimental runs.
        </p>

      </a>


      <a class="card" href="../programming/">

        <div class="card-top">
          <span class="number">HIST / 03</span>
        </div>

        <h2>Experiment States</h2>

        <p>
          Programming experiments progress through scaffold,
          prototype, running, results, and retirement.
        </p>

      </a>

    </div>

  </section>


  <footer>
    <span>standardgalactic / experiments / history</span>
    <span>apparatus evolution</span>
  </footer>

</main>
</body>
</html>
HTML


# ============================================================
# Generate programming laboratory from experiments.json
# ============================================================

echo "Generating programming laboratory from registry..."

python3 - "$ROOT" "$DATA" <<'PY'
import json
import sys
import html
from pathlib import Path
from collections import Counter

root = Path(sys.argv[1])
data_file = Path(sys.argv[2])

programming = root / "programming"
experiments_dir = programming / "experiments"

with data_file.open("r", encoding="utf-8") as f:
    experiments = json.load(f)

if not isinstance(experiments, list):
    raise SystemExit(
        "ERROR: experiments.json must contain a JSON array."
    )

required = {
    "id",
    "slug",
    "title",
    "status",
    "theory",
    "question",
}

allowed_status = {
    "scaffold",
    "prototype",
    "running",
    "results",
    "retired",
}

errors = []

for i, exp in enumerate(experiments):

    missing = required - set(exp)

    if missing:
        errors.append(
            f"entry {i}: missing "
            + ", ".join(sorted(missing))
        )
        continue

    if exp["status"] not in allowed_status:
        errors.append(
            f'{exp["id"]}: unknown status '
            f'"{exp["status"]}"'
        )

ids = [e.get("id") for e in experiments]
slugs = [e.get("slug") for e in experiments]

for value, count in Counter(ids).items():
    if value is not None and count > 1:
        errors.append(
            f"duplicate experiment id: {value}"
        )

for value, count in Counter(slugs).items():
    if value is not None and count > 1:
        errors.append(
            f"duplicate experiment slug: {value}"
        )

if errors:

    print()
    print("Registry validation failed:")

    for error in errors:
        print("  -", error)

    raise SystemExit(1)

experiments.sort(
    key=lambda e: e["id"]
)


def esc(value):
    return html.escape(
        str(value),
        quote=True
    )


def status_class(status):
    return "status-" + status


# ------------------------------------------------------------
# Create experiment scaffold pages
#
# Existing pages are preserved.
# ------------------------------------------------------------

created = 0
preserved = 0

for exp in experiments:

    directory = (
        experiments_dir
        / exp["slug"]
    )

    directory.mkdir(
        parents=True,
        exist_ok=True
    )

    index = directory / "index.html"

    if index.exists():
        preserved += 1
        continue

    page = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">

  <meta name="viewport"
        content="width=device-width, initial-scale=1">

  <meta name="description"
        content="{esc(exp['question'])}">

  <title>
    {esc(exp['title'])} — Experiment {esc(exp['id'])}
  </title>

  <link rel="stylesheet"
        href="../../../assets/site.css">
</head>

<body>
<main>

  <nav>
    <a href="../../">
      ← programming experiments
    </a>

    <a href="../../../">
      laboratory
    </a>
  </nav>

  <header class="experiment-header">

    <div class="eyebrow">
      Programming Experiment / {esc(exp['id'])}
    </div>

    <h1>{esc(exp['title'])}</h1>

    <p class="lede">
      {esc(exp['question'])}
    </p>

    <div class="experiment-meta">

      <span>
        Theory: {esc(exp['theory'])}
      </span>

      <span class="status {status_class(exp['status'])}">
        {esc(exp['status'])}
      </span>

    </div>

  </header>


  <section>

    <div class="section-title">
      Theoretical Claim
    </div>

    <div class="lab-panel">
      <p class="empty">
        The motivating claim has not yet been operationalized.
      </p>
    </div>

  </section>


  <section>

    <div class="section-title">
      Apparatus
    </div>

    <div class="lab-panel">
      <p class="empty">
        Experimental apparatus not yet implemented.
      </p>
    </div>

  </section>


  <section>

    <div class="section-title">
      Manipulation
    </div>

    <div class="lab-panel">
      <p class="empty">
        Independent variables and interventions not yet specified.
      </p>
    </div>

  </section>


  <section>

    <div class="section-title">
      Observation
    </div>

    <div class="lab-panel">
      <p class="empty">
        No observations recorded.
      </p>
    </div>

  </section>


  <section>

    <div class="section-title">
      Competing Interpretation
    </div>

    <div class="lab-panel">
      <p class="empty">
        Alternative explanation not yet specified.
      </p>
    </div>

  </section>


  <section>

    <div class="section-title">
      Embarrassment Condition
    </div>

    <div class="lab-panel">
      <p class="empty">
        The result that would count against the motivating
        interpretation must be specified before experimental
        observations are treated as supporting evidence.
      </p>
    </div>

  </section>


  <footer>

    <span>
      standardgalactic / experiments / programming
    </span>

    <span>
      EXP {esc(exp['id'])}
    </span>

  </footer>

</main>
</body>
</html>
"""

    index.write_text(
        page,
        encoding="utf-8"
    )

    created += 1


# ------------------------------------------------------------
# Generate programming catalog cards
# ------------------------------------------------------------

cards = []

for exp in experiments:

    cards.append(f"""
      <a class="card"
         href="experiments/{esc(exp['slug'])}/">

        <div class="card-top">

          <span class="number">
            EXP / {esc(exp['id'])}
          </span>

          <span class="status {status_class(exp['status'])}">
            {esc(exp['status'])}
          </span>

        </div>

        <h2>{esc(exp['title'])}</h2>

        <p>
          {esc(exp['question'])}
        </p>

        <div class="theory">
          {esc(exp['theory'])}
        </div>

      </a>
""")

counts = Counter(
    e["status"]
    for e in experiments
)


# ------------------------------------------------------------
# Programming index
# ------------------------------------------------------------

page = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">

  <meta name="viewport"
        content="width=device-width, initial-scale=1">

  <meta name="description"
        content="Programming experiments that operationalize theoretical distinctions.">

  <title>Programming Experiments</title>

  <link rel="stylesheet"
        href="../assets/site.css">
</head>

<body>
<main>

  <nav>

    <a href="../">
      ← laboratory index
    </a>

    <a href="experiments.json">
      experiment registry
    </a>

  </nav>


  <header>

    <div class="eyebrow">
      Executable Theory
    </div>

    <h1>
      Programming<br>
      Experiments
    </h1>

    <p class="lede">
      Small programs constructed from theoretical distinctions.
      Each experiment asks what must become observable when a claim
      is translated into states, transformations, constraints,
      interventions, and trajectories.
    </p>

    <div class="principle">
      A demonstration asks whether an idea can be shown.<br>
      An experiment asks where it stops working.
    </div>


    <div class="stats">

      <div class="stat">
        <span class="stat-value">
          {len(experiments)}
        </span>

        <span class="stat-label">
          experiments
        </span>
      </div>


      <div class="stat">
        <span class="stat-value">
          {counts['scaffold']}
        </span>

        <span class="stat-label">
          scaffolds
        </span>
      </div>


      <div class="stat">
        <span class="stat-value">
          {counts['prototype']}
        </span>

        <span class="stat-label">
          prototypes
        </span>
      </div>


      <div class="stat">
        <span class="stat-value">
          {counts['running'] + counts['results']}
        </span>

        <span class="stat-label">
          operational
        </span>
      </div>

    </div>

  </header>


  <section>

    <div class="section-title">
      Experiment Catalog
    </div>

    <div class="grid">
      {''.join(cards)}
    </div>

  </section>


  <section>

    <div class="section-title">
      Experimental Contract
    </div>

    <p class="lede">
      Each program should identify its theoretical claim,
      operational interpretation, manipulated variables,
      observable state, expected relationship, competing
      interpretation, and embarrassment condition.

      An interactive result is evidence about the implementation
      before it is evidence about the theory.
    </p>

  </section>


  <footer>

    <span>
      standardgalactic / experiments / programming
    </span>

    <span>
      registry-driven catalog
    </span>

  </footer>

</main>
</body>
</html>
"""

(programming / "index.html").write_text(
    page,
    encoding="utf-8"
)


# ------------------------------------------------------------
# Generate programming README
# ------------------------------------------------------------

lines = [
    "# Programming Experiments",
    "",
    "Small executable investigations derived from theoretical",
    "distinctions developed elsewhere in the standardgalactic corpus.",
    "",
    "The experiments are not intended merely as illustrations.",
    "",
    "Each experiment should eventually specify:",
    "",
    "1. theoretical claim",
    "2. operational interpretation",
    "3. manipulated variables",
    "4. observable state",
    "5. predicted relationship",
    "6. competing interpretation",
    "7. embarrassment condition",
    "",
    "An experiment should be capable of producing a result that is",
    "inconvenient for the theory that motivated it.",
    "",
    "## Registry",
    "",
]

for exp in experiments:

    lines.append(
        f"{exp['id']}. "
        f"**{exp['title']}** "
        f"— `{exp['status']}` "
        f"— {exp['theory']}"
    )

lines.extend([
    "",
    "The machine-readable registry is:",
    "",
    "    programming/experiments.json",
    "",
    "Individual experiments live under:",
    "",
    "    programming/experiments/<slug>/",
    "",
])

(programming / "README.md").write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8"
)


print(
    f"  registry entries:       "
    f"{len(experiments)}"
)

print(
    f"  scaffolds created:      "
    f"{created}"
)

print(
    f"  existing pages kept:    "
    f"{preserved}"
)
PY


# ============================================================
# Validation
# ============================================================

echo
echo "Validating generated laboratory..."

python3 - "$ROOT" "$DATA" <<'PY'
import json
import sys
from pathlib import Path
from html.parser import HTMLParser

root = Path(sys.argv[1])
data_file = Path(sys.argv[2])

with data_file.open("r", encoding="utf-8") as f:
    experiments = json.load(f)

errors = []


# ------------------------------------------------------------
# Required site files
# ------------------------------------------------------------

required = [
    root / "index.html",
    root / "assets" / "site.css",

    root / "programming" / "index.html",
    root / "programming" / "README.md",
    root / "programming" / "experiments.json",

    root / "models" / "index.html",
    root / "artifacts" / "index.html",
    root / "protocols" / "index.html",
    root / "history" / "index.html",
]

for path in required:

    if not path.exists():
        errors.append(
            "missing required file: "
            + str(path.relative_to(root))
        )


# ------------------------------------------------------------
# Programming experiment pages
# ------------------------------------------------------------

for exp in experiments:

    page = (
        root
        / "programming"
        / "experiments"
        / exp["slug"]
        / "index.html"
    )

    if not page.exists():
        errors.append(
            "missing experiment page: "
            + exp["slug"]
        )


# ------------------------------------------------------------
# Root and programming indexes must differ
# ------------------------------------------------------------

root_index = (
    root
    / "index.html"
)

programming_index = (
    root
    / "programming"
    / "index.html"
)

if (
    root_index.exists()
    and programming_index.exists()
    and root_index.read_bytes()
        == programming_index.read_bytes()
):
    errors.append(
        "root index and programming index are identical"
    )


# ------------------------------------------------------------
# Local href validation
# ------------------------------------------------------------

class LinkParser(HTMLParser):

    def __init__(self):
        super().__init__()
        self.links = []

    def handle_starttag(self, tag, attrs):

        if tag != "a":
            return

        attrs = dict(attrs)

        if "href" in attrs:
            self.links.append(
                attrs["href"]
            )


html_files = list(
    root.rglob("*.html")
)

for html_file in html_files:

    parser = LinkParser()

    try:
        parser.feed(
            html_file.read_text(
                encoding="utf-8"
            )
        )

    except Exception as exc:

        errors.append(
            f"{html_file.relative_to(root)}: "
            f"HTML parse error: {exc}"
        )

        continue


    for href in parser.links:

        if (
            href.startswith("http://")
            or href.startswith("https://")
            or href.startswith("mailto:")
            or href.startswith("#")
        ):
            continue

        href = (
            href
            .split("#", 1)[0]
            .split("?", 1)[0]
        )

        if not href:
            continue

        target = (
            html_file.parent
            / href
        ).resolve()

        if target.is_dir():
            target = (
                target
                / "index.html"
            )

        if not target.exists():
            errors.append(
                f"{html_file.relative_to(root)} "
                f"-> broken local link: {href}"
            )


# ------------------------------------------------------------
# Validation result
# ------------------------------------------------------------

if errors:

    print()
    print("VALIDATION FAILED")
    print()

    for error in errors:
        print("  -", error)

    print()

    raise SystemExit(1)


print("  required files          OK")
print("  experiment pages        OK")
print("  distinct indexes        OK")
print("  local navigation        OK")
print(
    f"  HTML pages checked      "
    f"{len(html_files)}"
)
PY


# ============================================================
# Build report
# ============================================================

echo
echo "========================================"
echo " BUILD COMPLETE"
echo "========================================"
echo
echo "Laboratories:"
echo
echo "  /                         main laboratory"
echo "  /programming/             executable theory"
echo "  /models/                  language-model experiments"
echo "  /artifacts/               preserved artifacts"
echo "  /protocols/               experimental protocols"
echo "  /history/                 experimental history"
echo
echo "Programming registry:"
echo
echo "  programming/experiments.json"
echo
echo "Shared visual system:"
echo
echo "  assets/site.css"
echo
echo "Serve locally with:"
echo
echo "  python3 -m http.server 8000"
echo
echo "Then open:"
echo
echo "  http://localhost:8000/"
echo
