#!/usr/bin/env bash
# Test script for SENTINEL health check module

# Source the module system
source /opt/github/SENTINEL/bash_modules

# Enable health check module
echo "Loading health check module..."
module_enable health_check

# Run some tests
echo -e "\n=== Testing Health Check System ===\n"

# 1. Check module status
echo "1. Checking module health status:"
health_check status

# 2. Check specific module
echo -e "\n2. Checking logging module health:"
health_check check logging

# 3. Register a custom health check
echo -e "\n3. Registering custom health check:"
test_module_health() {
    # Simple test - always returns healthy
    return 0
}
register_health_check "test_module" test_module_health

# 4. Check all modules
echo -e "\n4. Checking all modules:"
health_check check

# 5. Simulate a module with issues
echo -e "\n5. Simulating module failure:"
failing_module_health() {
    echo "Test failure condition"
    return 1
}
register_health_check "failing_test" failing_module_health
SENTINEL_LOADED_MODULES["failing_test"]=1
health_check check failing_test

# 6. Show final status
echo -e "\n6. Final health status:"
health_check status

echo -e "\n=== Health Check Test Complete ===\n"