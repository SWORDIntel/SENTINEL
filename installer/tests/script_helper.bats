#!/usr/bin/env bats

load 'test_helper.bash'

setup() {
  setup_test_environment

  # Source dependencies
  source "$BATS_TEST_DIRNAME/../../bash_modules.d/logging.module"
  source "$BATS_TEST_DIRNAME/../../bash_modules.d/script_helper.module"
}

teardown() {
  teardown_test_environment
}

@test "script_helper should make new scripts executable after editing" {
  local script_path="$SENTINEL_ROOT_DIR/test_script.sh"
  echo "#!/bin/bash" > "$script_path"

  # Simulate editing the file
  touch "$script_path"
  _editor_wrapper "touch" "$script_path"

  [ -x "$script_path" ]
}

@test "script_helper should make copied scripts executable" {
  local script_path="$SENTINEL_ROOT_DIR/test_script.sh"
  local new_script_path="$SENTINEL_ROOT_DIR/new_script.sh"
  echo "#!/bin/bash" > "$script_path"

  cp "$script_path" "$new_script_path"

  [ -x "$new_script_path" ]
}

@test "script_helper should make moved scripts executable" {
  local script_path="$SENTINEL_ROOT_DIR/test_script.sh"
  local new_script_path="$SENTINEL_ROOT_DIR/new_script.sh"
  echo "#!/bin/bash" > "$script_path"

  mv "$script_path" "$new_script_path"

  [ -x "$new_script_path" ]
}
