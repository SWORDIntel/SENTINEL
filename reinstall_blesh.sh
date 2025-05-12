#!/usr/bin/env bash
# Clean reinstall of BLE.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Performing clean reinstall of BLE.sh${NC}"

# Clean up existing installation
echo -e "${YELLOW}Removing existing BLE.sh installation...${NC}"
rm -rf ~/.local/share/blesh
rm -rf ~/.cache/blesh

# Create cache directory with correct permissions
echo -e "${YELLOW}Creating cache directory...${NC}"
mkdir -p ~/.cache/blesh
chmod 755 ~/.cache/blesh

# Temporary directory for installation
echo -e "${YELLOW}Setting up temporary directory...${NC}"
TMP_DIR=$(mktemp -d /tmp/blesh_install_XXXXXX)
cd "$TMP_DIR" || { echo "Failed to create temp directory"; exit 1; }

# Download and install BLE.sh
echo -e "${YELLOW}Downloading BLE.sh...${NC}"
if ! git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git .; then
    echo -e "${RED}Failed to download BLE.sh${NC}"
    cd - >/dev/null
    rm -rf "$TMP_DIR"
    exit 1
fi

echo -e "${YELLOW}Installing BLE.sh...${NC}"
if ! make install PREFIX=~/.local; then
    echo -e "${RED}Failed to install BLE.sh${NC}"
    cd - >/dev/null
    rm -rf "$TMP_DIR"
    exit 1
fi

# Cleanup
cd - >/dev/null
rm -rf "$TMP_DIR"

echo -e "${GREEN}BLE.sh reinstalled successfully${NC}"

# Create minimal test loader
echo -e "${YELLOW}Creating minimal test loader...${NC}"
cat > ~/.sentinel/minimal_blesh.sh << 'EOL'
#!/usr/bin/env bash
# Minimal BLE.sh test loader

# Load BLE.sh directly
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    source ~/.local/share/blesh/ble.sh
    echo "BLE.sh loaded successfully"
    
    # Set minimal options
    bleopt complete_auto_delay=100
    bleopt complete_auto_complete=1
    
    # Print available options for reference
    echo "Available complete options:"
    bleopt | grep complete
    
    echo "Available highlight options:"
    bleopt | grep highlight
else
    echo "BLE.sh not found"
fi
EOL

chmod +x ~/.sentinel/minimal_blesh.sh

echo -e "${GREEN}Created minimal test loader at ~/.sentinel/minimal_blesh.sh${NC}"
echo -e "${YELLOW}You can test it with: source ~/.sentinel/minimal_blesh.sh${NC}" 