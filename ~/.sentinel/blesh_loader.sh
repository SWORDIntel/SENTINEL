#!/usr/bin/env bash
# SENTINEL ble.sh integration loader
# This script loads ble.sh with proper error handling

# Clean up any stale cache files that might be causing issues
cleanup_stale_cache() {
  if [[ -d ~/.cache/blesh ]]; then
    # Try to fix permissions
    chmod -R 755 ~/.cache/blesh 2>/dev/null || true
    
    # Attempt to clean any .part files that might be causing issues
    find ~/.cache/blesh -name "*.part" -type f -delete 2>/dev/null || true
    
    # Clean decode.readline files that are causing errors
    find ~/.cache/blesh -name "decode.readline.*.txt*" -type f -delete 2>/dev/null || true
  fi
}

# Run cleanup before loading
cleanup_stale_cache

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    source ~/.local/share/blesh/ble.sh 2>/dev/null
    if ! type -t ble-bind &>/dev/null; then
        echo "Warning: ble.sh did not load properly. Trying alternative loading method..."
        # Try alternative loading with a different approach
        source <(cat ~/.local/share/blesh/ble.sh) 2>/dev/null
        
        if ! type -t ble-bind &>/dev/null; then
            echo "Warning: ble.sh could not be loaded. Using basic autocompletion instead."
            # Load bash standard completion as fallback
            [[ -f /etc/bash_completion ]] && source /etc/bash_completion
        fi
    else
        # Configure predictive suggestion settings
        bleopt complete_auto_delay=100 2>/dev/null || true
        bleopt complete_auto_complete=1 2>/dev/null || true
        bleopt highlight_auto_completion='fg=242' 2>/dev/null || true
        
        # Configure key bindings
        ble-bind -m auto_complete -f right 'auto_complete/accept-line' 2>/dev/null || true
    fi
fi 