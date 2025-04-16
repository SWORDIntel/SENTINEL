#!/usr/bin/env bash
# SENTINEL Core Functions
# Enhanced shell functions for improved productivity and security
# Last Update: 2025-04-14

# ============================================================================
# SECTION: UTILITY FUNCTIONS
# ============================================================================

# Visual spinner for progress indication
spin() {
    echo -ne "${RED}-"
    echo -ne "${WHITE}\b|"
    echo -ne "${BLUE}\bx"
    sleep .02
    echo -ne "${RED}\b+${NC}"
}

# More advanced progress bar with percentage
progress_bar() {
    local percent=$1
    local width=${2:-50}
    local bar_char=${3:-"#"}
    local empty_char=${4:-" "}
    
    # Calculate how many characters to fill
    local num_chars=$((percent * width / 100))
    
    # Print the progress bar
    printf "["
    printf "%0.s$bar_char" $(seq 1 $num_chars)
    printf "%0.s$empty_char" $(seq 1 $((width - num_chars)))
    printf "] %d%%\r" $percent
}

# Countdown timer function
countdown() {
    local seconds=${1:-10}
    local message=${2:-"Time's up!"}
    
    for (( i=seconds; i>=0; i-- )); do
        printf "\rCountdown: %02d seconds remaining" $i
        sleep 1
    done
    printf "\r%-50s\n" "$message"
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
        
        # Ask if user wants to make this permanent
        read -p "Do you want to make this PATH addition permanent? [y/N]: " perm_answer
        case "$perm_answer" in
            [Yy]* )
                echo "export PATH=\"$full_path:\$PATH\"" >> ~/.bashrc
                echo "PATH addition has been added to ~/.bashrc"
                ;;
            * )
                echo "PATH addition is temporary for this session only."
                ;;
        esac
    fi
}

# Remove a directory from PATH
remove_from_path() {
    local dir_to_remove="$1"
    
    if [ -z "$dir_to_remove" ]; then
        # If no argument provided, show directories in PATH and prompt
        echo "Current PATH directories:"
        echo "$PATH" | tr ':' '\n' | nl
        read -p "Enter the number of the directory to remove: " dir_num
        
        if [[ "$dir_num" =~ ^[0-9]+$ ]]; then
            dir_to_remove=$(echo "$PATH" | tr ':' '\n' | sed -n "${dir_num}p")
            if [ -z "$dir_to_remove" ]; then
                echo "Invalid selection."
                return 1
            fi
        else
            echo "Invalid input. Please enter a number."
            return 1
        fi
    fi
    
    # Remove the directory from PATH
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$dir_to_remove$" | tr '\n' ':' | sed 's/:$//')
    echo "Removed $dir_to_remove from PATH."
    
    # Ask if user wants to make this permanent
    read -p "Do you want to make this PATH removal permanent? [y/N]: " perm_answer
    case "$perm_answer" in
        [Yy]* )
            sed -i "\|export PATH=\"$dir_to_remove:\\\$PATH\"|d" ~/.bashrc
            echo "PATH removal has been made permanent in ~/.bashrc"
            ;;
        * )
            echo "PATH removal is temporary for this session only."
            ;;
    esac
}

# ============================================================================
# SECTION: VIRTUAL ENVIRONMENT MANAGEMENT
# ============================================================================

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

# Create and activate a Python virtual environment
mkvenv() {
    local venv_name=${1:-.venv}
    local python_version=${2:-3}
    
    # Check if Python is installed
    if ! command -v python$python_version &>/dev/null; then
        echo "Error: Python $python_version is not installed."
        return 1
    fi
    
    # Create the virtual environment
    echo "Creating virtual environment: $venv_name"
    python$python_version -m venv "$venv_name"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual environment."
        return 1
    fi
    
    # Activate the virtual environment
    echo "Activating virtual environment..."
    source "$venv_name/bin/activate"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to activate virtual environment."
        return 1
    fi
    
    # Update pip and setuptools
    echo "Updating pip and setuptools..."
    pip install --upgrade pip setuptools wheel
    
    echo "Virtual environment '$venv_name' created and activated."
    echo "Use 'deactivate' to exit the virtual environment."
}

