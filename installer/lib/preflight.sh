#!/usr/bin/env bash
# SENTINEL Installer - Pre-flight Checks

# Pre-flight checks
check_python_version
PYTHON_CMD=$(find_python) || fail "No suitable Python 3.6+ found"
export PYTHON_CMD
setup_python_venv

# Load configuration
{
    umask 077
    _sentinel_config_exports="$(mktemp "${HOME}/.sentinel_config_exports.XXXXXX")"
    "${HOME}/venv/bin/python" "${PROJECT_ROOT}/installer/config.py" --output "${_sentinel_config_exports}" || fail "Failed to parse configuration"
    # shellcheck disable=SC1090
    source "${_sentinel_config_exports}"
    rm -f "${_sentinel_config_exports}" 2>/dev/null || true
}

# Detect headless environment and auto-configure
if detect_headless_environment; then
    export SENTINEL_HEADLESS=1
    export SENTINEL_SKIP_BLESH=1
    export SENTINEL_SKIP_WAVE=1
    step "Headless VPS environment detected"
    log "Auto-configuring for server environment (no GUI)"
    log "BLE.sh and Wave Terminal configuration will be skipped"
else
    export SENTINEL_HEADLESS=0
    log "GUI environment detected - enabling full features"
fi

# Unattended install flag
INTERACTIVE=1
for arg in "$@"; do
  case "$arg" in
    --non-interactive)
      INTERACTIVE=0
      ;;
    --headless)
      SENTINEL_HEADLESS=1
      SENTINEL_SKIP_BLESH=1
      SENTINEL_SKIP_WAVE=1
      ;;
  esac
done

# Auto-enable non-interactive mode in headless environments
if [[ "${SENTINEL_HEADLESS}" == "1" ]] && [[ "${INTERACTIVE}" == "1" ]]; then
    log "Headless environment detected - enabling non-interactive mode"
    INTERACTIVE=0
fi

# Create rollback script before any changes
create_rollback_script

# Run dependency checks
check_dependencies
check_platform_dependencies
