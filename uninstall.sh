#!/usr/bin/env bash
# SENTINEL Uninstallation Script
# Version: 2.0
# This script uninstalls the SENTINEL system and restores original configurations

# Set strict error handling
set -o pipefail

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}"
echo "███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗      "
echo "██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║      "
echo "███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║      "
echo "╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║      "
echo "███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗ "
echo "╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝ "
echo -e "${NC}"
echo -e "${RED}Uninstallation Script${NC}"
echo

# Ask for confirmation
echo -e "${YELLOW}This script will uninstall SENTINEL from your system.${NC}"
echo -e "${YELLOW}All SENTINEL configurations will be removed.${NC}"
echo -e "${YELLOW}Your original configuration files will be restored if backups exist.${NC}"
echo
read -p "Are you sure you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo -e "${GREEN}Uninstallation aborted.${NC}"
    exit 0
fi

# Function to restore a backup if it exists
restore_backup() {
    local file="$1"
    
    # Check for backups with .bak extension
    local backup_files=( $(ls -1 "${file}.bak"* 2>/dev/null) )
    
    if [[ ${#backup_files[@]} -gt 0 ]]; then
        # Get the most recent backup
        local most_recent="${backup_files[${#backup_files[@]}-1]}"
        
        echo -e "${YELLOW}Restoring ${file} from backup: ${most_recent}${NC}"
        cp "$most_recent" "$file"
        return 0
    fi
    
    return 1
}

# Function to remove a file if it's a symlink to SENTINEL
remove_if_sentinel_link() {
    local file="$1"
    local sentinel_pattern="$2"
    
    if [[ -L "$file" && $(readlink "$file") == *"$sentinel_pattern"* ]]; then
        echo -e "${YELLOW}Removing SENTINEL symlink: ${file}${NC}"
        rm -f "$file"
        return 0
    fi
    
    return 1
}

# Function to remove SENTINEL integration from a file
remove_integration() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        echo -e "${YELLOW}Removing SENTINEL integration from ${file}${NC}"
        
        # Create temporary file
        local tmpfile=$(mktemp)
        
        # Find and remove SENTINEL integration block
        sed '/# SENTINEL Integration/,/# End of SENTINEL Integration/d' "$file" > "$tmpfile"
        
        # Replace original file
        mv "$tmpfile" "$file"
    fi
}

# Create a backup directory for SENTINEL files before removal
BACKUP_DIR="${HOME}/.sentinel_backup_$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}Created backup directory: ${BACKUP_DIR}${NC}"

# Back up .sentinel directory if it exists
if [[ -d "${HOME}/.sentinel" ]]; then
    echo -e "${YELLOW}Backing up .sentinel directory...${NC}"
    cp -r "${HOME}/.sentinel" "$BACKUP_DIR/"
    echo -e "${GREEN}✓ Backed up .sentinel directory${NC}"
fi

# Remove SENTINEL integration from .bashrc
echo -e "${BLUE}Removing SENTINEL integration from .bashrc...${NC}"
remove_integration "${HOME}/.bashrc"

# Remove SENTINEL symlinks
echo -e "${BLUE}Removing SENTINEL symlinks...${NC}"
remove_if_sentinel_link "${HOME}/.bashrc.sentinel" "SENTINEL/bashrc"
remove_if_sentinel_link "${HOME}/.bash_aliases.sentinel" "SENTINEL/bash_aliases"
remove_if_sentinel_link "${HOME}/.bash_functions.sentinel" "SENTINEL/bash_functions"
remove_if_sentinel_link "${HOME}/.bash_completion.sentinel" "SENTINEL/bash_completion"
remove_if_sentinel_link "${HOME}/.bash_modules.sentinel" "SENTINEL/bash_modules"

# Try to restore original files from backups
echo -e "${BLUE}Restoring original files from backups...${NC}"
restore_backup "${HOME}/.bashrc" || echo -e "${YELLOW}⚠ No backup found for .bashrc${NC}"
restore_backup "${HOME}/.bash_aliases" || echo -e "${YELLOW}⚠ No backup found for .bash_aliases${NC}"
restore_backup "${HOME}/.bash_functions" || echo -e "${YELLOW}⚠ No backup found for .bash_functions${NC}"
restore_backup "${HOME}/.bash_completion" || echo -e "${YELLOW}⚠ No backup found for .bash_completion${NC}"

# Ask before removing .sentinel directory
echo
echo -e "${RED}Warning: The following action will permanently delete SENTINEL data${NC}"
read -p "Remove the .sentinel directory and all its contents? (y/n): " remove_data
if [[ "$remove_data" == "y" ]]; then
    echo -e "${YELLOW}Removing .sentinel directory...${NC}"
    rm -rf "${HOME}/.sentinel"
    echo -e "${GREEN}✓ Removed .sentinel directory${NC}"
else
    echo -e "${YELLOW}Keeping .sentinel directory for reference.${NC}"
    echo -e "${YELLOW}You can manually remove it later with: rm -rf ${HOME}/.sentinel${NC}"
fi

# Final message
echo
echo -e "${GREEN}SENTINEL has been successfully uninstalled.${NC}"
echo -e "${YELLOW}A backup of your SENTINEL configuration was saved to: ${BACKUP_DIR}${NC}"
echo -e "${YELLOW}Please restart your terminal for changes to take effect.${NC}"
echo
echo -e "${BLUE}Thank you for using SENTINEL!${NC}"
echo

# --- Enhanced SENTINEL and BLE.sh Cleanup Section ---
# Remove all SENTINEL and BLE.sh files, configs, logs, and loader scripts
SENTINEL_PATHS=(
    "${HOME}/.sentinel"
    "${HOME}/.local/share/blesh"
    "${HOME}/.cache/blesh"
    "${HOME}/.blerc"
    "${HOME}/.sentinel/blesh_loader.sh"
    "${HOME}/.sentinel/logs"
    "${HOME}/.sentinel/autocomplete"
    "${HOME}/.sentinel_backup_*"
    "${HOME}/.bash_modules.d/blesh_installer.module"
    "${HOME}/.bash_modules.d/command_chains.module"
    "${HOME}/.bash_modules.d/fuzzy_correction.module"
    "${HOME}/.bash_modules.d/logging.module"
    "${HOME}/.bash_modules.d/hmac.module"
    "${HOME}/.bash_modules.d/autocomplete.module"
    "${HOME}/.bash_modules.d/shell_security.module"
)

for path in "${SENTINEL_PATHS[@]}"; do
    if [[ -e $path || -L $path ]]; then
        echo -e "${YELLOW}Removing $path ...${NC}"
        rm -rf $path
        if [[ ! -e $path && ! -L $path ]]; then
            echo -e "${GREEN}✓ Removed $path${NC}"
        else
            echo -e "${RED}⚠ Failed to remove $path${NC}"
        fi
    fi
    # Security: Ensure no world-writable files remain
    if [[ -e $path ]]; then
        chmod -R go-w "$path" 2>/dev/null
    fi
    # Idempotency: Safe to run multiple times
    # No error if file/dir does not exist
    true
done

# Remove SENTINEL and BLE.sh references from shell config files (hardened)
CONFIG_FILES=(
    "${HOME}/.bashrc"
    "${HOME}/.bashrc.postcustom"
    "${HOME}/.bashrc.precustom"
)
for file in "${CONFIG_FILES[@]}"; do
    if [[ -f $file ]]; then
        echo -e "${YELLOW}Sanitizing $file for all SENTINEL/BLE.sh loader lines...${NC}"
        # Remove any lines referencing blesh_loader.sh, BLE.sh, SENTINEL, or loader/cleanup scripts
        sed -i \
            -e '/blesh_loader\.sh/d' \
            -e '/BLE\.sh/d' \
            -e '/SENTINEL/d' \
            -e '/sentinel/d' \
            -e '/cleanup_blesh\.sh/d' \
            -e '/@autocomplete/d' \
            -e '/_sentinel_check_blesh/d' \
            -e '/autocomplete.module/d' \
            "$file"
        echo -e "${GREEN}✓ Cleaned $file${NC}"
    fi
    true
done

# Final syntax check for .bashrc and .bashrc.postcustom
for checkfile in "${HOME}/.bashrc" "${HOME}/.bashrc.postcustom"; do
    if [[ -f "$checkfile" ]]; then
        if ! bash -n "$checkfile"; then
            echo -e "${RED}⚠ Syntax error remains in $checkfile after uninstall. Please review manually.${NC}"
        else
            echo -e "${GREEN}✓ $checkfile passes syntax check after uninstall.${NC}"
        fi
    fi
done

# Remove SENTINEL symlinks and module registry files
SYMLINKS=(
    "${HOME}/.bashrc.sentinel"
    "${HOME}/.bash_aliases.sentinel"
    "${HOME}/.bash_functions.sentinel"
    "${HOME}/.bash_completion.sentinel"
    "${HOME}/.bash_modules.sentinel"
    "${HOME}/.bash_modules"
)
for link in "${SYMLINKS[@]}"; do
    if [[ -L $link || -f $link ]]; then
        echo -e "${YELLOW}Removing $link ...${NC}"
        rm -f "$link"
        echo -e "${GREEN}✓ Removed $link${NC}"
    fi
    true
done

# Final check for remaining SENTINEL/BLE.sh files
REMAINING=$(find "${HOME}" -name '*sentinel*' -o -name '*blesh*' 2>/dev/null | grep -vE 'sentinel_backup|bashrc.readme')
if [[ -n "$REMAINING" ]]; then
    echo -e "${YELLOW}Attempting automatic removal of remaining SENTINEL/BLE.sh files...${NC}"
    while IFS= read -r file; do
        if [[ -e "$file" || -L "$file" ]]; then
            echo -e "${YELLOW}Removing $file ...${NC}"
            rm -rf "$file"
            if [[ ! -e "$file" && ! -L "$file" ]]; then
                echo -e "${GREEN}✓ Removed $file${NC}"
            else
                echo -e "${RED}⚠ Failed to remove $file${NC}"
            fi
        fi
    done <<< "$REMAINING"
    # Re-scan to confirm
    REMAINING2=$(find "${HOME}" -name '*sentinel*' -o -name '*blesh*' 2>/dev/null | grep -vE 'sentinel_backup|bashrc.readme')
    if [[ -n "$REMAINING2" ]]; then
        echo -e "${RED}⚠ Warning: Some SENTINEL/BLE.sh files could not be removed automatically:${NC}"
        echo "$REMAINING2"
        echo -e "${YELLOW}Please review and remove these files manually if needed.${NC}"
    else
        echo -e "${GREEN}All SENTINEL and BLE.sh files have been automatically removed.${NC}"
    fi
else
    echo -e "${GREEN}All SENTINEL and BLE.sh files have been removed.${NC}"
fi

# Restore TTY state
stty sane 2>/dev/null || true

echo 