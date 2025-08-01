#!/usr/bin/env bats

@test "Installer runs without fatal errors" {
  run bash install.sh --non-interactive
  [ "$status" -eq 0 ] || (echo "Installer failed with status $status" && echo "Output: $output" && false)
}
