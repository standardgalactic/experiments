#!/usr/bin/env bash

set -Eeuo pipefail

DRAFT_MODEL="${DRAFT_MODEL:-granite4.1:3b}"
REVIEW_MODEL="${REVIEW_MODEL:-granite4.1:8b}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OUTPUT_DIR="${ROOT}/output"
LOG_DIR="${ROOT}/logs"

mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "Required command not found: $1"
}

require_model() {
    ollama show "$1" >/dev/null 2>&1 ||
        die "Ollama model not found: $1"
}

check_environment() {
    require_command ollama

    require_model "$DRAFT_MODEL"
    require_model "$REVIEW_MODEL"
}

run_model() {
    local model="$1"
    local prompt="$2"

    printf '%s\n' "$prompt" |
        ollama run "$model"
}

slugify() {
    printf '%s' "$1" |
        tr '[:upper:]' '[:lower:]' |
        sed -E             -e 's/[^a-z0-9]+/-/g'             -e 's/^-+//'             -e 's/-+$//'             -e 's/-+/-/g'
}
