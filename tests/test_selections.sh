#!/usr/bin/env bash

# Test script for installer selections

# Source test framework
source "$(dirname "$0")/test_framework.sh" 2>/null || {
    # Simple test framework
    TESTS_PASSED=0
    TESTS_FAILED=0

    test_start() {
        echo "=== Testing Installer Selections ==="
        echo
    }

    test_case() {
        echo -n "Testing $1... "
    }

    test_pass() {
        echo -e "\033[32mPASSED\033[0m"
        ((TESTS_PASSED++))
    }

    test_fail() {
        echo -e "\033[31mFAILED\033[0m: $1"
        ((TESTS_FAILED++))
    }

    test_summary() {
        echo
        echo "=== Test Summary ==="
        echo "Passed: $TESTS_PASSED"
        echo "Failed: $TESTS_FAILED"
        echo
        [[ $TESTS_FAILED -eq 0 ]] && return 0 || return 1
    }
}

# Test setup
test_setup() {
    export SENTINEL_ROOT_DIR="/tmp/sentinel_test_$$"
    export SENTINEL_INSTALL_DIR="$SENTINEL_ROOT_DIR/.sentinel"
    export SENTINEL_CONFIG_FILE="$SENTINEL_INSTALL_DIR/config/config.yaml"
    mkdir -p "$SENTINEL_INSTALL_DIR/config"
    cp "$(dirname "$0")/../config.yaml.dist" "$SENTINEL_CONFIG_FILE"
}

# Test cleanup
test_cleanup() {
    rm -rf "$SENTINEL_ROOT_DIR"
}

# Tests
test_zsh_selection() {
    test_case "zsh shell selection"

    bash "$(dirname "$0")/../installer/install.sh" --non-interactive &> /dev/null

    yq -i -y ".shell.preferred = \"zsh\"" "$SENTINEL_CONFIG_FILE"

    if grep -q "preferred: zsh" "$SENTINEL_CONFIG_FILE"; then
        test_pass
    else
        test_fail "zsh not selected"
    fi
}

# Main test execution
main() {
    test_start
    test_setup

    # Run tests
    test_zsh_selection

    test_cleanup
    test_summary
}

# Run tests
main "$@"