# List all virtual environments in the current directory and subdirectories
lsvenv() {
    local max_depth=${1:-2}
    
    echo "Searching for virtual environments (max depth: $max_depth)..."
    
    # Find potential virtual environments
    find . -maxdepth $max_depth -name "bin" -path "*/.*venv*/bin" -o -path "*/venv*/bin" | while read -r bin_dir; do
        venv_dir=$(dirname "$bin_dir")
        if [ -f "$bin_dir/activate" ]; then
            echo "Found venv: $venv_dir"
            
            # Check Python version
            if [ -f "$bin_dir/python" ]; then
                python_version=$("$bin_dir/python" --version 2>&1)
                echo "  - $python_version"
                
                # List installed packages (top 5)
                if [ -f "$bin_dir/pip" ]; then
                    echo "  - Top packages:"
                    "$bin_dir/pip" list --format=freeze | sort | head -5 | sed 's/^/    /'
                    pkg_count=$("$bin_dir/pip" list | wc -l)
                    pkg_count=$((pkg_count - 2))  # Subtract header lines
                    echo "    ... and $pkg_count more packages"
                fi
            fi
            echo ""
        fi
    done
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

# ============================================================================
# SECTION: SYSTEM ADMINISTRATION
# ============================================================================

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

# Enhanced system update function that works across different Linux distributions
sysupdate() {
    # Check internet connectivity first
    wget -q --spider http://google.com
    if [ $? -ne 0 ]; then
        echo "Not connected to the internet. Aborting update."
        return 1
    fi
    
    # Detect the Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
        DISTRO=$(uname -s)
    fi
    
    echo "Detected distribution: $DISTRO"
    echo "Starting system update..."
    
    case "$DISTRO" in
        ubuntu|debian|pop|mint|elementary)
            echo "Updating APT packages..."
            sudo apt update && sudo apt upgrade -y
            echo "Cleaning up..."
            sudo apt autoremove -y && sudo apt clean
            ;;
        fedora)
            echo "Updating DNF packages..."
            sudo dnf update -y
            echo "Cleaning up..."
            sudo dnf autoremove -y && sudo dnf clean all
            ;;
        centos|rhel)
            echo "Updating YUM packages..."
            sudo yum update -y
            echo "Cleaning up..."
            sudo yum autoremove -y && sudo yum clean all
            ;;
        arch|manjaro)
            echo "Updating Pacman packages..."
            sudo pacman -Syu --noconfirm
            echo "Cleaning up..."
            sudo pacman -Sc --noconfirm
            ;;
        opensuse|suse)
            echo "Updating Zypper packages..."
            sudo zypper refresh && sudo zypper update -y
            echo "Cleaning up..."
            sudo zypper clean
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            echo "Please update your system manually."
            return 1
            ;;
    esac
    
    echo "System update completed."
}

# Function to monitor system resources
sysmonitor() {
    local interval=${1:-5}
    local count=${2:-10}
    
    echo "Monitoring system resources every $interval seconds for $count iterations..."
    echo "Press Ctrl+C to stop."
    echo
    
    for ((i=1; i<=count; i++)); do
        clear
        echo "=== System Monitor (Iteration $i/$count) ==="
        echo "Date: $(date)"
        echo
        
        echo "=== CPU Usage ==="
        top -bn1 | head -n 12
        echo
        
        echo "=== Memory Usage ==="
        free -h
        echo
        
        echo "=== Disk Usage ==="
        df -h | grep -v tmpfs
        echo
        
        echo "=== Network Connections ==="
        netstat -tuln | head -n 20
        echo
        
        if [ $i -lt $count ]; then
            sleep $interval
        fi
    done
}

# Function to check for and kill zombie processes
killzombies() {
    echo "Checking for zombie processes..."
    
    # Find zombie processes
    zombies=$(ps aux | awk '$8=="Z" {print $2}')
    
    if [ -z "$zombies" ]; then
        echo "No zombie processes found."
        return 0
    fi
    
    echo "Found zombie processes with PIDs: $zombies"
    
    # For each zombie, find and kill its parent
    for pid in $zombies; do
        ppid=$(ps -o ppid= -p $pid)
        if [ -n "$ppid" ]; then
            echo "Killing parent process $ppid of zombie $pid"
            kill -9 $ppid
        fi
    done
    
    echo "Zombie cleanup completed."
}

