#!/usr/bin/env bash
# BLE.sh test script with verbosity and option checking

# Enable debugging
set -x

# Define logging
log() {
    echo "[TEST] $1"
}

log "Testing BLE.sh loading..."

# Test direct loading
log "Loading BLE.sh directly..."
if source ~/.local/share/blesh/ble.sh --attach 2>/dev/null; then
    log "BLE.sh loaded successfully with --attach option"
elif source ~/.local/share/blesh/ble.sh 2>/dev/null; then
    log "BLE.sh loaded successfully without options"
else
    log "Failed to load BLE.sh directly"
    exit 1
fi

# List available options
log "Listing available BLE.sh options..."
bleopt | grep complete
bleopt | grep highlight

# Test some basic settings
log "Testing safe options..."
bleopt complete_auto_delay=100
bleopt complete_auto_complete=1

log "All tests completed." 