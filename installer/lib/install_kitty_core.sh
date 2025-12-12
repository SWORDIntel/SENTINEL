#!/usr/bin/env bash
# SENTINEL Installer - Core Installation for Kitty Primary CLI Pathway

# Source kitty-specific functions
source "${PROJECT_ROOT}/installer/kitty.sh"

# Prompt for custom user environment
prompt_custom_env

# Setup directories
setup_directories

# Setup Kitty as primary CLI (required for this pathway)
setup_kitty_primary_cli

# Setup bash for kitty pathway
if ! is_done "BASHRC_PATCHED_KITTY"; then
  patch_bashrc_for_kitty "${HOME}/.bashrc"
  mark_done "BASHRC_PATCHED_KITTY"
fi

# Copy kitty.rc bootstrap (already done in setup_kitty_primary_cli, but ensure it exists)
if [[ ! -f "${HOME}/kitty.rc" ]]; then
  _kitty_create_rc_file
fi

ensure_local_bin_in_path
copy_bash_modules
copy_shell_support_files
enable_fzf_module
secure_permissions

# Note: Skip BLE.sh and Wave Terminal for kitty primary pathway
# Kitty provides its own shell integration
log "Kitty primary CLI pathway: BLE.sh and Wave Terminal integration skipped (not needed)"
