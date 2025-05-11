#!/usr/bin/env bash
# SENTINEL Autocomplete Modules Test Script
# This script tests the modular loading of the SENTINEL autocomplete system
# Run with: bash test_modules.sh

# Enable better error reporting
set -o pipefail
set -E

echo "=== SENTINEL Autocomplete Modules Test ==="
echo "Testing module loader and dependencies"

# Directory where the modules are located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Module directory: $SCRIPT_DIR"

# List of modules to test
MODULES=(
    "autocomplete_manager.sh"
    "blesh_module.sh"
    "categories_module.sh"
)

# Function to test if a module can be properly sourced
test_module() {
    local module="$1"
    local module_path="$SCRIPT_DIR/$module"
    
    echo -e "\n=== Testing module: $module ==="
    
    if [[ ! -f "$module_path" ]]; then
        echo "ERROR: Module file not found: $module_path"
        return 1
    fi
    
    echo "Module exists at: $module_path"
    
    # Create a temporary subshell to test loading the module
    (
        echo "Attempting to source module..."
        # Source the module and capture any errors
        if source "$module_path" > /tmp/module_output.log 2>&1; then
            echo "SUCCESS: Module loaded without errors"
            cat /tmp/module_output.log
            return 0
        else
            echo "ERROR: Failed to load module. Error output:"
            cat /tmp/module_output.log
            return 1
        fi
    )
    
    local result=$?
    if [[ $result -eq 0 ]]; then
        echo "Module test passed"
    else
        echo "Module test failed"
    fi
    
    return $result
}

# Main test function
run_tests() {
    echo -e "\n=== Starting module tests ==="
    local failed=0
    
    # Test each module individually
    for module in "${MODULES[@]}"; do
        if ! test_module "$module"; then
            ((failed++))
        fi
    done
    
    # Test loading the main autocomplete manager (which should load all other modules)
    echo -e "\n=== Testing full module system load ==="
    if [[ -f "$SCRIPT_DIR/autocomplete_manager.sh" ]]; then
        echo "Loading main autocomplete manager..."
        source "$SCRIPT_DIR/autocomplete_manager.sh"
        
        # Check if modules were loaded
        echo -e "\n=== Checking loaded modules ==="
        if type -t sentinel_autocomplete_list_modules &>/dev/null; then
            sentinel_autocomplete_list_modules
        else
            echo "ERROR: sentinel_autocomplete_list_modules function not found"
            ((failed++))
        fi
    else
        echo "ERROR: Main autocomplete manager not found"
        ((failed++))
    fi
    
    # Report test results
    echo -e "\n=== Test Summary ==="
    if [[ $failed -eq 0 ]]; then
        echo "All tests passed successfully"
    else
        echo "Failed tests: $failed"
    fi
    
    return $failed
}

# Run the tests
run_tests
exit $? 