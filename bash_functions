#!/usr/bin/env bash
# SENTINEL Core Functions
# Enhanced shell functions for improved productivity and security
# Last Update: 2023-08-14

# Centralized configuration caching
# Usage: load_cached_config <config_file> [options]
# Loads a config file, using a cache if available and up-to-date
# Options:
#   --debug         - Show debug messages
#   --force-refresh - Force refresh of cache
#   --verify        - Verify cache integrity
#   --selective="VAR1 VAR2" - Only cache specified variables
load_cached_config() {
    local config_file="$1"
    shift
    local cache_file="${config_file}.cache"
    local debug=0
    local force_refresh=0
    local verify=0
    local selective_vars=""
    local hash_file="${cache_file}.hash"
    
    # Process options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --debug)
                debug=1
                ;;
            --force-refresh)
                force_refresh=1
                ;;
            --verify)
                verify=1
                ;;
            --selective=*)
                selective_vars="${1#*=}"
                ;;
            *)
                echo "[load_cached_config] Unknown option: $1" >&2
                ;;
        esac
        shift
    done

    if [[ ! -f "$config_file" ]]; then
        echo "[load_cached_config] Config file not found: $config_file" >&2
        return 1
    fi

    # Force refresh or verify hash if requested
    if [[ $force_refresh -eq 1 || $verify -eq 1 ]]; then
        if [[ -f "$hash_file" && -f "$cache_file" && $verify -eq 1 ]]; then
            local stored_hash=$(cat "$hash_file")
            local current_hash=$(md5sum "$config_file" | cut -d' ' -f1)
            if [[ "$stored_hash" != "$current_hash" ]]; then
                [[ $debug -eq 1 ]] && echo "[load_cached_config] Hash mismatch, forcing refresh" >&2
                force_refresh=1
            fi
        else
            [[ $debug -eq 1 ]] && echo "[load_cached_config] No hash file, forcing refresh" >&2
            force_refresh=1
        fi
    fi

    # Use cache if it exists, is newer than config file, and no force refresh
    if [[ -f "$cache_file" && "$cache_file" -nt "$config_file" && $force_refresh -eq 0 ]]; then
        [[ $debug -eq 1 ]] && echo "[load_cached_config] Using cached config: $cache_file" >&2
        source "$cache_file"
        return 0
    fi

    # Source the config file
    [[ $debug -eq 1 ]] && echo "[load_cached_config] Sourcing config: $config_file" >&2
    source "$config_file"
    
    # Capture pre-existing variables to avoid caching them
    local tmp_env_before=$(mktemp)
    local tmp_env_after=$(mktemp)
    local tmp_env_diff=$(mktemp)
    
    # Create cache file with header
    echo "# SENTINEL Configuration Cache" > "$cache_file"
    echo "# Original: $config_file" >> "$cache_file"
    echo "# Generated: $(date)" >> "$cache_file"
    echo "" >> "$cache_file"
    
    if [[ -n "$selective_vars" ]]; then
        # Only cache specified variables
        [[ $debug -eq 1 ]] && echo "[load_cached_config] Selective caching: $selective_vars" >&2
        for var in $selective_vars; do
            if [[ -v "$var" ]]; then
                declare -p "$var" >> "$cache_file" 2>/dev/null
            fi
        done
    else
        # Get environment before and after to detect new variables
        set -o posix
        set > "$tmp_env_before"
        source "$config_file"
        set > "$tmp_env_after"
        set +o posix
        
        # Get the difference (new or changed variables)
        grep -vFxf "$tmp_env_before" "$tmp_env_after" > "$tmp_env_diff"
        
        # Save the changed variables to cache
        while IFS= read -r line; do
            # Extract variable name and check if it's a variable declaration
            local var_name=$(echo "$line" | cut -d= -f1)
            if [[ -n "$var_name" && "$var_name" != "BASH_LINENO" && "$var_name" != "BASH_SOURCE" && 
                  "$var_name" != "FUNCNAME" && "$var_name" != "BASH_COMMAND" && 
                  "$var_name" != "BASH_EXECUTION_STRING" && "$var_name" != "BASH_REMATCH" && 
                  ! "$var_name" =~ ^[0-9]+$ ]]; then
                # Declaration with declare -p to preserve variable type
                declare -p "$var_name" >> "$cache_file" 2>/dev/null
            fi
        done < "$tmp_env_diff"
    fi
    
    # Clean up temp files
    rm -f "$tmp_env_before" "$tmp_env_after" "$tmp_env_diff"
    
    # Create hash for future verification
    md5sum "$config_file" | cut -d' ' -f1 > "$hash_file"
    
    # Secure the files
    chmod 600 "$cache_file" "$hash_file"
    
    [[ $debug -eq 1 ]] && echo "[load_cached_config] Cache updated: $cache_file" >&2
    return 0
}

