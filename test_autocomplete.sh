#!/usr/bin/env bash
# Test the autocomplete module

echo "Testing SENTINEL autocomplete module..."

# Clear BLE.sh cache for clean testing
echo "Clearing BLE.sh cache..."
if [[ -d ~/.cache/blesh ]]; then
    rm -rf ~/.cache/blesh/*
fi
mkdir -p ~/.cache/blesh 2>/dev/null

# Source minimal functions first to avoid errors
if [[ -f ~/.sentinel/minimal_autocomplete.sh ]]; then
    source ~/.sentinel/minimal_autocomplete.sh
fi

echo "Loading autocomplete module..."
source ./bash_aliases.d/autocomplete

echo "Testing @autocomplete command..."
@autocomplete status

echo -e "\nTesting autocomplete functionality..."
echo "Hint: Try typing a command and pressing Tab or Right arrow to see suggestions"
echo "For example: 'git' (Right arrow) or 'ssh' (Tab)"
echo -e "\nDone! Type '@autocomplete' for help and available commands." 