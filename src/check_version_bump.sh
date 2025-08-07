#!/usr/bin/env bash  

set -euo pipefail 

VERSION_FILE="src/__version__.py" 

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

get_version() {
    grep -E '^__version__\s*=' "$1" | sed -E 's/__version__\s*=\s*["'\''"]([^"'\''"]+)["'\''"].*/\1/'
}

git fetch origin main 

git checkout origin/main -- "$VERSION_FILE"
MAIN_VERSION=$(get_version "$VERSION_FILE") 

git checkout "$CURRENT_BRANCH" -- "$VERSION_FILE"
FEATURE_VERSION=$(get_version "$VERSION_FILE") 

sorted_versions=$(printf "%s\n%s\n" "$MAIN_VERSION" "$FEATURE_VERSION" | sort -V)
last_sorted=$(printf "%s\n" "$sorted_versions" | tail -n 1) 

if [[ "$last_sorted" != "$FEATURE_VERSION" ]]; then 
    echo "❌ Version was not bumped: main=$MAIN_VERSION, feature=$FEATURE_VERSION" >&2 
    echo "👉 You can bump the version using: bumpver update --patch/minor/major" >&2 
    exit 1 
fi 

echo "✅ Version bump check passed: $MAIN_VERSION → $FEATURE_VERSION"
