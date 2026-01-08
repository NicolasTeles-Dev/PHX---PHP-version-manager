#!/usr/bin/env bash

set -e

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Initialize git submodules
git submodule init
git submodule update

# Run bats tests
"$SCRIPT_DIR/tests/bats-core/bin/bats" "$SCRIPT_DIR/tests"
