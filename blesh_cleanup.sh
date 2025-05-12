#!/usr/bin/env bash
# SENTINEL BLE.sh Cleanup Utility
# Version: 1.0
# This script removes all BLE.sh related files and references

# Set strict error handling
set -e
set -o pipefail

# Define colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗      "
echo "██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║      "
echo "███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║      "
echo "╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║      "
echo "███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗ "
echo "╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝ "
echo -e "${NC}"
echo -e "${GREEN}BLE.sh Cleanup Utility${NC}"
echo

# Print status
status() {
    echo -e "${BLUE}[*] $1${NC}"
}

success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

error() {
    echo -e "${RED}[✗] $1${NC}" >&2
}

# Confirm before proceeding
echo -e "${YELLOW}This script will remove all BLE.sh related files and references.${NC}"
echo -e "${YELLOW}This is a destructive operation and cannot be undone.${NC}"
read -p "Do you want to continue? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Create backup directory
timestamp=$(date +%Y%m%d%H%M%S)
backup_dir="${HOME}/.sentinel/backups/blesh_backup_${timestamp}"
status "Creating backup directory at $backup_dir"
mkdir -p "$backup_dir"

# Backup existing BLE.sh files
if [[ -d "${HOME}/.local/share/blesh" ]]; then
    status "Backing up BLE.sh installation"
    mkdir -p "${backup_dir}/local/share"
    cp -r "${HOME}/.local/share/blesh" "${backup_dir}/local/share/"
    success "BLE.sh installation backed up"
fi

if [[ -d "${HOME}/.cache/blesh" ]]; then
    status "Backing up BLE.sh cache"
    mkdir -p "${backup_dir}/cache"
    cp -r "${HOME}/.cache/blesh" "${backup_dir}/cache/"
    success "BLE.sh cache backed up"
fi

# Backup loader scripts
for loader in "${HOME}/.sentinel/blesh_loader.sh" "${HOME}/.sentinel/minimal_blesh.sh" "${HOME}/.sentinel/simple_blesh.sh" "${HOME}/.sentinel/ble.sh"; do
    if [[ -f "$loader" ]]; then
        status "Backing up loader: $loader"
        mkdir -p "${backup_dir}/sentinel"
        cp "$loader" "${backup_dir}/sentinel/"
        success "Loader backed up: $loader"
    fi
done

# Backup bashrc.postcustom
if [[ -f "${HOME}/Documents/GitHub/SENTINEL/bashrc.postcustom" ]]; then
    status "Backing up bashrc.postcustom"
    cp "${HOME}/Documents/GitHub/SENTINEL/bashrc.postcustom" "${backup_dir}/"
    success "bashrc.postcustom backed up"
fi

echo
status "Starting cleanup process..."

# Remove BLE.sh installation
if [[ -d "${HOME}/.local/share/blesh" ]]; then
    status "Removing BLE.sh installation"
    rm -rf "${HOME}/.local/share/blesh"
    success "BLE.sh installation removed"
else
    warning "BLE.sh installation not found at ${HOME}/.local/share/blesh"
fi

# Remove BLE.sh cache
if [[ -d "${HOME}/.cache/blesh" ]]; then
    status "Removing BLE.sh cache"
    rm -rf "${HOME}/.cache/blesh"
    success "BLE.sh cache removed"
else
    warning "BLE.sh cache not found at ${HOME}/.cache/blesh"
fi

# Remove loader scripts
for loader in "${HOME}/.sentinel/blesh_loader.sh" "${HOME}/.sentinel/minimal_blesh.sh" "${HOME}/.sentinel/simple_blesh.sh" "${HOME}/.sentinel/ble.sh"; do
    if [[ -f "$loader" ]]; then
        status "Removing loader: $loader"
        rm -f "$loader"
        success "Loader removed: $loader"
    fi
done

# Find and clean up any temporary BLE.sh directories
status "Searching for temporary BLE.sh directories"
temp_dirs=$(find /tmp -maxdepth 1 -type d -name "blesh*" 2>/dev/null || true)
if [[ -n "$temp_dirs" ]]; then
    echo "$temp_dirs" | while read -r dir; do
        status "Removing temporary directory: $dir"
        rm -rf "$dir"
        success "Temporary directory removed: $dir"
    done
else
    warning "No temporary BLE.sh directories found"
fi

# Clean references in bashrc.postcustom
if [[ -f "${HOME}/Documents/GitHub/SENTINEL/bashrc.postcustom" ]]; then
    status "Cleaning BLE.sh references in bashrc.postcustom"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Filter out BLE.sh related lines
    cat "${HOME}/Documents/GitHub/SENTINEL/bashrc.postcustom" | grep -v "blesh\|BLE\.sh\|ble\.sh\|ble-" > "$temp_file"
    
    # Replace the original file
    mv "$temp_file" "${HOME}/Documents/GitHub/SENTINEL/bashrc.postcustom"
    chmod +x "${HOME}/Documents/GitHub/SENTINEL/bashrc.postcustom"
    
    success "Cleaned BLE.sh references in bashrc.postcustom"
else
    warning "bashrc.postcustom not found at ${HOME}/Documents/GitHub/SENTINEL/bashrc.postcustom"
fi

# Clean references in .bashrc
if [[ -f "${HOME}/.bashrc" ]]; then
    status "Cleaning BLE.sh references in .bashrc"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Filter out BLE.sh related lines
    cat "${HOME}/.bashrc" | grep -v "blesh\|BLE\.sh\|ble\.sh\|ble-" > "$temp_file"
    
    # Replace the original file
    mv "$temp_file" "${HOME}/.bashrc"
    
    success "Cleaned BLE.sh references in .bashrc"
else
    warning ".bashrc not found at ${HOME}/.bashrc"
fi

# Check for bash_completion.sentinel integrity
if [[ -f "${HOME}/.bash_completion.sentinel" ]]; then
    status "Checking bash_completion.sentinel file"
    
    if grep -q "blesh\|BLE\.sh\|ble\.sh\|ble-" "${HOME}/.bash_completion.sentinel"; then
        warning "BLE.sh references found in .bash_completion.sentinel"
        warning "Please verify this file manually after the cleanup process"
    else
        success "bash_completion.sentinel file appears clean"
    fi
else
    warning "bash_completion.sentinel not found at ${HOME}/.bash_completion.sentinel"
fi

echo
echo -e "${GREEN}BLE.sh cleanup process completed!${NC}"
echo -e "${YELLOW}Backup files saved to: ${backup_dir}${NC}"
echo -e "${YELLOW}Please restart your terminal session to apply all changes.${NC}"
echo 