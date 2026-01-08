#!/usr/bin/env bats

load 'bats-support/load.bash'
load 'bats-assert/load.bash'

setup() {
  # Get the path to the phx.sh script
  PHX_SCRIPT="$(pwd)/phx.sh"
}

@test "displays version information" {
  run "$PHX_SCRIPT" version
  assert_output "phx 0.1.0"
}
