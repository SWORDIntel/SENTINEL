#!/usr/bin/env bats

load 'test_helper.bash'

setup() {
  setup_test_environment

  # Create mock aws command
  mock_aws_path="$SENTINEL_ROOT_DIR/bin/aws"
  mkdir -p "$(dirname "$mock_aws_path")"
  cat > "$mock_aws_path" <<'EOF'
#!/bin/sh
echo "mock_access_key mock_secret_key mock_session_token"
echo "$@" >> "$SENTINEL_ROOT_DIR/aws_calls.log"
EOF
  chmod +x "$mock_aws_path"
  export PATH="$SENTINEL_ROOT_DIR/bin:$PATH"

  # Source dependencies
  source "$BATS_TEST_DIRNAME/../../bash_modules.d/logging.module"
  source "$BATS_TEST_DIRNAME/../../bash_modules.d/aws_security.module"
}

teardown() {
  teardown_test_environment
}

@test "assume_role should export credentials" {
  assume_role "arn:aws:iam::123456789012:role/test-role"

  [ "$AWS_ACCESS_KEY_ID" = "mock_access_key" ]
  [ "$AWS_SECRET_ACCESS_KEY" = "mock_secret_key" ]
  [ "$AWS_SESSION_TOKEN" = "mock_session_token" ]
}

@test "assume_role should call aws cli with correct arguments" {
  assume_role "arn:aws:iam::123456789012:role/test-role" "test-session"

  # The mock aws command logs the arguments to this file
  local aws_calls
  aws_calls=$(cat "$SENTINEL_ROOT_DIR/aws_calls.log")

  echo "$aws_calls" | grep -q "sts"
  echo "$aws_calls" | grep -q "assume-role"
  echo "$aws_calls" | grep -q -- "--role-arn arn:aws:iam::123456789012:role/test-role"
  echo "$aws_calls" | grep -q -- "--role-session-name test-session"
}
