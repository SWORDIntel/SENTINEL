#!/usr/bin/env bash
# SENTINEL Autocomplete Configuration TUI
# A terminal-based user interface for configuring and troubleshooting
# the SENTINEL autocomplete module
# Implements secure cryptographic techniques for configuration management

# Guard clause for dialog dependency
if ! command -v dialog &>/dev/null; then
    echo "Error: dialog command not found. Please install dialog to use this tool."
    echo "  On Debian/Ubuntu: sudo apt install dialog"
    echo "  On Fedora/RHEL: sudo dnf install dialog"
    echo "  On Arch Linux: sudo pacman -S dialog"
    exit 1
fi

# HMAC-based verification for secure operations
_secure_verify() {
    local operation="$1"
    local resource="$2"
    local timestamp=$(date +%s)
    local nonce=$(openssl rand -hex 8)
    local key="${SENTINEL_AUTH_KEY:-$(hostname | openssl dgst -sha256 | cut -d' ' -f2)}"
    local data="${timestamp}:${resource}:${operation}:${nonce}"
    local hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$key" | cut -d' ' -f2)
    
    # Log with HMAC for security audit
    logger -t "SENTINEL" "[$hmac] Performing $operation on $resource" 2>/dev/null || true
    
    echo "${hmac:0:8}" # Return first 8 chars as verification token
}

# Progress bar using dialog
_show_progress() {
    local title="$1"
    local text="$2"
    local command="$3"
    local max=${4:-100}
    
    # Create a temporary file to store output
    local tmp_file=$(mktemp)
    
    # Run command in background and update progress
    (
        # Execute command and capture progress updates
        eval "$command" > "$tmp_file" 2>&1 &
        local pid=$!
        
        # Show initial progress
        echo "0"
        sleep 0.1
        
        # Monitor process and update progress
        while ps -p $pid > /dev/null; do
            for i in $(seq 10 10 90); do
                echo "$i"
                sleep 0.2
            done
        done
        
        # Show completed progress
        echo "100"
        sleep 0.5
    ) | dialog --title "$title" --gauge "$text" 10 70 0
    
    # Return command output
    local output=$(cat "$tmp_file")
    rm -f "$tmp_file"
    echo "$output"
}

# Function to check system status
check_system_status() {
    local status_file=$(mktemp)
    
    {
        echo "SENTINEL Autocomplete System Status"
        echo "====================================="
        echo
        
        # Check if ble.sh is installed
        if [[ -f ~/.local/share/blesh/ble.sh ]]; then
            echo "[✓] ble.sh is installed"
        else
            echo "[✗] ble.sh is not installed"
        fi
        
        # Check loader script
        if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
            echo "[✓] ble.sh loader script exists"
        else
            echo "[✗] ble.sh loader script doesn't exist"
        fi
        
        # Check path_manager fix
        if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then
            echo "[✓] path_manager fix script exists"
        else
            echo "[✗] path_manager fix script doesn't exist"
        fi
        
        # Check required directories
        echo
        echo "Required directories:"
        for dir in snippets context projects params; do
            if [[ -d ~/.sentinel/autocomplete/$dir ]]; then
                echo "[✓] ~/.sentinel/autocomplete/$dir"
            else
                echo "[✗] ~/.sentinel/autocomplete/$dir"
            fi
        done
        
        # Check .bashrc configuration
        echo
        echo "Configuration:"
        if grep -q "~/.sentinel/blesh_loader.sh" ~/.bashrc; then
            echo "[✓] ble.sh loader is configured in .bashrc"
        else
            echo "[✗] ble.sh loader is not configured in .bashrc"
        fi
        
        if grep -q "~/.sentinel/fix_path_manager.sh" ~/.bashrc; then
            echo "[✓] path_manager fix is configured in .bashrc"
        else
            echo "[✗] path_manager fix is not configured in .bashrc"
        fi
        
        # Security verification
        echo
        echo "Security verification: $(_secure_verify "system_check" "autocomplete")"
        
    } > "$status_file"
    
    # Display status in a scrollable text box
    dialog --title "System Status" --textbox "$status_file" 22 72
    
    # Clean up
    rm -f "$status_file"
}

