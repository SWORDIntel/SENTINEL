#!/usr/bin/env bash
# SENTINEL Installer - Main Entry Point

# Source the initialization script
source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"

# Handle --dry-run flag
DRY_RUN=0
if [[ " $@ " =~ " --dry-run " ]]; then
    DRY_RUN=1
fi

# Source the pre-flight checks script
source "${PROJECT_ROOT}/installer/lib/preflight.sh"

# Source the core installation script
if [ $DRY_RUN -eq 0 ]; then
    source "${PROJECT_ROOT}/installer/lib/install_core.sh"
fi

# Source the finalization script
if [ $DRY_RUN -eq 0 ]; then
    source "${PROJECT_ROOT}/installer/lib/finalize.sh"
fi
