#!/usr/bin/env bash
# SENTINEL BLE.sh Fix Script
# This script will fix BLE.sh issues by performing a clean re-installation

# Exit on error
set -e

echo "========================================================"
echo "SENTINEL BLE.sh Repair Tool"
echo "========================================================"

# Create backup of current BLE.sh installation
if [[ -d ~/.local/share/blesh ]]; then
    echo "→ Creating backup of current BLE.sh installation..."
    BACKUP_DIR=~/blesh_backup_$(date +%Y%m%d_%H%M%S)
    mkdir -p "$BACKUP_DIR"
    cp -r ~/.local/share/blesh/* "$BACKUP_DIR/" 2>/dev/null || true
    echo "✓ Backup created at $BACKUP_DIR"
else
    echo "→ No existing BLE.sh installation found to backup"
fi

# Clean up any existing installation
echo "→ Cleaning up existing BLE.sh installation..."
rm -rf ~/.local/share/blesh
rm -f ~/.sentinel/blesh_loader.sh
rm -f ~/.sentinel/simple_blesh.sh
rm -f ~/.sentinel/ble.sh
rm -f ~/.sentinel/minimal_blesh.sh
find /tmp -maxdepth 1 -type d -name "blesh*" -exec rm -rf {} \; 2>/dev/null || true
echo "✓ Cleanup complete"

# Clean up cache directory
echo "→ Cleaning cache directory..."
if [[ -d ~/.cache/blesh ]]; then
    rm -rf ~/.cache/blesh
fi
mkdir -p ~/.cache/blesh
chmod 755 ~/.cache/blesh
echo "✓ Cache directory reset"

# Create temp directory for installation
echo "→ Creating temporary directory for installation..."
TMP_DIR=$(mktemp -d /tmp/blesh_fix_XXXXXX)
cd "$TMP_DIR"
echo "✓ Using temporary directory: $TMP_DIR"

# Download and install BLE.sh
echo "→ Downloading BLE.sh..."
if ! git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git .; then
    echo "× Failed to download BLE.sh"
    exit 1
fi

echo "→ Installing BLE.sh..."
if ! make install PREFIX=~/.local; then
    echo "× Failed to install BLE.sh"
    exit 1
fi
echo "✓ BLE.sh installed successfully"

# Create simple loader
echo "→ Creating simple loader..."
cat > ~/.sentinel/blesh_loader.sh << 'EOL'
#!/usr/bin/env bash
# SENTINEL BLE.sh Simple Loader v2.0
# Ultra-simplified loader with minimal dependencies

# Prepare cache directory
mkdir -p ~/.cache/blesh 2>/dev/null
chmod 755 ~/.cache/blesh 2>/dev/null

# Load BLE.sh directly
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
  # Try to load without any fancy handling
  source ~/.local/share/blesh/ble.sh 2>/dev/null
  
  # Check if loaded successfully
  if type -t ble-bind &>/dev/null; then
    # Configure basic settings
    bleopt complete_auto_delay=100 2>/dev/null
    bleopt complete_auto_complete=1 2>/dev/null
    bleopt highlight_auto_completion='fg=242' 2>/dev/null
    export SENTINEL_BLESH_LOADED=1
  else
    # Fall back to basic completion
    [[ -f /etc/bash_completion ]] && source /etc/bash_completion
    export SENTINEL_BLESH_LOADED=0
  fi
else
  # BLE.sh not found
  [[ -f /etc/bash_completion ]] && source /etc/bash_completion
  export SENTINEL_BLESH_LOADED=0
fi
EOL
chmod +x ~/.sentinel/blesh_loader.sh
echo "✓ Loader created"

# Clean up
echo "→ Cleaning up..."
cd ~ && rm -rf "$TMP_DIR"
echo "✓ Temporary files removed"

# Test the loader
echo "→ Testing BLE.sh loader..."
source ~/.sentinel/blesh_loader.sh

# Check if it worked
if [[ "$SENTINEL_BLESH_LOADED" == "1" ]]; then
    echo "✓ BLE.sh loaded successfully!"
    echo "✓ All fixes have been applied"
else
    echo "× BLE.sh loader test failed"
    echo "× Please run 'source ~/.sentinel/blesh_loader.sh' manually to check for errors"
fi

echo "========================================================"
echo "Repair complete! Please restart your terminal for changes to take full effect."
echo "========================================================" 