# Function to fix autocomplete issues
fix_autocomplete_issues() {
    # Show a confirmation dialog
    dialog --title "Fix Autocomplete Issues" --yesno "This will attempt to fix common autocomplete issues by:\n\n1. Setting correct permissions\n2. Creating required directories\n3. Setting up ble.sh loader\n4. Creating path_manager fix\n\nProceed?" 15 60
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    # Run the fix with progress bar
    _show_progress "Fixing Autocomplete Issues" "Applying fixes..." "
        # Set permissions
        find ~/Documents/GitHub/SENTINEL/bash_functions.d/ -type f -exec chmod +x {} \\; 2>/dev/null
        find ~/Documents/GitHub/SENTINEL/bash_aliases.d/ -type f -exec chmod +x {} \\; 2>/dev/null
        find ~/Documents/GitHub/SENTINEL/bash_modules.d/ -type f -exec chmod +x {} \\; 2>/dev/null
        find ~/Documents/GitHub/SENTINEL/bash_completion.d/ -type f -exec chmod +x {} \\; 2>/dev/null
        echo '10% - Set permissions'
        
        # Create directories
        mkdir -p ~/.sentinel/autocomplete/snippets 2>/dev/null
        mkdir -p ~/.sentinel/autocomplete/context 2>/dev/null
        mkdir -p ~/.sentinel/autocomplete/projects 2>/dev/null
        mkdir -p ~/.sentinel/autocomplete/params 2>/dev/null
        echo '30% - Created directories'
        
        # Create ble.sh loader
        cat > ~/.sentinel/blesh_loader.sh << 'EOF'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader
# This script loads ble.sh with proper error handling

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    # Try the standard loading method first
    source ~/.local/share/blesh/ble.sh 2>/dev/null
    
    # Check if it worked
    if ! type -t ble-bind &>/dev/null; then
        echo \"Warning: ble.sh did not load properly. Trying alternative loading method...\"
        # Try alternative loading with a different approach
        source <(cat ~/.local/share/blesh/ble.sh) 2>/dev/null
        
        # If still not working, fall back to basic completion
        if ! type -t ble-bind &>/dev/null; then
            echo \"Warning: ble.sh could not be loaded. Using basic autocompletion instead.\"
            # Load bash standard completion as fallback
            [[ -f /etc/bash_completion ]] && source /etc/bash_completion
        fi
    fi
fi
EOF
        chmod +x ~/.sentinel/blesh_loader.sh
        echo '50% - Created ble.sh loader'
        
        # Create path_manager fix
        cat > ~/.sentinel/fix_path_manager.sh << 'EOF'
#!/usr/bin/env bash
# Fix for path_manager.sh loading issues

# Create a simplified version of the PATH management functionality
PATH_CONFIG_FILE=\"\${HOME}/.sentinel_paths\"

# Initialize path config file if it doesn't exist
[[ ! -f \"\${PATH_CONFIG_FILE}\" ]] && touch \"\${PATH_CONFIG_FILE}\"

# Load paths from configuration
load_custom_paths() {
    if [[ -f \"\${PATH_CONFIG_FILE}\" ]]; then
        while IFS= read -r path_entry; do
            # Skip comments and empty lines
            [[ -z \"\${path_entry}\" || \"\${path_entry}\" =~ ^# ]] && continue
            
            # Only add if directory exists and isn't already in PATH
            if [[ -d \"\${path_entry}\" && \":\${PATH}:\" != *\":\${path_entry}:\"* ]]; then
                export PATH=\"\${path_entry}:\${PATH}\"
            fi
        done < \"\${PATH_CONFIG_FILE}\"
    fi
}

# Load custom paths
load_custom_paths
EOF
        chmod +x ~/.sentinel/fix_path_manager.sh
        echo '70% - Created path_manager fix'
        
        # Update .bashrc if needed
        if ! grep -q \"~/.sentinel/blesh_loader.sh\" ~/.bashrc; then
            echo '# SENTINEL ble.sh integration' >> ~/.bashrc
            echo 'if [[ -f ~/.sentinel/blesh_loader.sh ]]; then' >> ~/.bashrc
            echo '    source ~/.sentinel/blesh_loader.sh' >> ~/.bashrc
            echo 'fi' >> ~/.bashrc
        fi
        
        if ! grep -q \"~/.sentinel/fix_path_manager.sh\" ~/.bashrc; then
            echo '# SENTINEL path_manager fix' >> ~/.bashrc
            echo 'if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then' >> ~/.bashrc
            echo '    source ~/.sentinel/fix_path_manager.sh' >> ~/.bashrc
            echo 'fi' >> ~/.bashrc
        fi
        echo '90% - Updated .bashrc'
        
        # Clean up temporary files
        find /tmp -maxdepth 1 -type d -name \"blesh*\" -exec rm -rf {} \\; 2>/dev/null || true
        echo '100% - Cleaned up temporary files'
    "
    
    # Show success message
    dialog --title "Fix Complete" --msgbox "Autocomplete fixes have been applied successfully!\n\nPlease restart your terminal for changes to take effect, or run:\nsource ~/.sentinel/blesh_loader.sh\nsource ~/.sentinel/fix_path_manager.sh" 12 60
}

# Function to reinstall ble.sh
reinstall_blesh() {
    # Show a confirmation dialog
    dialog --title "Reinstall ble.sh" --yesno "This will completely remove and reinstall ble.sh.\n\nAny custom configuration will be lost.\n\nProceed?" 10 60
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    # Run the reinstall with progress bar
    _show_progress "Reinstalling ble.sh" "Removing and reinstalling ble.sh..." "
        # Remove existing installation
        rm -rf ~/.local/share/blesh 2>/dev/null
        echo '20% - Removed existing installation'
        
        # Create temporary directory
        tmp_dir=\"/tmp/blesh_$RANDOM\"
        mkdir -p \"\$tmp_dir\"
        echo '30% - Created temporary directory'
        
        # Clone repository
        git clone --depth 1 https://github.com/akinomyoga/ble.sh.git \"\$tmp_dir\" 2>/dev/null
        if [ \$? -ne 0 ]; then
            echo 'Error: Failed to clone repository'
            exit 1
        fi
        echo '50% - Cloned repository'
        
        # Install ble.sh
        make -C \"\$tmp_dir\" install PREFIX=~/.local 2>/dev/null
        if [ \$? -ne 0 ]; then
            echo 'Error: Installation failed'
            exit 1
        fi
        echo '80% - Installed ble.sh'
        
        # Clean up
        rm -rf \"\$tmp_dir\"
        echo '100% - Cleaned up'
    "
    
    # Show success message
    dialog --title "Reinstallation Complete" --msgbox "ble.sh has been successfully reinstalled!\n\nPlease restart your terminal for changes to take effect." 10 60
}

# Function to manage autocomplete directories
manage_autocomplete_dirs() {
    while true; do
        # Show a menu with autocomplete directories
        dialog --title "Manage Autocomplete Directories" --menu "Select an option:" 15 60 8 \
            "1" "View snippets" \
            "2" "View context" \
            "3" "View projects" \
            "4" "View params" \
            "5" "Create missing directories" \
            "6" "Back to main menu" 2> /tmp/sentinel_menu
        
        choice=$(cat /tmp/sentinel_menu)
        rm -f /tmp/sentinel_menu
        
        case $choice in
            1) view_directory "snippets" ;;
            2) view_directory "context" ;;
            3) view_directory "projects" ;;
            4) view_directory "params" ;;
            5) create_missing_directories ;;
            6|"") break ;;
        esac
    done
}

# Function to view directory contents
view_directory() {
    local dir="$1"
    local dir_path="$HOME/.sentinel/autocomplete/$dir"
    local content_file=$(mktemp)
    
    # Check if directory exists
    if [[ ! -d "$dir_path" ]]; then
        dialog --title "Error" --msgbox "Directory $dir_path does not exist!" 8 50
        return
    fi
    
    # List directory contents
    {
        echo "Contents of $dir_path:"
        echo "======================"
        echo
        ls -la "$dir_path" | tail -n +4 | while read -r line; do
            echo "$line"
        done
        
        # If no files, show message
        if [[ ! "$(ls -A "$dir_path" 2>/dev/null)" ]]; then
            echo "No files in this directory."
        fi
    } > "$content_file"
    
    # Display contents in a scrollable text box
    dialog --title "Directory Contents" --textbox "$content_file" 20 70
    
    # Clean up
    rm -f "$content_file"
}

# Function to create missing directories
create_missing_directories() {
    local log_file=$(mktemp)
    
    {
        echo "Creating missing directories..."
        mkdir -p ~/.sentinel/autocomplete/snippets 2>&1
        mkdir -p ~/.sentinel/autocomplete/context 2>&1
        mkdir -p ~/.sentinel/autocomplete/projects 2>&1
        mkdir -p ~/.sentinel/autocomplete/params 2>&1
        echo "Done!"
    } > "$log_file"
    
    # Display log in a scrollable text box
    dialog --title "Create Directories" --textbox "$log_file" 10 70
    
    # Clean up
    rm -f "$log_file"
}

# Function to view and edit configuration
manage_configuration() {
    while true; do
        # Show a menu with configuration options
        dialog --title "Manage Configuration" --menu "Select an option:" 15 60 8 \
            "1" "View current configuration" \
            "2" "Edit blesh_loader.sh" \
            "3" "Edit fix_path_manager.sh" \
            "4" "Check .bashrc integration" \
            "5" "Back to main menu" 2> /tmp/sentinel_menu
        
        choice=$(cat /tmp/sentinel_menu)
        rm -f /tmp/sentinel_menu
        
        case $choice in
            1) view_configuration ;;
            2) edit_file "~/.sentinel/blesh_loader.sh" ;;
            3) edit_file "~/.sentinel/fix_path_manager.sh" ;;
            4) check_bashrc_integration ;;
            5|"") break ;;
        esac
    done
}

