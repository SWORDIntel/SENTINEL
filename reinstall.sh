#!/usr/bin/env bash
###############################################################################
# SENTINEL – Framework reinstaller
# -----------------------------------------------
# Hardened edition  •  v2.3.0  •  2025-05-16
# Fully reinstalls SENTINEL after cleaning any previous installation
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

# Define paths
STATE_FILE="${HOME}/install.state"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Get confirmation
step "This will completely remove and reinstall SENTINEL"
warn "This will remove your current SENTINEL installation and settings."
read -p "Are you sure you want to reinstall SENTINEL? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    fail "Reinstallation cancelled by user."
fi

# Create backup of current setup
step "Creating backup of current setup"
BACKUP_DIR="${HOME}/sentinel_backup_$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Check for old sentinel home directory (legacy)
if [[ -d "${HOME}/.sentinel" ]]; then
    cp -r "${HOME}/.sentinel" "${BACKUP_DIR}/"
    ok "Legacy SENTINEL home directory backed up to ${BACKUP_DIR}"
fi

# Back up key SENTINEL files from HOME
for file in blesh_loader.sh bashrc.postcustom; do
    if [[ -f "${HOME}/${file}" ]]; then
        cp "${HOME}/${file}" "${BACKUP_DIR}/"
        ok "${file} backed up to ${BACKUP_DIR}"
    fi
done

for dir in bash_aliases.d bash_completion.d bash_functions.d contrib logs autocomplete bash_modules.d venv; do
    if [[ -d "${HOME}/${dir}" ]]; then
        cp -r "${HOME}/${dir}" "${BACKUP_DIR}/"
        ok "${dir} backed up to ${BACKUP_DIR}"
    fi
done

for file in .bashrc .bash_modules .bash_aliases .bash_completion .bash_functions; do
    if [[ -f "${HOME}/${file}" ]]; then
        cp "${HOME}/${file}" "${BACKUP_DIR}/"
        ok "${file} backed up to ${BACKUP_DIR}"
    fi
done

# Verify installation script exists
if [[ ! -f "${SCRIPT_DIR}/install.sh" ]]; then
    fail "Install script not found: ${SCRIPT_DIR}/install.sh"
fi

# Remove existing installation
step "Removing existing SENTINEL installation files"

# Remove old sentinel directory if it exists (legacy)
if [[ -d "${HOME}/.sentinel" ]]; then
    rm -rf "${HOME}/.sentinel"
    ok "Removed legacy ${HOME}/.sentinel directory"
fi

# Remove specific SENTINEL files from HOME
for file in blesh_loader.sh bashrc.postcustom install.state; do
    if [[ -f "${HOME}/${file}" ]]; then
        rm -f "${HOME}/${file}"
        ok "Removed ${HOME}/${file}"
    fi
done

# Remove SENTINEL directories
for dir in autocomplete bash_modules.d logs; do
    if [[ -d "${HOME}/${dir}" ]]; then
        rm -rf "${HOME}/${dir}"
        ok "Removed ${HOME}/${dir}"
    fi
done

# Remove venv directory if it exists
if [[ -d "${HOME}/venv" ]]; then
    read -p "Remove Python virtual environment at ${HOME}/venv? [y/N]: " confirm_venv
    if [[ "$confirm_venv" =~ ^[Yy]$ ]]; then
        rm -rf "${HOME}/venv"
        ok "Removed Python virtual environment"
    else
        warn "Keeping Python virtual environment at ${HOME}/venv"
    fi
fi

# Remove modular directories
for dir in bash_aliases.d bash_completion.d bash_functions.d contrib; do
    if [[ -d "${HOME}/${dir}" ]]; then
        read -p "Remove ${HOME}/${dir}? [y/N]: " confirm_dir
        if [[ "$confirm_dir" =~ ^[Yy]$ ]]; then
            rm -rf "${HOME}/${dir}"
            ok "Removed ${HOME}/${dir}"
        else
            warn "Keeping ${HOME}/${dir} (may contain old files)"
        fi
    fi
done

# Clean up BLE.sh installation
if [[ -d "${HOME}/.local/share/blesh" ]]; then
    rm -rf "${HOME}/.local/share/blesh"
    ok "Removed BLE.sh installation"
fi

if [[ -d "${HOME}/.cache/blesh" ]]; then
    rm -rf "${HOME}/.cache/blesh"
    ok "Removed BLE.sh cache"
fi

# Run the installer
step "Running SENTINEL installer"
bash "${SCRIPT_DIR}/install.sh"

# Verify installation
step "Verifying installation"
if [[ -f "${HOME}/bashrc.postcustom" ]]; then
    ok "SENTINEL installation verified"
else
    fail "Installation verification failed"
fi

# Final message
echo
ok "SENTINEL has been successfully reinstalled!"
echo "• Open a new terminal OR run:  source '${HOME}/bashrc.postcustom'"
echo "• Verify with:                @autocomplete status"
echo "• A backup of your previous installation is available at: ${BACKUP_DIR}" 