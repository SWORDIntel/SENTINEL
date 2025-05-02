#!/usr/bin/env bash
# SENTINEL Autocomplete Module Test
# Tests if the autocomplete module is working properly

echo "SENTINEL Autocomplete Module Test"
echo "================================"

# Test if ble.sh loader exists
if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
    echo "✓ ble.sh loader script found"
else
    echo "✗ ble.sh loader script not found"
fi

# Test if path_manager fix exists
if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then
    echo "✓ path_manager fix script found"
else
    echo "✗ path_manager fix script not found"
fi

# Test if ble.sh is installed
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    echo "✓ ble.sh installation found"
else
    echo "✗ ble.sh installation not found"
fi

# Test loading the ble.sh script
echo -n "Testing ble.sh loading: "
source ~/.sentinel/blesh_loader.sh 2>/dev/null
if type -t ble-bind &>/dev/null; then
    echo "✓ Success"
else
    echo "✗ Failed"
    echo "  (Not critical, will use fallback completion)"
fi

# Test path_manager fix
echo -n "Testing path_manager fix: "
source ~/.sentinel/fix_path_manager.sh 2>/dev/null
if type -t load_custom_paths &>/dev/null; then
    echo "✓ Success"
else
    echo "✗ Failed"
fi

# Test autocomplete directories
echo "Testing autocomplete directories:"
for dir in snippets context projects params; do
    if [[ -d ~/.sentinel/autocomplete/$dir ]]; then
        echo "✓ Directory ~/.sentinel/autocomplete/$dir exists"
    else
        echo "✗ Directory ~/.sentinel/autocomplete/$dir does not exist"
    fi
done

echo
echo "Test complete!"
echo "If you see any failures, try running fix_autocomplete.sh again"
echo "or restart your terminal." 