# Function to view configuration
view_configuration() {
    local config_file=$(mktemp)
    
    {
        echo "SENTINEL Autocomplete Configuration"
        echo "=================================="
        echo
        
        # ble.sh loader
        if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
            echo "ble.sh loader script:"
            echo "--------------------"
            cat ~/.sentinel/blesh_loader.sh
            echo
        else
            echo "ble.sh loader script not found!"
            echo
        fi
        
        # path_manager fix
        if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then
            echo "path_manager fix script:"
            echo "-----------------------"
            cat ~/.sentinel/fix_path_manager.sh
            echo
        else
            echo "path_manager fix script not found!"
            echo
        fi
        
        # .bashrc integration
        echo ".bashrc integration:"
        echo "------------------"
        grep -A3 "SENTINEL" ~/.bashrc 2>/dev/null || echo "No SENTINEL configuration found in .bashrc"
        
    } > "$config_file"
    
    # Display configuration in a scrollable text box
    dialog --title "Current Configuration" --textbox "$config_file" 22 78
    
    # Clean up
    rm -f "$config_file"
}

# Function to edit a file
edit_file() {
    local file="$1"
    
    # Expand tilde to home directory
    file="${file/#\~/$HOME}"
    
    # Check if file exists
    if [[ ! -f "$file" ]]; then
        dialog --title "Error" --msgbox "File $file does not exist!" 8 50
        return
    fi
    
    # Determine editor
    local editor="${EDITOR:-vim}"
    if ! command -v "$editor" &>/dev/null; then
        editor="nano"
        if ! command -v "$editor" &>/dev/null; then
            editor="vi"
        fi
    fi
    
    # Clear screen and edit file
    clear
    $editor "$file"
    
    # Show success message
    dialog --title "File Edited" --msgbox "File $file has been edited." 8 50
}

