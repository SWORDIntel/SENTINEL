#!/usr/bin/env bash
# SENTINEL Security Enhanced Logout Script
# Securely cleans up temporary files and bash history on logout

# Only run in interactive shells
case $- in
  *i*) ;;
    *) return;;
esac

echo "SENTINEL: Starting secure cleanup..."

# Function for secure deletion using existing _secure_shred
_secure_logout_deletion() {
    local file_path="$1"
    local desc="$2"

    if [[ -e "$file_path" ]]; then
        echo "SENTINEL: Securely erasing $desc..."
        
        # Check if our secure shredding function is available
        if type _secure_shred &>/dev/null; then
            # Use our custom secure deletion function
            _secure_shred "$file_path" "-f" >/dev/null 2>&1
        elif command -v shred &>/dev/null; then
            # Use shred if available
            shred -fuz "$file_path" >/dev/null 2>&1
        else
            # Fallback method
            local filesize=$(stat -c %s "$file_path" 2>/dev/null || stat -f %z "$file_path" 2>/dev/null)
            local blocksize=1024
            
            # Overwrite with random data
            dd if=/dev/urandom of="$file_path" bs=$blocksize count=$((filesize/blocksize+1)) conv=notrunc >/dev/null 2>&1
            
            # Remove the file
            rm -f "$file_path" >/dev/null 2>&1
        fi
    fi
}

# Function to securely clean directory
_secure_clean_dir() {
    local dir_path="$1"
    local desc="$2"
    local pattern="${3:-.*}"  # Default pattern matches all files
    
    if [[ -d "$dir_path" ]]; then
        echo "SENTINEL: Cleaning $desc..."
        
        # Find files matching pattern in directory
        find "$dir_path" -type f -name "$pattern" -print0 2>/dev/null | 
        while IFS= read -r -d '' file; do
            _secure_logout_deletion "$file" "$(basename "$file") in $desc"
        done
    fi
}

# Clear Bash history
if [[ "${SENTINEL_SECURE_BASH_HISTORY:-1}" == "1" ]]; then
    echo "SENTINEL: Clearing bash history..."
    history -c
    _secure_logout_deletion ~/.bash_history "bash history"
fi

# Clear SSH known hosts if configured
if [[ "${SENTINEL_SECURE_SSH_KNOWN_HOSTS:-0}" == "1" ]]; then
    _secure_logout_deletion ~/.ssh/known_hosts "SSH known hosts"
fi

# Clean temporary directories
# Clean /tmp files created by current user
_secure_clean_dir "/tmp" "temporary files owned by current user" "*"

# Clean ~/.cache directory
if [[ "${SENTINEL_SECURE_CLEAN_CACHE:-1}" == "1" ]]; then
    _secure_clean_dir "$HOME/.cache" "cache directory"
fi

# Clean browser cache if specified
if [[ "${SENTINEL_SECURE_BROWSER_CACHE:-0}" == "1" ]]; then
    # Firefox
    if [[ -d "$HOME/.mozilla/firefox" ]]; then
        _secure_clean_dir "$HOME/.mozilla/firefox" "Firefox cache" "*.sqlite"
        _secure_clean_dir "$HOME/.mozilla/firefox" "Firefox cookies" "cookies.sqlite*"
    fi
    
    # Chrome/Chromium
    if [[ -d "$HOME/.config/google-chrome" ]]; then
        _secure_clean_dir "$HOME/.config/google-chrome/Default" "Chrome cache" "Cookies*"
    fi
    if [[ -d "$HOME/.config/chromium" ]]; then
        _secure_clean_dir "$HOME/.config/chromium/Default" "Chromium cache" "Cookies*"
    fi
fi

# Clean recently-used files list
if [[ "${SENTINEL_SECURE_RECENT:-1}" == "1" ]]; then
    _secure_logout_deletion "$HOME/.local/share/recently-used.xbel" "recently used files list"
    _secure_logout_deletion "$HOME/.recently-used" "recently used files list (old format)"
fi

# Clean vim undo history if enabled
if [[ "${SENTINEL_SECURE_VIM_UNDO:-1}" == "1" ]]; then
    if [[ -d "$HOME/.vim/undo" ]]; then
        _secure_clean_dir "$HOME/.vim/undo" "Vim undo history"
    fi
fi

# Clean any workspace-specific temp files
if [[ -n "${SENTINEL_WORKSPACE_TEMP}" && -d "${SENTINEL_WORKSPACE_TEMP}" ]]; then
    _secure_clean_dir "${SENTINEL_WORKSPACE_TEMP}" "workspace temporary files"
fi

# Special handling for secure data directories (if defined)
if [[ -n "${SENTINEL_SECURE_DIRS}" ]]; then
    IFS=':' read -ra DIRS <<< "${SENTINEL_SECURE_DIRS}"
    for dir in "${DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            _secure_clean_dir "$dir" "secure data in $dir"
        fi
    done
fi

# Clear clipboard (if xsel is available)
if [[ "${SENTINEL_SECURE_CLIPBOARD:-1}" == "1" ]]; then
    if command -v xsel &>/dev/null; then
        echo "SENTINEL: Clearing clipboard..."
        echo -n | xsel --clipboard --input
    elif command -v xclip &>/dev/null; then
        echo "SENTINEL: Clearing clipboard..."
        echo -n | xclip -selection clipboard
    fi
fi

echo "SENTINEL: Secure cleanup complete."

# Clear the screen for added privacy
if [[ "${SENTINEL_SECURE_CLEAR_SCREEN:-1}" == "1" ]]; then
    clear
    echo "Terminal session ended and secured."
fi