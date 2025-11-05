#!/usr/bin/env bash

# Basic test script for auto_install and venv_helpers

# --- Setup ---
# Ensure we are in a predictable state if possible
# For testing, it's good to source the .bashrc in a subshell
# or ensure the functions/modules are loaded in a controlled way.
# However, directly sourcing .bashrc can have side effects.
# For this test, we'll assume the functions/modules are available
# as they would be in a normal shell session after the changes.

# Load bashrc in a way that makes functions available.
# This is tricky; for a real test framework, you'd have a more robust setup.
# As a simple approach, we'll try to source it if it's not breaking things.
# Or, more safely, just check for function existence.

if [ ! -f "$HOME/.bashrc" ]; then
    bash "$(dirname "$0")/../installer/install.sh" --non-interactive
fi

if [ -f "$HOME/.sentinel/bash_functions.d/venv_helpers" ]; then
    source "$HOME/.sentinel/bash_functions.d/venv_helpers"
fi

echo "--- Test Suite for New Features ---"

TEST_PASSED_COUNT=0
TEST_FAILED_COUNT=0

_run_test() {
    local test_name="$1"
    local command_to_run="$2"
    echo -n "Running test: $test_name ... "
    if eval "$command_to_run"; then
        echo -e "\033[0;32mPASSED\033[0m"
        TEST_PASSED_COUNT=$((TEST_PASSED_COUNT + 1))
    else
        echo -e "\033[0;31mFAILED\033[0m"
        TEST_FAILED_COUNT=$((TEST_FAILED_COUNT + 1))
    fi
}

_run_test "installer runs without errors" "bash $(dirname "$0")/../installer/install.sh --non-interactive"




# --- Summary ---
echo ""
echo "--- Test Summary ---"
echo -e "\033[0;32mTests Passed: $TEST_PASSED_COUNT\033[0m"
echo -e "\033[0;31mTests Failed: $TEST_FAILED_COUNT\033[0m"
echo "--------------------"

if [ "$TEST_FAILED_COUNT" -ne 0 ]; then
    exit 1
fi
exit 0
