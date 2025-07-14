#!/usr/bin/env bash

# Clean test of module loading with dependency resolution

echo "=== SENTINEL Clean Module Loading Test ==="
echo

# Set up environment
export SENTINEL_MODULES_PATH="/opt/github/SENTINEL/bash_modules.d"
export MODULES_DIR="$SENTINEL_MODULES_PATH"
export SENTINEL_DEBUG_MODULES=0
export SENTINEL_QUIET_MODULES=0
export SENTINEL_SKIP_AUTO_LOAD=1  # Prevent automatic loading

# Source only the module functions without loading any modules
echo "Loading module system functions only..."
source /opt/github/SENTINEL/bash_modules

echo
echo "=== Testing Individual Module Loading with Dependencies ==="
echo

# Test loading a module that has dependencies
echo "1. Testing config_cache (depends on: logging)"
echo "   Initial state: No modules loaded"
echo

# Clear any loaded modules
unset SENTINEL_LOADED_MODULES
declare -gA SENTINEL_LOADED_MODULES

echo "   Loading config_cache..."
module_enable "config_cache" 0 "test"

echo
echo "   Loaded modules after loading config_cache:"
for module in "${!SENTINEL_LOADED_MODULES[@]}"; do
    if [[ "${SENTINEL_LOADED_MODULES[$module]}" == "1" ]]; then
        echo "     ✓ $module"
    fi
done

echo
echo "2. Testing module_manager (depends on: config_cache logging)"
echo "   Clearing all loaded modules..."

# Clear loaded modules again
unset SENTINEL_LOADED_MODULES
declare -gA SENTINEL_LOADED_MODULES

echo "   Loading module_manager..."
module_enable "module_manager" 0 "test"

echo
echo "   Loaded modules after loading module_manager:"
for module in "${!SENTINEL_LOADED_MODULES[@]}"; do
    if [[ "${SENTINEL_LOADED_MODULES[$module]}" == "1" ]]; then
        echo "     ✓ $module"
    fi
done

echo
echo "3. Testing sentinel_markov (depends on: logging config_cache)"
echo "   Clearing all loaded modules..."

# Clear loaded modules again
unset SENTINEL_LOADED_MODULES
declare -gA SENTINEL_LOADED_MODULES

echo "   Loading sentinel_markov..."
module_enable "sentinel_markov" 0 "test"

echo
echo "   Loaded modules after loading sentinel_markov:"
for module in "${!SENTINEL_LOADED_MODULES[@]}"; do
    if [[ "${SENTINEL_LOADED_MODULES[$module]}" == "1" ]]; then
        echo "     ✓ $module"
    fi
done

echo
echo "=== Summary ==="
echo "Dependency resolution test complete."
echo "If dependencies are properly configured, you should see:"
echo "  - config_cache loading should also load: logging"
echo "  - module_manager loading should also load: config_cache and logging"
echo "  - sentinel_markov loading should also load: logging and config_cache"