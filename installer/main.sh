#!/usr/bin/env bash
# SENTINEL Installer - Main Entry Point

# Strict mode to catch errors
set -euo pipefail

# Define critical variables
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
LOG_DIR="${HOME}/logs"
STATE_FILE="${HOME}/install.state"
ROLLBACK_SCRIPT="${HOME}/.sentinel_rollback.sh"
BLESH_DIR="${HOME}/.local/share/blesh"
BLESH_LOADER="${HOME}/blesh_loader.sh"
MODULES_DIR="${HOME}/bash_modules.d"

# Load configuration
eval "$(${PROJECT_ROOT}/venv/bin/python ${PROJECT_ROOT}/installer/config.py)"

# Source helper scripts
# shellcheck source=installer/helpers.sh
source "${PROJECT_ROOT}/installer/helpers.sh"
# shellcheck source=installer/dependencies.sh
source "${PROJECT_ROOT}/installer/dependencies.sh"
# shellcheck source=installer/directories.sh
source "${PROJECT_ROOT}/installer/directories.sh"
# shellcheck source=installer/python.sh
source "${PROJECT_ROOT}/installer/python.sh"
# shellcheck source=installer/blesh.sh
source "${PROJECT_ROOT}/installer/blesh.sh"
# shellcheck source=installer/bash.sh
source "${PROJECT_ROOT}/installer/bash.sh"


# Ensure logs directory exists before any logging
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi

# Error handler
trap 'fail "Installer aborted on line $LINENO; see ${LOG_DIR}/install.log"' ERR

# State management functions
mark_done()  { echo "$1" >> "${STATE_FILE}"; }
is_done()    { grep -qxF "$1" "${STATE_FILE:-/dev/null}" 2>/dev/null; }

# Unattended install flag
INTERACTIVE=1
for arg in "$@"; do
  case "$arg" in
    --non-interactive)
      INTERACTIVE=0
      ;;
  esac
done

# Create rollback script before any changes
create_rollback_script

# Run dependency checks
check_python_version
PYTHON_CMD=$(find_python) || fail "No suitable Python 3.6+ found"
ok "Using Python: $PYTHON_CMD"
check_dependencies
check_debian_dependencies

# Prompt for custom user environment
prompt_custom_env

# Setup directories
setup_directories
setup_wave_terminal

# Setup Python venv
setup_python_venv

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
run_verification_checks
final_summary
