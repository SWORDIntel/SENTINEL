#!/usr/bin/env bash
# SENTINEL Installer - Main Entry Point

# Source the initialization script
source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"

# Source the pre-flight checks script
source "${PROJECT_ROOT}/installer/lib/preflight.sh"

# Source the core installation script
source "${PROJECT_ROOT}/installer/lib/install_core.sh"

# Source the finalization script
source "${PROJECT_ROOT}/installer/lib/finalize.sh"
