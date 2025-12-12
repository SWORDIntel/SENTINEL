#!/usr/bin/env bash
# SENTINEL Installer - Kitty Primary CLI Pathway
# This installer configures SENTINEL to use kitty as the primary terminal CLI

# Source the initialization script
source "$(dirname "${BASH_SOURCE[0]}")/installer/lib/init.sh"

# Handle --dry-run flag
DRY_RUN=0
if [[ " $@ " =~ " --dry-run " ]]; then
    DRY_RUN=1
fi

# Set kitty pathway flag
export SENTINEL_KITTY_PRIMARY_CLI=1
export SENTINEL_SKIP_BLESH=1
export SENTINEL_SKIP_WAVE=1

# Source the pre-flight checks script
source "${PROJECT_ROOT}/installer/lib/preflight.sh"

# Source the kitty core installation script
if [ $DRY_RUN -eq 0 ]; then
    source "${PROJECT_ROOT}/installer/lib/install_kitty_core.sh"
fi

# Source the finalization script
if [ $DRY_RUN -eq 0 ]; then
    source "${PROJECT_ROOT}/installer/lib/finalize.sh"
fi
