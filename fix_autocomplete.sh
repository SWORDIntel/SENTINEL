#!/usr/bin/env bash
# SENTINEL Autocomplete Fix Script
# This script fixes issues with the autocomplete module and ble.sh integration

# Continue on errors but report them
set +e

echo "SENTINEL Autocomplete Module Fix"
echo "==============================="

# Ensure proper permissions on all script files
echo "Setting executable permissions on all script files..."
find bash_functions.d/ -type f -exec chmod +x {} \; 2>/dev/null || echo "Warning: Could not set permissions on some files in bash_functions.d/"
find bash_aliases.d/ -type f -exec chmod +x {} \; 2>/dev/null || echo "Warning: Could not set permissions on some files in bash_aliases.d/"
find bash_modules.d/ -type f -exec chmod +x {} \; 2>/dev/null || echo "Warning: Could not set permissions on some files in bash_modules.d/"
find bash_completion.d/ -type f -exec chmod +x {} \; 2>/dev/null || echo "Warning: Could not set permissions on some files in bash_completion.d/"

# Ensure proper directories exist
echo "Creating required directories..."
mkdir -p ~/.sentinel/autocomplete/snippets 2>/dev/null
mkdir -p ~/.sentinel/autocomplete/context 2>/dev/null
mkdir -p ~/.sentinel/autocomplete/projects 2>/dev/null
mkdir -p ~/.sentinel/autocomplete/params 2>/dev/null

# Create a simple ble.sh loader
echo "Creating ble.sh loader script..."
cat > ~/.sentinel/blesh_loader.sh << 'EOF'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader
# This script loads ble.sh with proper error handling

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    # Try the standard loading method first
    source ~/.local/share/blesh/ble.sh 2>/dev/null
    
    # Check if it worked
    if ! type -t ble-bind &>/dev/null; then
        echo "Warning: ble.sh did not load properly. Trying alternative loading method..."
        # Try alternative loading with a different approach
        source <(cat ~/.local/share/blesh/ble.sh) 2>/dev/null
        
        # If still not working, fall back to basic completion
        if ! type -t ble-bind &>/dev/null; then
            echo "Warning: ble.sh could not be loaded. Using basic autocompletion instead."
            # Load bash standard completion as fallback
            [[ -f /etc/bash_completion ]] && source /etc/bash_completion
        fi
    fi
fi
EOF
chmod +x ~/.sentinel/blesh_loader.sh

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
chmod +x ~/.sentinel/fix_path_manager.sh

# Add loader to bashrc if not already there
if ! grep -q "~/.sentinel/blesh_loader.sh" ~/.bashrc; then
    echo "Adding ble.sh loader to ~/.bashrc..."
    echo '# SENTINEL ble.sh integration' >> ~/.bashrc
    echo 'if [[ -f ~/.sentinel/blesh_loader.sh ]]; then' >> ~/.bashrc
    echo '    source ~/.sentinel/blesh_loader.sh' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
fi

# Add path_manager fix to .bashrc if not already there
if ! grep -q "~/.sentinel/fix_path_manager.sh" ~/.bashrc; then
    echo "Adding path_manager fix to ~/.bashrc..."
    echo '# SENTINEL path_manager fix' >> ~/.bashrc
    echo 'if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then' >> ~/.bashrc
    echo '    source ~/.sentinel/fix_path_manager.sh' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
fi

# Clean up any temporary files
echo "Cleaning up temporary files..."
find /tmp -maxdepth 1 -type d -name "blesh*" -exec rm -rf {} \; 2>/dev/null || true

echo
echo "Fix complete! Please restart your terminal or run:"
echo "source ~/.sentinel/blesh_loader.sh"
echo "source ~/.sentinel/fix_path_manager.sh" 