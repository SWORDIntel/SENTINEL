#!/bin/bash

# Test script for SENTINEL autocomplete module
echo "Testing SENTINEL autocomplete module..."

# Clear previous BLE cache files
echo "Clearing BLE.sh cache..."
rm -rf ~/.cache/blesh 2>/dev/null
mkdir -p ~/.cache/blesh
chmod 755 ~/.cache/blesh

# Source the autocomplete module
echo "Loading autocomplete module..."
source ~/Documents/GitHub/SENTINEL/bash_aliases.d/autocomplete

# Run status command
echo -e "\nTesting @autocomplete command..."
@autocomplete status

echo -e "\nTesting autocomplete functionality..."
echo "Hint: Try typing a command and pressing Tab or Right arrow to see suggestions"
echo "For example: 'git' (Right arrow) or 'ssh' (Tab)"

echo -e "\nDone! Type '@autocomplete' for help and available commands." 