#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/scripts/common.sh"

echo
echo "Granite experiment test"
echo

check_environment

echo "Models:"
echo
echo "    $DRAFT_MODEL"
echo "    $REVIEW_MODEL"
echo

echo "Checking shell scripts..."

for script in \
    test-models.sh \
    compare-models.sh \
    granite-essay.sh \
    review-essay.sh \
    essay-pipeline.sh \
    scripts/common.sh
do
    printf '    %-30s' "$script"

    bash -n "$ROOT/$script"

    echo "PASS"
done

echo
echo "Checking Python helper..."

python3 -m py_compile \
    "$ROOT/scripts/render-prompt.py"

echo "    render-prompt.py              PASS"

echo
echo "Environment and syntax checks passed."
