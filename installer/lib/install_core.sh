#!/usr/bin/env bash
# SENTINEL Installer - Core Installation

# Prompt for custom user environment
prompt_custom_env

# Setup directories
setup_directories
setup_wave_terminal

# Install BLE.sh
if ! is_done "BLESH_INSTALLED"; then
  if [[ -f "${BLESH_DIR}/ble.sh" ]]; then
    ok "BLE.sh already present – skipping clone"
  else
    install_blesh
  fi
  mark_done "BLESH_INSTALLED"
fi

create_blesh_loader

# Setup bash
ensure_local_bin_in_path
if ! is_done "BASHRC_PATCHED"; then
  patch_bashrc "${HOME}/.bashrc"
  mark_done "BASHRC_PATCHED"
fi
copy_postcustom_bootstrap
copy_bash_modules
copy_shell_support_files
enable_fzf_module
secure_permissions