# Module configuration caching
# Specialized version of load_cached_config for modules
# Usage: load_module_config <module_name>
load_module_config() {
    local module_name="$1"
    local module_dir="${SENTINEL_MODULES_PATH:-$HOME/.bash_modules.d}"
    local module_file=""
    local debug=0
    [[ "$2" == "--debug" ]] && debug=1
    
    # Find the module file
    if [[ -f "${module_dir}/${module_name}.sh" ]]; then
        module_file="${module_dir}/${module_name}.sh"
    elif [[ -f "${module_dir}/${module_name}.module" ]]; then
        module_file="${module_dir}/${module_name}.module"
    else
        # Try to find in subdirs
        local found_file=$(find "${module_dir}" -name "${module_name}.sh" -o -name "${module_name}.module" | head -n1)
        if [[ -n "$found_file" ]]; then
            module_file="$found_file"
        else
            echo "[load_module_config] Module not found: $module_name" >&2
            return 1
        fi
    fi
    
    # Create tracker directory if it doesn't exist
    local cache_dir="${SENTINEL_CACHE_DIR:-$HOME/.sentinel/cache}/modules"
    mkdir -p "$cache_dir"
    
    # Extract module dependencies before loading
    if grep -q "SENTINEL_MODULE_DEPENDENCIES=" "$module_file"; then
        local deps=$(grep "SENTINEL_MODULE_DEPENDENCIES=" "$module_file" | head -n1 | sed 's/.*="\(.*\)".*/\1/')
        
        # Store deps in dependency tracking file
        echo "$deps" > "${cache_dir}/${module_name}.deps"
        [[ $debug -eq 1 ]] && echo "[load_module_config] Cached dependencies for $module_name: $deps" >&2
    else
        # No dependencies
        echo "" > "${cache_dir}/${module_name}.deps"
    fi
    
    # Now load the module with config caching
    load_cached_config "$module_file" ${debug:+--debug}
    return $?
}

# Get cached module dependencies
# Usage: get_module_dependencies <module_name>
get_module_dependencies() {
    local module_name="$1"
    local cache_dir="${SENTINEL_CACHE_DIR:-$HOME/.sentinel/cache}/modules"
    local deps_file="${cache_dir}/${module_name}.deps"
    
    if [[ -f "$deps_file" ]]; then
        cat "$deps_file"
    else
        # Try to extract without loading the module
        local module_dir="${SENTINEL_MODULES_PATH:-$HOME/.bash_modules.d}"
        local module_file=""
        
        # Find the module file
        if [[ -f "${module_dir}/${module_name}.sh" ]]; then
            module_file="${module_dir}/${module_name}.sh"
        elif [[ -f "${module_dir}/${module_name}.module" ]]; then
            module_file="${module_dir}/${module_name}.module"
        else
            # Try to find in subdirs
            local found_file=$(find "${module_dir}" -name "${module_name}.sh" -o -name "${module_name}.module" | head -n1)
            if [[ -n "$found_file" ]]; then
                module_file="$found_file"
            else
                return 1
            fi
        fi
        
        # Extract dependencies
        if grep -q "SENTINEL_MODULE_DEPENDENCIES=" "$module_file"; then
            grep "SENTINEL_MODULE_DEPENDENCIES=" "$module_file" | head -n1 | sed 's/.*="\(.*\)".*/\1/'
        fi
    fi
}

# Visual spinner for progress indication
spin() {
    echo -ne "${RED}-"
    echo -ne "${WHITE}\b|"
    echo -ne "${BLUE}\bx"
    sleep .02
    echo -ne "${RED}\b+${NC}"
}