# Function to find and kill processes by name
killbyname() {
    local process_name="$1"
    local force=${2:-0}
    
    if [ -z "$process_name" ]; then
        echo "Usage: killbyname <process_name> [force]"
        echo "  process_name: Name of the process to kill"
        echo "  force: Use 1 to force kill (-9), 0 for normal kill (default)"
        return 1
    fi
    
    echo "Searching for processes matching: $process_name"
    
    # Find processes
    local pids=$(pgrep -f "$process_name")
    
    if [ -z "$pids" ]; then
        echo "No processes found matching: $process_name"
        return 0
    fi
    
    # Show processes before killing
    echo "Found the following processes:"
    ps -f -p $pids
    
    # Confirm before killing
    read -p "Kill these processes? [y/N] " confirm
    if [[ "$confirm" != [yY]* ]]; then
        echo "Operation cancelled."
        return 0
    fi
    
    # Kill processes
    if [ "$force" -eq 1 ]; then
        echo "Force killing processes..."
        kill -9 $pids
    else
        echo "Killing processes..."
        kill $pids
    fi
    
    echo "Process termination requested."
}

# ============================================================================
# SECTION: SECURE FILE OPERATIONS
# ============================================================================

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

# Secure file encryption function
encrypt_file() {
    local file="$1"
    local output="${2:-${file}.enc}"
    
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found."
        return 1
    fi
    
    # Check if openssl is available
    if ! command -v openssl &>/dev/null; then
        echo "Error: OpenSSL is not installed. Please install it first."
        return 1
    fi
    
    # Encrypt the file
    echo "Encrypting file: $file"
    openssl enc -aes-256-cbc -salt -in "$file" -out "$output"
    
    if [ $? -eq 0 ]; then
        echo "File encrypted successfully: $output"
        
        # Ask if user wants to securely delete the original
        read -p "Do you want to securely delete the original file? [y/N] " delete_original
        if [[ "$delete_original" =~ ^[Yy]$ ]]; then
            rm -s "$file"
            echo "Original file securely deleted."
        fi
    else
        echo "Encryption failed."
        rm -f "$output"  # Remove failed output
        return 1
    fi
}

# Secure file decryption function
decrypt_file() {
    local file="$1"
    local output="${2:-${file%.enc}}"
    
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found."
        return 1
    fi
    
    # Check if openssl is available
    if ! command -v openssl &>/dev/null; then
        echo "Error: OpenSSL is not installed. Please install it first."
        return 1
    fi
    
    # Decrypt the file
    echo "Decrypting file: $file"
    openssl enc -d -aes-256-cbc -in "$file" -out "$output"
    
    if [ $? -eq 0 ]; then
        echo "File decrypted successfully: $output"
    else
        echo "Decryption failed. Check if the password is correct."
        rm -f "$output"  # Remove failed output
        return 1
    fi
}

# ============================================================================
# SECTION: FILE AND DIRECTORY MANAGEMENT
# ============================================================================

# Create a timestamped backup of a file or directory
backup() {
    local target="$1"
    local backup_dir="${2:-$HOME/backups}"
    
    if [ -z "$target" ]; then
        echo "Usage: backup <file_or_directory> [backup_directory]"
        return 1
    fi
    
    if [ ! -e "$target" ]; then
        echo "Error: '$target' does not exist."
        return 1
    fi
    
    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"
    
    # Generate timestamp
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local basename=$(basename "$target")
    local backup_file="${backup_dir}/${basename}-${timestamp}.tar.gz"
    
    # Create backup
    echo "Creating backup of '$target'..."
    tar -czf "$backup_file" "$target"
    
    if [ $? -eq 0 ]; then
        echo "Backup created: $backup_file"
    else
        echo "Backup failed."
        rm -f "$backup_file"  # Remove failed backup
        return 1
    fi
}

# Find and replace text in files
find_replace() {
    local search="$1"
    local replace="$2"
    local path="${3:-.}"
    local file_pattern="${4:-*}"
    
    if [ -z "$search" ] || [ -z "$replace" ]; then
        echo "Usage: find_replace <search_text> <replace_text> [path] [file_pattern]"
        echo "Example: find_replace 'old text' 'new text' ./src '*.py'"
        return 1
    fi
    
    echo "Searching for files containing '$search' in $path..."
    
    # Find files containing the search text
    local files=$(grep -l "$search" "$path"/$file_pattern 2>/dev/null)
    
    if [ -z "$files" ]; then
        echo "No files found containing '$search'."
        return 0
    fi
    
    # Show files that will be modified
    echo "The following files will be modified:"
    echo "$files" | sed 's/^/  /'
    
    # Confirm before proceeding
    read -p "Proceed with replacement? [y/N] " confirm
    if [[ "$confirm" != [yY]* ]]; then
        echo "Operation cancelled."
        return 0
    fi
    
    # Perform replacement
    echo "Replacing '$search' with '$replace'..."
    echo "$files" | xargs sed -i "s/$search/$replace/g"
    
    echo "Replacement completed."
}

