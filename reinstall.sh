#!/usr/bin/env bash
# SENTINEL Reinstallation Script
# Robust, non-interactive, and safe reinstallation of SENTINEL
# Backs up config, uninstalls, reinstalls, and restores user customizations
# Logs all actions and errors for auditability

set -euo pipefail

# --- Logging Setup ---
LOG_DIR="$HOME/.sentinel/logs"
LOG_FILE="$LOG_DIR/reinstall-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

# --- TTY State Protection ---
trap 'stty sane 2>/dev/null || true' EXIT

# --- Banner ---
echo "=================================================="
echo " SENTINEL REINSTALLATION SCRIPT"
echo " Date: $(date)"
echo " Log: $LOG_FILE"
echo "=================================================="

# --- Backup Current Config and Modules ---
BACKUP_DIR="$HOME/.sentinel_reinstall_backup_$(date +%Y%m%d%H%M%S)"
echo "[INFO] Backing up current SENTINEL config and modules to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
if [[ -d "$HOME/.sentinel" ]]; then
    cp -a "$HOME/.sentinel" "$BACKUP_DIR/" || echo "[WARN] Could not backup .sentinel directory"
fi
if [[ -d "$HOME/.bash_modules.d" ]]; then
    cp -a "$HOME/.bash_modules.d" "$BACKUP_DIR/" || echo "[WARN] Could not backup .bash_modules.d directory"
fi
if [[ -f "$HOME/.bashrc" ]]; then
    cp "$HOME/.bashrc" "$BACKUP_DIR/bashrc.bak" || echo "[WARN] Could not backup .bashrc"
fi
if [[ -f "$HOME/.bash_aliases" ]]; then
    cp "$HOME/.bash_aliases" "$BACKUP_DIR/bash_aliases.bak" || echo "[WARN] Could not backup .bash_aliases"
fi
if [[ -f "$HOME/.bash_functions" ]]; then
    cp "$HOME/.bash_functions" "$BACKUP_DIR/bash_functions.bak" || echo "[WARN] Could not backup .bash_functions"
fi
if [[ -f "$HOME/.bash_completion" ]]; then
    cp "$HOME/.bash_completion" "$BACKUP_DIR/bash_completion.bak" || echo "[WARN] Could not backup .bash_completion"
fi

# --- Non-interactive Uninstall ---
echo "[INFO] Running SENTINEL uninstall (auto-confirm)"
if [[ -f ./uninstall.sh ]]; then
    yes | bash ./uninstall.sh || echo "[WARN] Uninstall script exited with non-zero status"
else
    echo "[ERROR] uninstall.sh not found! Aborting."
    exit 1
fi

# --- Non-interactive Install ---
echo "[INFO] Running SENTINEL install"
if [[ -f ./install.sh ]]; then
    bash ./install.sh || { echo "[ERROR] Install script failed!"; exit 1; }
else
    echo "[ERROR] install.sh not found! Aborting."
    exit 1
fi

# --- Restore User Customizations (if any) ---
echo "[INFO] Attempting to restore user customizations from backup"
for file in bashrc.bak bash_aliases.bak bash_functions.bak bash_completion.bak; do
    if [[ -f "$BACKUP_DIR/$file" ]]; then
        # Only restore lines not related to SENTINEL integration
        orig_file="$HOME/.${file%.bak}"
        grep -v 'SENTINEL Integration' "$BACKUP_DIR/$file" > "$orig_file.user"
        cat "$orig_file.user" >> "$orig_file"
        rm "$orig_file.user"
        echo "[INFO] Restored user customizations to $orig_file"
    fi
    # Do not overwrite new SENTINEL integration
    # User should manually review if needed
    # Security: No automatic overwrite of critical config
    # Reference: CWE-494, CWE-284
    # https://cwe.mitre.org/data/definitions/494.html
    # https://cwe.mitre.org/data/definitions/284.html
done

# --- Cleanup ---
echo "[INFO] Cleaning up temporary files"
# (No temp files to clean in this script)

# --- Final Status ---
echo "[SUCCESS] SENTINEL reinstallation complete."
echo "[INFO] Log file: $LOG_FILE"
echo "[INFO] Backup directory: $BACKUP_DIR"
echo "[INFO] Please restart your terminal or run: source ~/.bashrc"
echo "=================================================="

exit 0 