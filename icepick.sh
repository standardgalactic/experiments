#!/usr/bin/env bash

# icepick.sh
#
# Concatenate the useful text, source, prompt, and experiment files in this
# repository into a single readable file.
#
# Output:
#
#     icepick.txt
#
# Usage:
#
#     chmod +x icepick.sh
#     ./icepick.sh
#
# Then:
#
#     less icepick.txt
#     vim icepick.txt
#     wc -l icepick.txt

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="${ROOT}/icepick.txt"

###############################################################################
# Temporary file
###############################################################################

TMP="$(mktemp)"

cleanup() {
    rm -f "$TMP"
}

trap cleanup EXIT

###############################################################################
# Header
###############################################################################

{
    echo "================================================================"
    echo " ICEPICK"
    echo "================================================================"
    echo
    echo "Repository: $(basename "$ROOT")"
    echo "Generated:  $(date --iso-8601=seconds)"
    echo
    echo "Combined textual repository snapshot."
    echo

} > "$TMP"

###############################################################################
# File selection
###############################################################################

# We explicitly select textual formats rather than blindly catting everything.
#
# This includes:
#
#   Markdown
#   shell scripts
#   text files
#   Python
#   LaTeX
#   JSON
#   YAML
#
# Add more -name expressions here if the repository grows new textual formats.

mapfile -d '' FILES < <(

    find "$ROOT" \
        -type f \
        \( \
            -name '*.md'  -o \
            -name '*.txt' -o \
            -name '*.sh'  -o \
            -name '*.py'  -o \
            -name '*.tex' -o \
            -name '*.json' -o \
            -name '*.yaml' -o \
            -name '*.yml' \
        \) \
        ! -path "$ROOT/.git/*" \
        ! -path '*/__pycache__/*' \
        ! -path "$ROOT/logs/*" \
        ! -name 'icepick.txt' \
        ! -name 'output.txt' \
        -print0 |
        sort -z

)

###############################################################################
# Concatenate
###############################################################################

COUNT=0

for FILE in "${FILES[@]}"; do

    RELATIVE="${FILE#"$ROOT"/}"

    {
        echo
        echo
        echo "================================================================"
        echo " FILE: $RELATIVE"
        echo "================================================================"
        echo
        echo "----- BEGIN $RELATIVE -----"
        echo

        cat "$FILE"

        echo
        echo "----- END $RELATIVE -----"
        echo

    } >> "$TMP"

    ((COUNT += 1))

done

###############################################################################
# Footer
###############################################################################

{
    echo
    echo
    echo "================================================================"
    echo " END ICEPICK"
    echo "================================================================"
    echo
    echo "Files collected: $COUNT"

} >> "$TMP"

###############################################################################
# Atomic replacement
###############################################################################

mv "$TMP" "$OUTPUT"

###############################################################################
# Report
###############################################################################

LINES="$(wc -l < "$OUTPUT")"
WORDS="$(wc -w < "$OUTPUT")"
BYTES="$(wc -c < "$OUTPUT")"

echo
echo "ICEPICK complete."
echo
echo "Output:"
echo "    $OUTPUT"
echo
echo "Files: $COUNT"
echo "Lines: $LINES"
echo "Words: $WORDS"
echo "Bytes: $BYTES"
echo