# Find duplicate files in a directory
find_dupes() {
    local dir="${1:-.}"
    local min_size="${2:-1k}"  # Minimum file size to consider
    
    if [ ! -d "$dir" ]; then
        echo "Error: '$dir' is not a directory."
        return 1
    fi
    
    echo "Finding duplicate files in '$dir' (minimum size: $min_size)..."
    
    # Check if fdupes is available
    if command -v fdupes &>/dev/null; then
        fdupes -r -S "$min_size" "$dir"
    else
        # Fallback to find + md5sum
        echo "fdupes not found, using find + md5sum (this may be slower)..."
        
        # Create temporary file
        local tmp_file=$(mktemp)
        
        # Find files and compute checksums
        find "$dir" -type f -size "+$min_size" -exec md5sum {} \; | sort > "$tmp_file"
        
        # Find duplicates
        echo "Duplicate files:"
        cat "$tmp_file" | cut -d ' ' -f 1 | uniq -d | while read checksum; do
            echo "Checksum: $checksum"
            grep "$checksum" "$tmp_file" | cut -d ' ' -f 3-
            echo
        done
        
        # Clean up
        rm -f "$tmp_file"
    fi
}

# Create a directory and cd into it
mkcd() {
    local dir="$1"
    
    if [ -z "$dir" ]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    
    mkdir -p "$dir" && cd "$dir"
}

# Extract various archive formats
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive_file>"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "Error: '$1' is not a valid file."
        return 1
    fi
    
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.tar.xz)    tar xJf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar x "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *)           echo "Error: '$1' cannot be extracted via extract function." ;;
    esac
}

# ============================================================================
# SECTION: DEVELOPMENT TOOLS
# ============================================================================

# Git branch in prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Set prompt with git branch
set_git_prompt() {
    export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\$ "
}

# Git status summary
gitstatus() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Not a git repository."
        return 1
    fi
    
    echo "=== Git Status Summary ==="
    echo "Branch: $(git branch --show-current)"
    echo "Commit: $(git rev-parse --short HEAD) - $(git log -1 --pretty=%B | head -1)"
    
    # Check for uncommitted changes
    if ! git diff --quiet; then
        echo "Uncommitted changes: YES"
    else
        echo "Uncommitted changes: NO"
    fi
    
    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "Untracked files: YES"
    else
        echo "Untracked files: NO"
    fi
    
    # Check for stashed changes
    local stash_count=$(git stash list | wc -l)
    echo "Stashed changes: $stash_count"
    
    # Check remote status
    echo "Remote status:"
    git fetch --quiet
    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "unknown")
    local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "unknown")
    
    if [ "$ahead" != "unknown" ] && [ "$behind" != "unknown" ]; then
        echo "  Ahead: $ahead commit(s)"
        echo "  Behind: $behind commit(s)"
    else
        echo "  No upstream branch configured"
    fi
}

# Git quick commit and push
gitquick() {
    local message="$1"
    
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Not a git repository."
        return 1
    fi
    
    if [ -z "$message" ]; then
        echo "Usage: gitquick <commit_message>"
        return 1
    fi
    
    # Add all changes
    git add .
    
    # Commit with message
    git commit -m "$message"
    
    # Push to remote
    git push
    
    echo "Changes committed and pushed."
}

# Run a Python HTTP server
pyserver() {
    local port="${1:-8000}"
    local ip=$(hostname -I | cut -d' ' -f1)
    
    echo "Starting Python HTTP server on port $port"
    echo "Local URL: http://localhost:$port"
    echo "Network URL: http://$ip:$port"
    
    python3 -m http.server "$port"
}

# Generate a random password
genpassword() {
    local length="${1:-16}"
    local use_special="${2:-1}"
    
    if ! [[ "$length" =~ ^[0-9]+$ ]]; then
        echo "Error: Length must be a number."
        return 1
    fi
    
    if [ "$use_special" -eq 1 ]; then
        # With special characters
        LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+?><~' < /dev/urandom | head -c "$length"
    else
        # Without special characters
        LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
    fi
    
    echo  # Add newline
}

# ============================================================================
# SECTION: NETWORK TOOLS
# ============================================================================

# Check if a port is open
portcheck() {
    local host="$1"
    local port="$2"
    
    if [ -z "$host" ] || [ -z "$port" ]; then
        echo "Usage: portcheck <host> <port>"
        return 1
    fi
    
    # Try to connect to the port
    timeout 5 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "Port $port is OPEN on $host"
        return 0
    else
        echo "Port $port is CLOSED on $host"
        return 1
    fi
}

