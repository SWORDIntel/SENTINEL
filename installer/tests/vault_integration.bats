#!/usr/bin/env bats

load 'test_helper.bash'

setup() {
  setup_test_environment

  # Create mock vault command
  mock_vault_path="$SENTINEL_ROOT_DIR/bin/vault"
  mkdir -p "$(dirname "$mock_vault_path")"
  cat > "$mock_vault_path" <<'EOF'
#!/bin/sh
if [ "$1" = "read" ] && [ "$2" = "-field=value" ]; then
  echo "mock_secret"
elif [ "$1" = "read" ] && [ "$2" = "-format=json" ]; then
  echo '{"data": {"MY_SECRET": "my_value"}}'
fi
echo "vault mock: $@" >> "$SENTINEL_ROOT_DIR/vault_calls.log"
exit 0
EOF
  chmod +x "$mock_vault_path"

  # Create mock jq command
  mock_jq_path="$SENTINEL_ROOT_DIR/bin/jq"
    cat > "$mock_jq_path" <<'EOF'
#!/bin/sh
echo "export MY_SECRET=my_value"
EOF
  chmod +x "$mock_jq_path"

  export PATH="$SENTINEL_ROOT_DIR/bin:$PATH"

  # Source dependencies
  source "$BATS_TEST_DIRNAME/../../bash_modules.d/logging.module"
  source "$BATS_TEST_DIRNAME/../../bash_modules.d/vault_integration.module"
}

teardown() {
  teardown_test_environment
}

@test "vault_read should call vault with correct arguments" {
  vault_read "secret/data/test"

  local vault_calls
  vault_calls=$(cat "$SENTINEL_ROOT_DIR/vault_calls.log")

  echo "$vault_calls" | grep -q "read"
  echo "$vault_calls" | grep -q -- "-field=value"
  echo "$vault_calls" | grep -q "secret/data/test"
}

@test "vault_exec should export secrets" {
  vault_exec "secret/data/test" "printenv MY_SECRET"

  local secrets
  secrets=$(cat "/tmp/secrets.txt")

  echo "$secrets" | grep -q "export MY_SECRET=my_value"
}
