#!/usr/bin/env bash
# SENTINEL Core Functions
# Enhanced shell functions for improved productivity and security
# Last Update: 2023-08-14

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
    if [[ -d "$dir" ]]; then
        local rcFile
        for rcFile in "$dir"/*; do
            if [[ -f "$rcFile" && -r "$rcFile" ]]; then
                source "$rcFile" || echo "Error loading $rcFile" >&2
            fi
        done
    fi
}

# Add a directory to the PATH
add2path() {
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
    export VENV_AUTO=1
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

# Alias to source .bashrc and run the update only when 'sourcebash' is called
alias sourcebash='source ~/.bashrc && check_internet_and_update && echo ".bashrc sourced and apt updated if connected."'

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
        export SENTINEL_SECURE_RM=0
        echo "Secure rm mode is now OFF. Files deleted with rm will use standard deletion."
    else
        export SENTINEL_SECURE_RM=1
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

# Default to secure rm mode
export SENTINEL_SECURE_RM=1

# Load additional functions from function directory
loadRcDir "${HOME}/.bash_functions.d"

# Ensure the script is sourced correctly - only need this check once
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Please source this script instead of executing it:"
    echo "source ~/.bashrc"
fi