#!/bin/bash
set -euo pipefail

files=$(git ls-files -- .github/workflows/ renovate.json)
if [[ $files != .github/workflows/fnos-sync.yml ]]; then
    printf 'Only .github/workflows/fnos-sync.yml is allowed on the fnOS branch. Found:\n%s\n' "$files" >&2
    exit 1
fi
