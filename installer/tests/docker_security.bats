#!/usr/bin/env bats

load 'test_helper.bash'

setup() {
  setup_test_environment

  # Create mock trivy command
  mock_trivy_path="$SENTINEL_ROOT_DIR/bin/trivy"
  mkdir -p "$(dirname "$mock_trivy_path")"
  cat > "$mock_trivy_path" <<'EOF'
#!/bin/sh
echo "trivy mock: $@" >> "$SENTINEL_ROOT_DIR/trivy_calls.log"
exit 0
EOF
  chmod +x "$mock_trivy_path"
  export PATH="$SENTINEL_ROOT_DIR/bin:$PATH"

  # Source dependencies
  source "$BATS_TEST_DIRNAME/../../bash_modules.d/logging.module"
  source "$BATS_TEST_DIRNAME/../../bash_modules.d/docker_security.module"
}

teardown() {
  teardown_test_environment
}

@test "scan_image should call trivy with correct arguments" {
  scan_image "test-image:latest"

  local trivy_calls
  trivy_calls=$(cat "$SENTINEL_ROOT_DIR/trivy_calls.log")

  echo "$trivy_calls" | grep -q "image"
  echo "$trivy_calls" | grep -q "test-image:latest"
}
