#!/usr/bin/env bash
# SENTINEL Installer - Pre-flight Checks

# Pre-flight checks
check_python_version
PYTHON_CMD=$(find_python) || fail "No suitable Python 3.6+ found"
setup_python_venv

# Load configuration
eval "$(${VENV_DIR}/bin/python ${PROJECT_ROOT}/installer/config.py)"

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
check_dependencies
check_debian_dependencies
