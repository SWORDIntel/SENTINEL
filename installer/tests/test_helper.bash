#!/usr/bin/env bash

setup_test_environment() {
  export SENTINEL_ROOT_DIR="$BATS_TEST_DIRNAME/test_root"
  export SENTINEL_INSTALL_DIR="$SENTINEL_ROOT_DIR/sentinel"
  export SENTINEL_CONFIG_FILE="$SENTINEL_INSTALL_DIR/config/config.yaml"
  export BASHRC_FILE="$SENTINEL_ROOT_DIR/.bashrc"

  # Create test directories
  mkdir -p "$SENTINEL_INSTALL_DIR/config"
  local mock_bin_dir="$SENTINEL_ROOT_DIR/bin"
  mkdir -p "$mock_bin_dir"

  # Create mock sudo
  cat > "$mock_bin_dir/sudo" <<'EOF'
#!/bin/sh
# This is a mock sudo for testing purposes. It logs calls and exits successfully.
echo "sudo mock: $@" >> "$SENTINEL_ROOT_DIR/sudo.log"
exit 0
EOF
  chmod +x "$mock_bin_dir/sudo"

  # Prepend mock bin to PATH
  export PATH="$mock_bin_dir:$PATH"

  cp "$BATS_TEST_DIRNAME/../../config.yaml.dist" "$SENTINEL_CONFIG_FILE"
  touch "$BASHRC_FILE"
}

teardown_test_environment() {
  rm -rf "$SENTINEL_ROOT_DIR"
  rm -f "$SENTINEL_INSTALL_DIR/install.state"
}
