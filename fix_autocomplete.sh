#!/usr/bin/env bash
# SENTINEL Autocomplete Fix Script
# This script fixes issues with the autocomplete module and ble.sh integration

# Continue on errors but report them
set +e

echo "SENTINEL Autocomplete Module Fix"
echo "==============================="

# Add error handling function
handle_error() {
  echo "ERROR: $1"
  # Continue despite errors
}

# Ensure proper permissions on all script files
echo "Setting executable permissions on all script files..."
find bash_functions.d/ -type f -exec chmod +x {} \; 2>/dev/null || handle_error "Could not set permissions on some files in bash_functions.d/"
find bash_aliases.d/ -type f -exec chmod +x {} \; 2>/dev/null || handle_error "Could not set permissions on some files in bash_aliases.d/"
find bash_modules.d/ -type f -exec chmod +x {} \; 2>/dev/null || handle_error "Could not set permissions on some files in bash_modules.d/"
find bash_completion.d/ -type f -exec chmod +x {} \; 2>/dev/null || handle_error "Could not set permissions on some files in bash_completion.d/"

# Ensure proper directories exist
echo "Creating required directories..."
mkdir -p ~/.sentinel/autocomplete/snippets 2>/dev/null
mkdir -p ~/.sentinel/autocomplete/context 2>/dev/null
mkdir -p ~/.sentinel/autocomplete/projects 2>/dev/null
mkdir -p ~/.sentinel/autocomplete/params 2>/dev/null

# Aggressive cleanup of ble.sh cache files
echo "Aggressively cleaning ble.sh cache files..."
if [[ -d ~/.cache/blesh ]]; then
  # First try to fix permissions
  chmod -R 755 ~/.cache/blesh 2>/dev/null || handle_error "Failed to fix permissions on ~/.cache/blesh"
  
  # Try to remove specific problematic files
  echo "Removing potentially corrupted cache files..."
  find ~/.cache/blesh -type f -name "*.part" -delete 2>/dev/null || true
  find ~/.cache/blesh -type f -name "decode.readline*.txt*" -delete 2>/dev/null || true
  
  # Clean up the entire 0.4 directory that's causing problems
  if [[ -d ~/.cache/blesh/0.4 ]]; then
    echo "Removing problematic blesh cache directory..."
    chmod -R 755 ~/.cache/blesh/0.4 2>/dev/null || true
    rm -rf ~/.cache/blesh/0.4 2>/dev/null || handle_error "Failed to remove ~/.cache/blesh/0.4"
  fi
fi

# Create a simple ble.sh loader
echo "Creating ble.sh loader script..."
cat > ~/.sentinel/blesh_loader.sh << 'EOF'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader
# This script loads ble.sh with proper error handling

# Clean up any stale cache files that might be causing issues
cleanup_stale_cache() {
  if [[ -d ~/.cache/blesh ]]; then
    # Try to fix permissions
    chmod -R 755 ~/.cache/blesh 2>/dev/null || true
    
    # Attempt to clean any .part files that might be causing issues
    find ~/.cache/blesh -name "*.part" -type f -delete 2>/dev/null || true
    
    # Clean decode.readline files that are causing errors
    find ~/.cache/blesh -name "decode.readline.*.txt*" -type f -delete 2>/dev/null || true
  fi
}

# Run cleanup before loading
cleanup_stale_cache

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    source ~/.local/share/blesh/ble.sh 2>/dev/null
    if ! type -t ble-bind &>/dev/null; then
        echo "Warning: ble.sh did not load properly. Trying alternative loading method..."
        # Try alternative loading with a different approach
        source <(cat ~/.local/share/blesh/ble.sh) 2>/dev/null
        
        if ! type -t ble-bind &>/dev/null; then
            echo "Warning: ble.sh could not be loaded. Using basic autocompletion instead."
            # Load bash standard completion as fallback
            [[ -f /etc/bash_completion ]] && source /etc/bash_completion
        fi
    else
        # Configure predictive suggestion settings
        bleopt complete_auto_delay=100 2>/dev/null || true
        bleopt complete_auto_complete=1 2>/dev/null || true
        bleopt highlight_auto_completion='fg=242' 2>/dev/null || true
        
        # Configure key bindings
        ble-bind -m auto_complete -f right 'auto_complete/accept-line' 2>/dev/null || true
    fi
fi
EOF
chmod +x ~/.sentinel/blesh_loader.sh || handle_error "Failed to set permissions on blesh_loader.sh"

# Create fix for path_manager.sh if it's causing problems
echo "Creating path_manager fix script..."
cat > ~/.sentinel/fix_path_manager.sh << 'EOF'
#!/usr/bin/env bash
# Fix for path_manager.sh loading issues

# Create a simplified version of the PATH management functionality
PATH_CONFIG_FILE="${HOME}/.sentinel_paths"

# Initialize path config file if it doesn't exist
[[ ! -f "${PATH_CONFIG_FILE}" ]] && touch "${PATH_CONFIG_FILE}"

# Load paths from configuration
load_custom_paths() {
    if [[ -f "${PATH_CONFIG_FILE}" ]]; then
        while IFS= read -r path_entry; do
            # Skip comments and empty lines
            [[ -z "${path_entry}" || "${path_entry}" =~ ^# ]] && continue
            
            # Only add if directory exists and isn't already in PATH
            if [[ -d "${path_entry}" && ":${PATH}:" != *":${path_entry}:"* ]]; then
                export PATH="${path_entry}:${PATH}"
            fi
        done < "${PATH_CONFIG_FILE}"
    fi
}

# Load custom paths
load_custom_paths
EOF
chmod +x ~/.sentinel/fix_path_manager.sh || handle_error "Failed to set permissions on fix_path_manager.sh"

# Add loader to bashrc if not already there
if ! grep -q "~/.sentinel/blesh_loader.sh" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# SENTINEL automatic fixes for ble.sh and path_manager" >> ~/.bashrc
    echo "if [[ -f ~/.sentinel/blesh_loader.sh ]]; then" >> ~/.bashrc
    echo "    source ~/.sentinel/blesh_loader.sh" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
    echo "if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then" >> ~/.bashrc
    echo "    source ~/.sentinel/fix_path_manager.sh" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
    echo "Added fixes to ~/.bashrc"
else
    echo "Fixes already in ~/.bashrc"
fi

echo ""
echo "Fixes applied. Please open a new terminal or run the following commands:"
echo "source ~/.sentinel/blesh_loader.sh"
echo "source ~/.sentinel/fix_path_manager.sh"
echo ""
echo "If problems persist, you may need to rebuild the ble.sh cache by removing ~/.cache/blesh directory." 