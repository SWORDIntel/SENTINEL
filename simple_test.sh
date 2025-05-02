#!/bin/bash

echo "Simple test script"
echo "Current directory: $(pwd)"
echo "Listing bash_aliases.d directory:"
ls -la bash_aliases.d/
echo "Sourcing autocomplete file:"
source ./bash_aliases.d/autocomplete || echo "Failed to source autocomplete file"
echo "Test complete" 