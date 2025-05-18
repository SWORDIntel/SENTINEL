#!/usr/bin/env bash
###############################################################################
# SENTINEL – Framework uninstaller
# -----------------------------------------------
# Hardened edition  •  v2.3.0  •  2025-05-16
# Completely removes the SENTINEL framework and restores backup files
###############################################################################

set -euo pipefail

# Colour helpers
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_blue=$'\033[1;34m'; c_reset=$'\033[0m'

# Logging functions
log() { printf '[%(%F %T)T] %b\n' -1 "$*"; }
step() { log "${c_blue}==>${c_reset} $*"; }
ok()   { log "${c_green}✔${c_reset}  $*"; }
warn() { log "${c_yellow}⚠${c_reset}  $*"; }
fail() { log "${c_red}✖${c_reset}  $*"; exit 1; }

# Define paths for SENTINEL components
SENTINEL_DIRS=(
    "${HOME}/bash_aliases.d"
    "${HOME}/bash_completion.d"
    "${HOME}/bash_functions.d"
    "${HOME}/contrib"
    "${HOME}/logs"
    "${HOME}/autocomplete"
    "${HOME}/bash_modules.d"
    "${HOME}/venv"
)
SENTINEL_FILES=(
    "${HOME}/.bash_modules"
    "${HOME}/blesh_loader.sh"
    "${HOME}/bashrc.postcustom"
    "${HOME}/install.state"
)

# Check for legacy installation
LEGACY_SENTINEL_HOME="${HOME}/.sentinel"

# Get confirmation
step "This will completely remove SENTINEL from your system"
warn "All SENTINEL files, settings, and customizations will be permanently deleted."
read -p "Are you sure you want to uninstall SENTINEL? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    fail "Uninstallation cancelled by user."
fi

# Create backup
step "Creating backup of current SENTINEL installation"
BACKUP_DIR="${HOME}/sentinel_backup_$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup legacy directory if it exists
if [[ -d "${LEGACY_SENTINEL_HOME}" ]]; then
    cp -r "${LEGACY_SENTINEL_HOME}" "${BACKUP_DIR}/"
    ok "Legacy SENTINEL home directory backed up to ${BACKUP_DIR}"
fi

# Backup current SENTINEL files
for file in "${SENTINEL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        file_name=$(basename "$file")
        cp "$file" "${BACKUP_DIR}/"
        ok "File $file_name backed up to ${BACKUP_DIR}"
    fi
done

# Backup current SENTINEL directories
for dir in "${SENTINEL_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        dir_name=$(basename "$dir")
        cp -r "$dir" "${BACKUP_DIR}/"
        ok "Directory $dir_name backed up to ${BACKUP_DIR}"
    fi
done

# Also backup .bashrc
if [[ -f "${HOME}/.bashrc" ]]; then
    cp "${HOME}/.bashrc" "${BACKUP_DIR}/"
    ok "File .bashrc backed up to ${BACKUP_DIR}"
fi

# Restore original .bashrc if a sentinel backup exists
if [[ -f "${HOME}/.bashrc.sentinel.bak" ]]; then
    step "Restoring original .bashrc from backup"
    cp "${HOME}/.bashrc.sentinel.bak" "${HOME}/.bashrc"
    ok "Original .bashrc restored"
else
    step "Removing SENTINEL references from .bashrc"
    if [[ -f "${HOME}/.bashrc" ]]; then
        # Remove SENTINEL integration lines from .bashrc
        sed -i '/# SENTINEL Framework Integration/,+3d' "${HOME}/.bashrc" || warn "Could not remove SENTINEL references from .bashrc"
        ok "SENTINEL references removed from .bashrc"
    fi
fi

# Remove legacy SENTINEL home directory if it exists
if [[ -d "${LEGACY_SENTINEL_HOME}" ]]; then
    step "Removing legacy SENTINEL home directory"
    rm -rf "${LEGACY_SENTINEL_HOME}"
    ok "Removed ${LEGACY_SENTINEL_HOME}"
fi

# Remove SENTINEL files
step "Removing SENTINEL files"
for file in "${SENTINEL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        rm -f "$file"
        ok "Removed $file"
    fi
done

# Remove SENTINEL directories
step "Removing SENTINEL directories"
for dir in "${SENTINEL_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        read -p "Remove $dir? [y/N]: " confirm_dir
        if [[ "$confirm_dir" =~ ^[Yy]$ ]]; then
            rm -rf "$dir"
            ok "Removed $dir"
        else
            warn "Keeping $dir (may contain custom files)"
        fi
    fi
done

# Remove BLE.sh
step "Removing BLE.sh"
if [[ -d "${HOME}/.local/share/blesh" ]]; then
    rm -rf "${HOME}/.local/share/blesh"
    ok "Removed BLE.sh installation"
fi

if [[ -d "${HOME}/.cache/blesh" ]]; then
    rm -rf "${HOME}/.cache/blesh"
    ok "Removed BLE.sh cache"
fi

if [[ -f "${HOME}/.blerc" ]]; then
    rm -f "${HOME}/.blerc"
    ok "Removed .blerc configuration file"
fi

# Final message
echo
ok "SENTINEL has been successfully uninstalled!"
echo "• A backup of your SENTINEL installation is available at: ${BACKUP_DIR}"
echo "• You may need to restart your shell session for changes to take effect."
echo "• If you want to reinstall SENTINEL later, run: bash /path/to/SENTINEL/install.sh" 