# Load additional function files from directory
loadRcDir() {
    local dir="$1"
    local recursive="${2:-0}"  # 0=non-recursive, 1=recursive
    local debug="${3:-0}"      # 0=quiet, 1=debug output
    
    if [[ "$debug" == "1" ]]; then
        echo "DEBUG: Loading files from $dir (recursive=$recursive)"
    fi
    
    if [[ -d "$dir" ]]; then
        # Process non-recursive files first
        local rcFile
        for rcFile in "$dir"/*; do
            if [[ -f "$rcFile" && -r "$rcFile" ]]; then
                [[ "$debug" == "1" ]] && echo "DEBUG: Loading $rcFile"
                source "$rcFile" || echo "Error loading $rcFile" >&2
            fi
        done
        
        # Process subdirectories if recursive mode is enabled
        if [[ "$recursive" == "1" ]]; then
            for subdir in "$dir"/*; do
                if [[ -d "$subdir" ]]; then
                    [[ "$debug" == "1" ]] && echo "DEBUG: Entering subdirectory $subdir"
                    for subFile in "$subdir"/*; do
                        if [[ -f "$subFile" && -r "$subFile" ]]; then
                            [[ "$debug" == "1" ]] && echo "DEBUG: Loading $subFile"
                            source "$subFile" || echo "Error loading $subFile" >&2
                        fi
                    done
                fi
            done
        fi
    else
        [[ "$debug" == "1" ]] && echo "DEBUG: Directory $dir does not exist or is not readable"
    fi
}

# Add a directory to the PATH (redirects to path_manager)
# This function is kept for backward compatibility and redirects to add_path
add2path() {
    # Check if path_manager.sh is available
    if type add_path &>/dev/null; then
        # Using the new path management system
        add_path "$@"
    else
        echo "Path manager not available, using legacy method (PATH changes won't persist between sessions)."
        
        # Legacy implementation
        # Prompt the user
        read -p "Do you want to add the current directory ($PWD) to PATH? [Y/n]: " answer
        case "$answer" in
            [Nn]* )
                # User selected 'no', prompt for directory to add
                read -p "Enter the full path you want to add to PATH: " new_path
                ;;
            * )
                # Default to adding current directory
                new_path="$PWD"
                ;;
        esac
        
        # Ensure new_path is not empty
        if [ -z "$new_path" ]; then
            echo "No path provided. Aborting."
            return 1
        fi
        
        # Resolve to full path
        full_path=$(readlink -f "$new_path")
        
        # Check if full_path is already in PATH
        if echo "$PATH" | tr ':' '\n' | grep -Fxq "$full_path"; then
            echo "Directory $full_path is already in PATH."
        else
            export PATH="$full_path:$PATH"
            echo "Added $full_path to PATH."
        fi
    fi
}

# Function to check if we're in a virtual environment
function in_venv() {
    if [ -n "$VIRTUAL_ENV" ]; then
        return 0  # In a virtual environment
    else
        return 1  # Not in a virtual environment
    fi
}

# Function to activate automatic virtual environment creation
function venvon() {
    VENV_AUTO=1
    echo "Automatic virtual environment activation is ON."
}

# Function to deactivate automatic virtual environment creation
function venvoff() {
    unset VENV_AUTO
    echo "Automatic virtual environment activation is OFF."
}

# General function to handle pip commands (pip and pip3)
function pip_command() {
    local PIP_EXEC="$1"
    shift  # Remove the first argument (pip or pip3)
    
    # Check if VENV_AUTO is enabled and not already in a venv
    if [ -n "$VENV_AUTO" ] && ! in_venv; then
        # Create a virtual environment in the current directory if it doesn't exist
        if [ ! -d "./.venv" ]; then
            echo "Creating virtual environment in ./.venv"
            python3 -m venv ./.venv
            if [ $? -ne 0 ]; then
                echo "Error: Failed to create virtual environment."
                return 1
            fi
        fi
        
        # Activate the virtual environment
        source ./.venv/bin/activate
        if [ $? -ne 0 ]; then
            echo "Error: Failed to activate virtual environment."
            return 1
        fi
    fi
    
    # Run the actual pip command
    command "$PIP_EXEC" "$@"
    local PIP_STATUS=$?
    
    # Check for errors related to virtual environment
    if [ $PIP_STATUS -ne 0 ] && ! in_venv; then
        # Specific error checking can be added here based on pip's output
        if [[ "$1" == "install" ]]; then
            echo "It seems you're not in a virtual environment. Would you like to create one? (y/n)"
            read -r CREATE_VENV
            if [ "$CREATE_VENV" = "y" ] || [ "$CREATE_VENV" = "Y" ]; then
                # Create a virtual environment
                python3 -m venv ./.venv
                if [ $? -ne 0 ]; then
                    echo "Error: Failed to create virtual environment."
                    return 1
                fi
                
                # Activate the virtual environment
                source ./.venv/bin/activate
                if [ $? -ne 0 ]; then
                    echo "Error: Failed to activate virtual environment."
                    return 1
                fi
                
                # Retry the pip command
                command "$PIP_EXEC" "$@"
                return $?
            else
                echo "Continuing without a virtual environment."
            fi
        fi
    fi
    
    return $PIP_STATUS
}

# Override the pip command
function pip() {
    pip_command pip "$@"
}

# Override the pip3 command
function pip3() {
    pip_command pip3 "$@"
}

# Function to check internet connectivity and run apt update if connected
check_internet_and_update() {
    wget -q --spider http://google.com
    if [ $? -eq 0 ]; then
        echo "Connected to the internet."
        sudo apt update
    else
        echo "Not connected to the internet. Skipping apt update."
    fi
}

# Note: sourcebash alias has been moved to bash_aliases file

# Secure file deletion function that overrides rm
rm() {
    local secure_mode=0
    local force=0
    local recursive=0
    local verbose=0
    local interactive=0
    local args=()
    local secure_options=""

    # Process all arguments to capture rm flags
    for arg in "$@"; do
        case "$arg" in
            -s|--secure)
                secure_mode=1
                ;;
            -f|--force)
                force=1
                args+=("$arg")
                secure_options+=" -f"
                ;;
            -r|--recursive|-R)
                recursive=1
                args+=("$arg")
                ;;
            -v|--verbose)
                verbose=1
                args+=("$arg")
                secure_options+=" -v"
                ;;
            -i|--interactive)
                interactive=1
                args+=("$arg")
                ;;
            *)
                # Add other arguments to the list
                args+=("$arg")
                ;;
        esac
    done

    # Default to secure mode if configured in SENTINEL
    if [[ "${SENTINEL_SECURE_RM:-1}" == "1" ]]; then
        secure_mode=1
    fi

    # If in secure mode, use secure deletion methods
    if [[ $secure_mode -eq 1 ]]; then
        local files_to_process=()
        local is_empty=1

        # Get the list of files to delete (excluding options)
        for arg in "${args[@]}"; do
            if [[ "$arg" != -* ]]; then
                files_to_process+=("$arg")
                is_empty=0
            fi
        done

        # If no files were specified, show usage
        if [[ $is_empty -eq 1 ]]; then
            echo "Usage: rm [options] file(s)"
            echo "Secure deletion options:"
            echo "  -s, --secure     Force secure deletion (default in current configuration)"
            return 1
        fi

        # Process the files
        for file in "${files_to_process[@]}"; do
            # Skip if file doesn't exist
            if [[ ! -e "$file" ]]; then
                [[ $verbose -eq 1 ]] && echo "rm: cannot remove '$file': No such file or directory"
                continue
            fi

            # Handle directories
            if [[ -d "$file" ]]; then
                if [[ $recursive -eq 1 ]]; then
                    if [[ $interactive -eq 1 && $force -eq 0 ]]; then
                        read -p "Securely remove directory '$file' and all its contents? [y/N] " confirm
                        [[ "$confirm" != [yY]* ]] && continue
                    fi
                    
                    if [[ $verbose -eq 1 ]]; then
                        echo "Securely removing directory: $file"
                    fi
                    
                    # Process directory contents first
                    find "$file" -type f -print0 2>/dev/null | while IFS= read -r -d '' item; do
                        _secure_shred "$item" "$secure_options"
                    done
                    
                    # Then remove the empty directory structure
                    command rm -rf "$file"
                else
                    echo "rm: cannot remove '$file': Is a directory"
                    continue
                fi
            else
                # Handle files
                if [[ $interactive -eq 1 && $force -eq 0 ]]; then
                    read -p "Securely remove '$file'? [y/N] " confirm
                    [[ "$confirm" != [yY]* ]] && continue
                fi
                
                if [[ $verbose -eq 1 ]]; then
                    echo "Securely removing file: $file"
                fi
                
                # Securely delete the file
                _secure_shred "$file" "$secure_options"
            fi
        done
    else
        # Fall back to standard rm
        command rm "${args[@]}"
    fi
}

# Helper function for actual secure deletion
_secure_shred() {
    local file="$1"
    local options="$2"
    
    # Check file existence
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Use shred if available
    if command -v shred &>/dev/null; then
        # Default options: 3 passes, zero final pass, remove file
        shred -n 3 -z -u $options "$file"
    else
        # Fallback if shred is not available
        local filesize=$(stat -c %s "$file" 2>/dev/null || stat -f %z "$file" 2>/dev/null)
        local blocksize=1024
        local pass_count=3
        
        # For each pass
        for ((pass=1; pass<=pass_count; pass++)); do
            # Progress indicator
            echo -ne "Secure erase pass $pass/$pass_count: ["
            
            # Different patterns for different passes
            case $pass in
                1) pattern='\x00' ;; # Zero
                2) pattern='\xFF' ;; # Ones
                3) pattern=/dev/urandom ;; # Random
            esac
            
            if [[ "$pattern" == "/dev/urandom" ]]; then
                dd if=/dev/urandom of="$file" bs=$blocksize count=$((filesize/blocksize+1)) conv=notrunc >/dev/null 2>&1
            else
                dd if=/dev/zero bs=$blocksize count=$((filesize/blocksize+1)) 2>/dev/null | tr '\000' "$pattern" | dd of="$file" bs=$blocksize count=$((filesize/blocksize+1)) conv=notrunc >/dev/null 2>&1
            fi
            
            # Complete progress bar
            echo -ne "========================================"
            echo -e "] Done."
        done
        
        # Finally remove the file
        command rm -f "$file"
    fi
}

# Function to toggle secure rm mode
secure_rm_toggle() {
    if [[ "${SENTINEL_SECURE_RM:-1}" == "1" ]]; then
        SENTINEL_SECURE_RM=0
        echo "Secure rm mode is now OFF. Files deleted with rm will use standard deletion."
    else
        SENTINEL_SECURE_RM=1
        echo "Secure rm mode is now ON. Files deleted with rm will be securely erased."
    fi
}

# Function to manually trigger secure cleanup
secure_clean() {
    local scope="${1:-all}"
    
    echo "SENTINEL: Starting manual secure cleanup (scope: $scope)..."
    
    case "$scope" in
        history)
            history -c
            _secure_shred ~/.bash_history "-f"
            echo "Bash history cleared and securely erased."
            ;;
            
        temp)
            # Clean /tmp files created by current user
            find /tmp -user $(whoami) -type f -exec _secure_shred {} \; 2>/dev/null
            echo "Temporary files securely erased."
            ;;
            
        browser)
            # Firefox
            if [[ -d "$HOME/.mozilla/firefox" ]]; then
                find "$HOME/.mozilla/firefox" -name "*.sqlite" -exec _secure_shred {} \; 2>/dev/null
                find "$HOME/.mozilla/firefox" -name "cookies.sqlite*" -exec _secure_shred {} \; 2>/dev/null
            fi
            
            # Chrome/Chromium
            if [[ -d "$HOME/.config/google-chrome" ]]; then
                find "$HOME/.config/google-chrome/Default" -name "Cookies*" -exec _secure_shred {} \; 2>/dev/null
            fi
            if [[ -d "$HOME/.config/chromium" ]]; then
                find "$HOME/.config/chromium/Default" -name "Cookies*" -exec _secure_shred {} \; 2>/dev/null
            fi
            
            echo "Browser data securely erased."
            ;;
            
        cache)
            find "$HOME/.cache" -type f -exec _secure_shred {} \; 2>/dev/null
            echo "Cache files securely erased."
            ;;
            
        all)
            # Call the function recursively for each scope
            secure_clean history
            secure_clean temp
            secure_clean browser
            secure_clean cache
            
            # Additional cleaning for "all" scope
            _secure_shred "$HOME/.local/share/recently-used.xbel" "-f" 2>/dev/null
            _secure_shred "$HOME/.recently-used" "-f" 2>/dev/null
            
            # Clear clipboard
            if command -v xsel &>/dev/null; then
                echo -n | xsel --clipboard --input
            elif command -v xclip &>/dev/null; then
                echo -n | xclip -selection clipboard
            fi
            
            echo "All cleanup tasks completed."
            ;;
            
        *)
            echo "Unknown scope: $scope"
            echo "Available scopes: history, temp, browser, cache, all"
            return 1
            ;;
    esac
}

# Function to toggle module verbosity
sentinel_quiet() {
    if [[ "$1" == "on" ]]; then
        SENTINEL_QUIET_MODULES=1
        echo "SENTINEL quiet mode: ON - Minimal module output"
    elif [[ "$1" == "off" ]]; then
        SENTINEL_QUIET_MODULES=0
        echo "SENTINEL quiet mode: OFF - Verbose module output"
    else
        echo "SENTINEL quiet mode is currently: $([[ "${SENTINEL_QUIET_MODULES:-1}" == "1" ]] && echo "ON" || echo "OFF")"
        echo "Usage: sentinel_quiet [on|off]"
    fi
}

# Load additional functions from function directory
loadRcDir "${HOME}/.bash_functions.d" 1

# Quick alias setup
function qalias() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: qalias <alias_name> <command>"
    return 1
  fi
  
  local alias_name="$1"
  shift
  local alias_cmd="$*"
  
  # Add to aliases file
  echo "alias $alias_name='$alias_cmd'" >> ~/.bash_aliases
  
  # Load it immediately
  alias "$alias_name"="$alias_cmd"
  
  echo "Alias '$alias_name' created and activated"
}

# Ensure the script is sourced correctly - only need this check once
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Please source this script instead of executing it:"
    echo "source ~/.bashrc"
fi

# Generic lazy loading function
# This function creates a wrapper that loads the real command only when it's first invoked
# Usage: lazy_load <command> <load_function>
function lazy_load() {
    local cmd="$1"
    local load_function="$2"
    
    # Create a wrapper function with the same name as the command
    eval "function $cmd() {
        # Unset this function to avoid recursion
        unset -f $cmd
        
        # Call the loader function
        $load_function
        
        # Now call the real command with the original arguments
        $cmd \"\$@\"
    }"
}

# Collection of loader functions for different development environments
# These can be used with the lazy_load function

# Load NVM environment
function __load_nvm() {
    if [[ -d "$HOME/.nvm" ]]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    fi
}

# Load Pyenv environment
function __load_pyenv() {
    if [[ -d "$HOME/.pyenv" ]]; then
        export PYENV_ROOT="$HOME/.pyenv"
        [[ -d "$PYENV_ROOT/bin" ]] && PATH="$PYENV_ROOT/bin:$PATH"
        if command -v pyenv >/dev/null; then
            eval "$(pyenv init -)"
            eval "$(pyenv virtualenv-init -)"
        fi
    fi
}

# Load Cargo/Rust environment
function __load_cargo() {
    if [[ -f "$HOME/.cargo/env" ]]; then
        # shellcheck source=~/.cargo/env
        . "$HOME/.cargo/env"
    fi
}

# Load RVM environment
function __load_rvm() {
    if [[ -d "$HOME/.rvm" ]]; then
        export PATH="$PATH:$HOME/.rvm/bin"
        [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
    fi
}

# Load Go environment
function __load_go() {
    if [[ -d "$HOME/go" ]]; then
        export GOPATH="$HOME/go"
        export PATH="$PATH:$GOPATH/bin"
    fi
}

# Load Docker environment - useful for tools like docker-compose
function __load_docker() {
    # Load Docker completion if available
    if [[ -f /usr/share/bash-completion/completions/docker ]]; then
        source /usr/share/bash-completion/completions/docker
    fi
}

# Example usage:
# lazy_load nvm __load_nvm
# lazy_load pyenv __load_pyenv
# ... etc ...