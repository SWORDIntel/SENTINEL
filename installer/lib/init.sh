#!/usr/bin/env bash
# SENTINEL Installer - Initialization

# Strict mode to catch errors
set -euo pipefail

# Define critical variables
export SENTINEL_ROOT_DIR="${SENTINEL_ROOT_DIR:-$HOME}"
export SENTINEL_INSTALL_DIR="${SENTINEL_INSTALL_DIR:-$SENTINEL_ROOT_DIR/.sentinel}"
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
INSTALLER_VERSION="1.0.0"
LOG_DIR="${SENTINEL_INSTALL_DIR}/logs"
STATE_FILE="${SENTINEL_INSTALL_DIR}/install.state"
ROLLBACK_SCRIPT="${SENTINEL_INSTALL_DIR}/.sentinel_rollback.sh"
BLESH_DIR="${SENTINEL_INSTALL_DIR}/.local/share/blesh"
BLESH_LOADER="${SENTINEL_INSTALL_DIR}/blesh_loader.sh"
MODULES_DIR="${SENTINEL_INSTALL_DIR}/bash_modules.d"
VENV_DIR="${SENTINEL_INSTALL_DIR}/venv"

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
# shellcheck source=installer/terminal.sh
source "${PROJECT_ROOT}/installer/terminal.sh"

# Ensure logs directory exists before any logging
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi

# Error handler
trap 'fail "Installer aborted on line $LINENO; see ${LOG_DIR}/install.log"' ERR

# State management functions
mark_done()  { echo "$1" >> "${STATE_FILE}"; }
is_done()    { grep -qxF "$1" "${STATE_FILE:-/dev/null}" 2>/dev/null; }
