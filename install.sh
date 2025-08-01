#!/usr/bin/env bash
###############################################################################
# SENTINEL – Framework installer
# -----------------------------------------------
# Hardened edition  •  v2.4.0  •  2025-01-16
# Installs/repairs directly to user's home directory
# and patches the user's Bash startup chain in an idempotent way.
###############################################################################

# Detect if script is being sourced instead of executed
# This prevents the user's shell from being terminated if they incorrectly use 'source install.sh'
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "Error: This script should be executed with 'bash install.sh', not sourced with 'source install.sh'." >&2
    echo "Sourcing would cause your shell to exit if an error occurs." >&2
    return 1
fi

# Set the project root
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Call the main installer script
bash "${PROJECT_ROOT}/installer/main.sh" "$@"