# Scan common ports on a host
portscan() {
    local host="$1"
    local start_port="${2:-1}"
    local end_port="${3:-1024}"
    
    if [ -z "$host" ]; then
        echo "Usage: portscan <host> [start_port] [end_port]"
        return 1
    fi
    
    echo "Scanning ports $start_port-$end_port on $host..."
    echo "Open ports:"
    
    for port in $(seq $start_port $end_port); do
        # Show progress every 100 ports
        if [ $((port % 100)) -eq 0 ]; then
            echo -ne "Scanning port $port/$end_port\r"
        fi
        
        # Try to connect to the port
        timeout 1 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "$port: OPEN"
        fi
    done
    
    echo "Scan completed."
}

# Get public IP address
myip() {
    echo "Fetching public IP address..."
    
    # Try multiple services in case one is down
    curl -s https://api.ipify.org || \
    curl -s https://ifconfig.me || \
    curl -s https://icanhazip.com
    
    echo  # Add newline
}

# Network interface information
netinfo() {
    echo "=== Network Interface Information ==="
    
    # Get default interface
    local default_iface=$(ip route | grep default | awk '{print $5}' | head -1)
    
    echo "Default interface: $default_iface"
    echo
    
    # Show all interfaces
    echo "All interfaces:"
    ip -brief addr show
    echo
    
    # Show routing table
    echo "Routing table:"
    ip route
    echo
    
    # Show DNS servers
    echo "DNS servers:"
    grep nameserver /etc/resolv.conf
    echo
    
    # Show public IP
    echo "Public IP:"
    myip
}

# ============================================================================
# SECTION: PRODUCTIVITY TOOLS
# ============================================================================

# Simple note-taking function
note() {
    local notes_dir="${NOTES_DIR:-$HOME/.notes}"
    local action="$1"
    shift
    
    # Create notes directory if it doesn't exist
    mkdir -p "$notes_dir"
    
    case "$action" in
        add|a)
            # Add a new note
            local note_text="$*"
            local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
            echo "[$timestamp] $note_text" >> "$notes_dir/notes.txt"
            echo "Note added."
            ;;
            
        list|ls|l)
            # List all notes
            if [ -f "$notes_dir/notes.txt" ]; then
                cat -n "$notes_dir/notes.txt"
            else
                echo "No notes found."
            fi
            ;;
            
        search|s)
            # Search notes
            local search_term="$*"
            if [ -f "$notes_dir/notes.txt" ]; then
                grep -n "$search_term" "$notes_dir/notes.txt"
            else
                echo "No notes found."
            fi
            ;;
            
        delete|d)
            # Delete a note by line number
            local line_num="$1"
            if [ -f "$notes_dir/notes.txt" ]; then
                if [[ "$line_num" =~ ^[0-9]+$ ]]; then
                    sed -i "${line_num}d" "$notes_dir/notes.txt"
                    echo "Note deleted."
                else
                    echo "Error: Line number must be a number."
                fi
            else
                echo "No notes found."
            fi
            ;;
            
        clear)
            # Clear all notes
            read -p "Are you sure you want to clear all notes? [y/N] " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm -f "$notes_dir/notes.txt"
                echo "All notes cleared."
            else
                echo "Operation cancelled."
            fi
            ;;
            
        *)
            # Show usage
            echo "Usage: note <action> [arguments]"
            echo "Actions:"
            echo "  add|a <text>      Add a new note"
            echo "  list|ls|l         List all notes"
            echo "  search|s <term>   Search notes"
            echo "  delete|d <line>   Delete note by line number"
            echo "  clear             Clear all notes"
            ;;
    esac
}