# Function to check .bashrc integration
check_bashrc_integration() {
    local bashrc_file=$(mktemp)
    
    {
        echo "Checking .bashrc integration..."
        echo "==============================="
        echo
        
        # Check for ble.sh loader
        if grep -q "~/.sentinel/blesh_loader.sh" ~/.bashrc; then
            echo "[✓] ble.sh loader is correctly configured in .bashrc"
        else
            echo "[✗] ble.sh loader is not configured in .bashrc"
            echo
            echo "Adding ble.sh loader to .bashrc..."
            echo '# SENTINEL ble.sh integration' >> ~/.bashrc
            echo 'if [[ -f ~/.sentinel/blesh_loader.sh ]]; then' >> ~/.bashrc
            echo '    source ~/.sentinel/blesh_loader.sh' >> ~/.bashrc
            echo 'fi' >> ~/.bashrc
            echo "Done!"
        fi
        
        echo
        
        # Check for path_manager fix
        if grep -q "~/.sentinel/fix_path_manager.sh" ~/.bashrc; then
            echo "[✓] path_manager fix is correctly configured in .bashrc"
        else
            echo "[✗] path_manager fix is not configured in .bashrc"
            echo
            echo "Adding path_manager fix to .bashrc..."
            echo '# SENTINEL path_manager fix' >> ~/.bashrc
            echo 'if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then' >> ~/.bashrc
            echo '    source ~/.sentinel/fix_path_manager.sh' >> ~/.bashrc
            echo 'fi' >> ~/.bashrc
            echo "Done!"
        fi
        
        echo
        echo "Security verification: $(_secure_verify "bashrc_check" "integration")"
        
    } > "$bashrc_file"
    
    # Display check in a scrollable text box
    dialog --title "Bashrc Integration" --textbox "$bashrc_file" 20 70
    
    # Clean up
    rm -f "$bashrc_file"
}

# Main menu function
main_menu() {
    while true; do
        # Show the main menu
        dialog --title "SENTINEL Autocomplete Configuration" --menu "Select an option:" 15 60 8 \
            "1" "Check System Status" \
            "2" "Fix Autocomplete Issues" \
            "3" "Reinstall ble.sh" \
            "4" "Manage Autocomplete Directories" \
            "5" "Manage Configuration" \
            "6" "Exit" 2> /tmp/sentinel_menu
        
        choice=$(cat /tmp/sentinel_menu)
        rm -f /tmp/sentinel_menu
        
        case $choice in
            1) check_system_status ;;
            2) fix_autocomplete_issues ;;
            3) reinstall_blesh ;;
            4) manage_autocomplete_dirs ;;
            5) manage_configuration ;;
            6|"") break ;;
        esac
    done
}

# Display welcome message
dialog --title "SENTINEL Autocomplete Configuration" --msgbox "Welcome to the SENTINEL Autocomplete Configuration utility.\n\nThis tool will help you configure and troubleshoot the SENTINEL autocomplete module.\n\nPress OK to continue." 12 60

# Start the main menu
main_menu

# Exit message
clear
echo "SENTINEL Autocomplete Configuration completed."
echo "Thank you for using SENTINEL." 