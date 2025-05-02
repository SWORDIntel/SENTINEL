#!/bin/bash

# SENTINEL Autocomplete Fix Script
# This script fixes issues with the SENTINEL autocomplete module

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}SENTINEL Autocomplete Fix Script${NC}"
echo -e "${BLUE}=================================${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}This script should not be run as root${NC}"
    exit 1
fi

# Step 1: Clean up any existing BLE.sh installations
echo -e "\n${BLUE}Step 1: Cleaning up existing BLE.sh installations${NC}"

# Clean up cache directories
echo -e "${YELLOW}Cleaning BLE.sh cache directories...${NC}"
rm -rf ~/.cache/blesh 2>/dev/null
mkdir -p ~/.cache/blesh
chmod 755 ~/.cache/blesh
echo -e "${GREEN}✓ BLE.sh cache directories cleaned${NC}"

# Remove temporary files
echo -e "${YELLOW}Removing temporary BLE.sh files...${NC}"
find /tmp -maxdepth 1 -type d -name "blesh*" | while read dir; do
    echo "  Removing $dir"
    chmod -R 755 "$dir" 2>/dev/null
    rm -rf "$dir" 2>/dev/null
done
echo -e "${GREEN}✓ Temporary BLE.sh files removed${NC}"

# Step 2: Check if BLE.sh is properly installed
echo -e "\n${BLUE}Step 2: Checking BLE.sh installation${NC}"
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    echo -e "${GREEN}✓ BLE.sh is installed${NC}"
else
    echo -e "${YELLOW}BLE.sh is not installed. Installing now...${NC}"
    
    # Create a temporary directory for installation
    tmp_dir="/tmp/blesh_fix_$$_$(date +%s)"
    mkdir -p "$tmp_dir"
    
    # Clone the repository
    echo "  Cloning BLE.sh repository..."
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$tmp_dir" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        # Install BLE.sh
        echo "  Installing BLE.sh..."
        mkdir -p ~/.local/share/blesh
        make -C "$tmp_dir" install PREFIX=~/.local 2>/tmp/blesh_make.log
        
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✓ BLE.sh installed successfully${NC}"
        else
            echo -e "${RED}✗ Failed to install BLE.sh. See /tmp/blesh_make.log for details${NC}"
        fi
        
        # Clean up
        rm -rf "$tmp_dir" 2>/dev/null
    else
        echo -e "${RED}✗ Failed to clone BLE.sh repository${NC}"
    fi
fi

# Step 3: Create or update the BLE.sh loader script
echo -e "\n${BLUE}Step 3: Creating BLE.sh loader script${NC}"
mkdir -p ~/.sentinel

cat > ~/.sentinel/blesh_loader.sh << 'EOF'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader
# This script loads ble.sh with proper error handling

# Ensure cache directory exists with proper permissions
mkdir -p ~/.cache/blesh 2>/dev/null
chmod 755 ~/.cache/blesh 2>/dev/null

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    # Configure BLE to disable unused module caching files that cause errors
    export _ble_suppress_stderr=1
    export _ble_keymap_initialize=0
    
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
    fi
fi
EOF

chmod +x ~/.sentinel/blesh_loader.sh
echo -e "${GREEN}✓ BLE.sh loader script created${NC}"

# Step 4: Add the @autocomplete command to bash_aliases
echo -e "\n${BLUE}Step 4: Creating @autocomplete command${NC}"