# Simple todo list function
todo() {
    local todo_file="${TODO_FILE:-$HOME/.todo.txt}"
    local action="$1"
    shift
    
    # Create todo file if it doesn't exist
    touch "$todo_file"
    
    case "$action" in
        add|a)
            # Add a new todo item
            local todo_text="$*"
            echo "[ ] $todo_text" >> "$todo_file"
            echo "Todo item added."
            ;;
            
        list|ls|l)
            # List all todo items
            if [ -s "$todo_file" ]; then
                cat -n "$todo_file"
            else
                echo "No todo items found."
            fi
            ;;
            
        done|d)
            # Mark a todo item as done
            local line_num="$1"
            if [[ "$line_num" =~ ^[0-9]+$ ]]; then
                sed -i "${line_num}s/\[ \]/\[x\]/" "$todo_file"
                echo "Todo item marked as done."
            else
                echo "Error: Line number must be a number."
            fi
            ;;
            
        undone|u)
            # Mark a todo item as not done
            local line_num="$1"
            if [[ "$line_num" =~ ^[0-9]+$ ]]; then
                sed -i "${line_num}s/\[x\]/\[ \]/" "$todo_file"
                echo "Todo item marked as not done."
            else
                echo "Error: Line number must be a number."
            fi
            ;;
            
        delete|del)
            # Delete a todo item
            local line_num="$1"
            if [[ "$line_num" =~ ^[0-9]+$ ]]; then
                sed -i "${line_num}d" "$todo_file"
                echo "Todo item deleted."
            else
                echo "Error: Line number must be a number."
            fi
            ;;
            
        clear)
            # Clear all todo items
            read -p "Are you sure you want to clear all todo items? [y/N] " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                > "$todo_file"
                echo "All todo items cleared."
            else
                echo "Operation cancelled."
            fi
            ;;
            
        *)
            # Show usage
            echo "Usage: todo <action> [arguments]"
            echo "Actions:"
            echo "  add|a <text>      Add a new todo item"
            echo "  list|ls|l         List all todo items"
            echo "  done|d <line>     Mark todo item as done"
            echo "  undone|u <line>   Mark todo item as not done"
            echo "  delete|del <line> Delete todo item"
            echo "  clear             Clear all todo items"
            ;;
    esac
}

# Simple timer function
timer() {
    local duration="$1"
    local message="${2:-Time is up!}"
    
    if [ -z "$duration" ]; then
        echo "Usage: timer <duration> [message]"
        echo "Duration can be specified in seconds, or as 1h, 5m, 30s, etc."
        return 1
    fi
    
    # Convert duration to seconds
    local seconds=0
    if [[ "$duration" =~ ^[0-9]+$ ]]; then
        # Duration is already in seconds
        seconds=$duration
    elif [[ "$duration" =~ ^([0-9]+)h$ ]]; then
        # Duration is in hours
        seconds=$((${BASH_REMATCH[1]} * 3600))
    elif [[ "$duration" =~ ^([0-9]+)m$ ]]; then
        # Duration is in minutes
        seconds=$((${BASH_REMATCH[1]} * 60))
    elif [[ "$duration" =~ ^([0-9]+)s$ ]]; then
        # Duration is in seconds
        seconds=${BASH_REMATCH[1]}
    elif [[ "$duration" =~ ^([0-9]+)h([0-9]+)m$ ]]; then
        # Duration is in hours and minutes
        seconds=$(( (${BASH_REMATCH[1]} * 3600) + (${BASH_REMATCH[2]} * 60) ))
    elif [[ "$duration" =~ ^([0-9]+)m([0-9]+)s$ ]]; then
        # Duration is in minutes and seconds
        seconds=$(( (${BASH_REMATCH[1]} * 60) + ${BASH_REMATCH[2]} ))
    else
        echo "Error: Invalid duration format."
        return 1
    fi
    
    echo "Timer set for $seconds seconds."
    echo "Starting timer at $(date +"%H:%M:%S")"
    echo "Press Ctrl+C to cancel."
    
    # Start the timer
    local start_time=$(date +%s)
    local end_time=$((start_time + seconds))
    
    while [ $(date +%s) -lt $end_time ]; do
        local remaining=$((end_time - $(date +%s)))
        local hours=$((remaining / 3600))
        local minutes=$(( (remaining % 3600) / 60 ))
        local secs=$((remaining % 60))
        
        printf "\rTime remaining: %02d:%02d:%02d" $hours $minutes $secs
        sleep 1
    done
    
    printf "\r%-50s\n" "$message"
    
    # Play a sound if available
    if command -v paplay &>/dev/null && [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga
    elif command -v spd-say &>/dev/null; then
        spd-say "$message"
    elif command -v say &>/dev/null; then
        say "$message"
    else
        # Visual bell
        echo -e "\a"
    fi
}

# Default to secure rm mode
export SENTINEL_SECURE_RM=1

# Load additional functions from function directory
loadRcDir "${HOME}/.bash_functions.d"

# Set git-aware prompt if in a git repository
if command -v git &>/dev/null; then
    set_git_prompt
fi

# Ensure the script is sourced correctly - only need this check once
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Please source this script instead of executing it:"
    echo "source ~/.bashrc"
fi
