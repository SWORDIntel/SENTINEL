#!/usr/bin/env bats

load 'test_helper.bash'

setup() {
  setup_test_environment
}

teardown() {
  teardown_test_environment
}

@test "installer.sh should run without errors" {
  run "$BATS_TEST_DIRNAME/../install.sh" --non-interactive
  echo "Status: $status"
  echo "Output: $output"
  [ "$status" -eq 0 ]
}

@test "installer.sh should create necessary directories" {
  run "$BATS_TEST_DIRNAME/../install.sh" --non-interactive
  [ "$status" -eq 0 ]
  [ -d "$SENTINEL_INSTALL_DIR" ]
  [ -d "$SENTINEL_INSTALL_DIR/config" ]
  [ -d "$SENTINEL_INSTALL_DIR/logs" ]
  [ -d "$SENTINEL_INSTALL_DIR/bash_modules.d" ]
}


@test "installer.sh should create a python virtualenv" {
  run "$BATS_TEST_DIRNAME/../install.sh" --non-interactive
  [ "$status" -eq 0 ]
  [ -d "$SENTINEL_INSTALL_DIR/venv" ]
}

@test "installer.sh should execute install_core.sh" {
  run "$BATS_TEST_DIRNAME/../install.sh" --non-interactive
  [ "$status" -eq 0 ]
  [ -f "$SENTINEL_INSTALL_DIR/blesh_loader.sh" ]
}

@test "installer.sh should select kitty terminal" {
  command -v yq >/dev/null 2>&1 || skip "yq not installed"
  run bash -c "echo '1' | $BATS_TEST_DIRNAME/../install.sh"
  [ "$status" -eq 0 ]
  grep -q "preferred: kitty" "$SENTINEL_CONFIG_FILE"
}

@test "installer.sh should select default terminal" {
    run bash -c "echo '3' | $BATS_TEST_DIRNAME/../install.sh"
    [ "$status" -eq 0 ]
    grep -q "preferred: default" "$SENTINEL_CONFIG_FILE"
}