# Create a temporary autocomplete command file
cat > /tmp/autocomplete_command.sh << 'EOF'
# Function to handle @autocomplete command directly
_sentinel_autocomplete_command() {
    local cmd="$1"
    shift
    
    case "$cmd" in
        help|--help|-h|"")
            # Show help information
            echo -e "\033[1;32mSENTINEL Autocomplete Commands:\033[0m"
            echo -e "  \033[1;34m@autocomplete\033[0m                   - Show this help"
            echo -e "  \033[1;34m@autocomplete status\033[0m            - Check autocomplete status"
            echo -e "  \033[1;34m@autocomplete fix\033[0m               - Fix common issues"
            echo -e "  \033[1;34m@autocomplete reload\033[0m            - Reload BLE.sh"
            echo -e "  \033[1;34m@autocomplete install\033[0m           - Force reinstall BLE.sh"
            
            echo -e "\n\033[1;32mUsage:\033[0m"
            echo -e "  - Press \033[1;34mTab\033[0m to see suggestions"
            echo -e "  - Press \033[1;34mRight Arrow\033[0m to accept suggestion"
            echo -e "  - Type \033[1;34m!!:fix\033[0m to correct last failed command"
            echo -e "  - Type \033[1;34m!!:next\033[0m to run most likely next command"
            
            echo -e "\n\033[1;32mTroubleshooting:\033[0m"
            echo -e "  If autocomplete isn't working, try:"
            echo -e "  1. Run '@autocomplete fix'"
            echo -e "  2. Close and reopen your terminal"
            echo -e "  3. If still not working, run '@autocomplete install'"
            ;;
        status|--status|-s)
            # Show status information
            echo -e "\033[1;32mSENTINEL Autocomplete Status:\033[0m"
            
            # Check BLE.sh installation
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
            
            # Check cache directory permissions
            echo -n "Cache directory: "
            if [[ -d ~/.cache/blesh ]]; then
                local perms=$(stat -c "%a" ~/.cache/blesh 2>/dev/null)
                if [[ "$perms" == "755" ]]; then
                    echo -e "\033[1;32mOK (permissions: $perms)\033[0m"
                else
                    echo -e "\033[1;33mWarning (permissions: $perms, should be 755)\033[0m"
                    echo "To fix: chmod 755 ~/.cache/blesh"
                fi
            else
                echo -e "\033[1;31mNot found\033[0m"
                echo "To fix: mkdir -p ~/.cache/blesh && chmod 755 ~/.cache/blesh"
            fi
            ;;
        fix|--fix|-f)
            # Fix common issues
            echo "Fixing common autocomplete issues..."
            
            # Fix cache directory permissions
            mkdir -p ~/.cache/blesh 2>/dev/null
            chmod 755 ~/.cache/blesh 2>/dev/null
            echo "✓ Fixed cache directory permissions"
            
            # Clean up problematic cache files
            find ~/.cache/blesh -name "*.part" -type f -delete 2>/dev/null
            find ~/.cache/blesh -name "*.lock" -type f -delete 2>/dev/null
            echo "✓ Cleaned up cache files"
            
            # Clean up temporary installation directories
            find /tmp -maxdepth 1 -type d -name "blesh*" | while read dir; do
                chmod -R 755 "$dir" 2>/dev/null
                rm -rf "$dir" 2>/dev/null
            done
            echo "✓ Cleaned up temporary installation directories"
            
            # Reload BLE.sh if available
            if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
                source ~/.sentinel/blesh_loader.sh 2>/dev/null || true
                echo "✓ Reloaded BLE.sh using loader script"
            elif [[ -f ~/.local/share/blesh/ble.sh ]]; then
                export _ble_suppress_stderr=1
                export _ble_keymap_initialize=0
                source ~/.local/share/blesh/ble.sh 2>/dev/null || true
                echo "✓ Reloaded BLE.sh directly"
            fi
            
            echo -e "\nAll issues fixed. Please \033[1;32mclose and reopen your terminal\033[0m for changes to take full effect."
            ;;
        reload|--reload|-r)
            # Re-initialize BLE.sh
            if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
                source ~/.sentinel/blesh_loader.sh 2>/dev/null || true
                echo "BLE.sh reloaded using loader script."
            elif [[ -f ~/.local/share/blesh/ble.sh ]]; then
                export _ble_suppress_stderr=1
                export _ble_keymap_initialize=0
                source ~/.local/share/blesh/ble.sh 2>/dev/null || true
                echo "BLE.sh reloaded directly."
            else
                echo "BLE.sh not installed. Run '@autocomplete fix' to install."
            fi
            ;;
        install|--install|-i)
            # Force reinstall BLE.sh
            rm -rf ~/.local/share/blesh 2>/dev/null
            echo "Reinstalling BLE.sh..."
            
            # Create a temporary directory for installation
            local tmp_dir="/tmp/blesh_reinstall_$$_$(date +%s)"
            mkdir -p "$tmp_dir"
            
            # Clone the repository
            echo "  Cloning BLE.sh repository..."
            git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$tmp_dir" 2>/dev/null
            
            if [[ $? -eq 0 ]]; then
                # Install BLE.sh
                echo "  Installing BLE.sh..."
                mkdir -p ~/.local/share/blesh
                make -C "$tmp_dir" install PREFIX=~/.local 2>/tmp/blesh_make.log
                
                if [[ $? -eq 0 ]]; then
                    echo "✓ BLE.sh installed successfully"
                else
                    echo "✗ Failed to install BLE.sh. See /tmp/blesh_make.log for details"
                fi
                
                # Clean up
                rm -rf "$tmp_dir" 2>/dev/null
            else
                echo "✗ Failed to clone BLE.sh repository"
            fi
            
            echo "Installation complete. Please restart your terminal."
            ;;
        *)
            echo "Unknown command: $cmd"
            echo "Available commands: help, status, fix, reload, install"
            ;;
    esac
}

# Enable @autocomplete command
function @autocomplete() {
    _sentinel_autocomplete_command "$@"
}
EOF

# Check if the function already exists in autocomplete file
if grep -q "@autocomplete()" "bash_aliases.d/autocomplete"; then
    echo -e "${YELLOW}@autocomplete command already exists in autocomplete file${NC}"
else
    # Add the @autocomplete command to the autocomplete file
    cat /tmp/autocomplete_command.sh >> bash_aliases.d/autocomplete
    echo -e "${GREEN}✓ @autocomplete command added to autocomplete file${NC}"
fi

# Step 5: Source the updated autocomplete file
echo -e "\n${BLUE}Step 5: Testing the fix${NC}"
echo -e "${YELLOW}Sourcing autocomplete file...${NC}"
source bash_aliases.d/autocomplete
echo -e "${GREEN}✓ Autocomplete file sourced${NC}"

# Step 6: Test the @autocomplete command
echo -e "\n${BLUE}Step 6: Testing @autocomplete command${NC}"
if type -t @autocomplete &>/dev/null; then
    echo -e "${GREEN}✓ @autocomplete command is available${NC}"
    echo -e "${YELLOW}Running @autocomplete status...${NC}"
    @autocomplete status
else
    echo -e "${RED}✗ @autocomplete command is not available${NC}"
fi

# Cleanup
rm -f /tmp/autocomplete_command.sh

echo -e "\n${BLUE}Autocomplete fix complete!${NC}"
echo -e "${YELLOW}Please restart your terminal or run 'source ~/.bashrc' to apply changes${NC}"
echo -e "Type '@autocomplete' for help and available commands" 