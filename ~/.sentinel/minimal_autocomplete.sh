#!/usr/bin/env bash
# SENTINEL Minimal Autocomplete Status Function
# This is a minimal implementation to fix missing function errors

# Function to display autocomplete status and help
_sentinel_autocomplete_status() {
    echo -e "\033[1;32mSENTINEL Autocomplete Status (Minimal Version):\033[0m"
    
    # Check BLE.sh
    echo -n "BLE.sh installation: "
    if [[ -f ~/.local/share/blesh/ble.sh ]]; then
        echo -e "\033[1;32mInstalled\033[0m"
    else
        echo -e "\033[1;31mNot installed\033[0m"
    fi
    
    # Check if BLE.sh is loaded
    echo -n "BLE.sh loaded: "
    if type -t ble-bind &>/dev/null; then
        echo -e "\033[1;32mYes\033[0m"
    else
        echo -e "\033[1;31mNo\033[0m"
    fi
    
    echo -e "\n\033[1;32mTroubleshooting:\033[0m"
    echo -e " 1. Run: bash ~/blesh_fix/fix_blesh.sh"
    echo -e " 2. Close and reopen your terminal"
}

# Export the function for availability
export -f _sentinel_autocomplete_status

# Function to fix common autocomplete issues
_sentinel_autocomplete_fix() {
    echo "Fixing common autocomplete issues..."
    bash ~/blesh_fix/fix_blesh.sh
}

# Export the fix function
export -f _sentinel_autocomplete_fix

echo "Minimal autocomplete functions loaded." 