#!/usr/bin/env bash
# SENTINEL Secure Logout Module
# Provides configuration for the secure automatic logout cleanup

# Check if we're being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced, not executed directly."
    exit 1
fi

# Default configuration values - can be overridden in .bashrc.postcustom

# Clean bash history on logout
export SENTINEL_SECURE_BASH_HISTORY="${SENTINEL_SECURE_BASH_HISTORY:-1}"

# Clean SSH known hosts on logout (be careful with this one!)
export SENTINEL_SECURE_SSH_KNOWN_HOSTS="${SENTINEL_SECURE_SSH_KNOWN_HOSTS:-0}"

# Clean cache directory on logout
export SENTINEL_SECURE_CLEAN_CACHE="${SENTINEL_SECURE_CLEAN_CACHE:-1}"

# Clean browser cookies/cache on logout
export SENTINEL_SECURE_BROWSER_CACHE="${SENTINEL_SECURE_BROWSER_CACHE:-0}"

# Clean recently used files list on logout
export SENTINEL_SECURE_RECENT="${SENTINEL_SECURE_RECENT:-1}"

# Clean Vim undo history on logout
export SENTINEL_SECURE_VIM_UNDO="${SENTINEL_SECURE_VIM_UNDO:-1}"

# Clear clipboard on logout
export SENTINEL_SECURE_CLIPBOARD="${SENTINEL_SECURE_CLIPBOARD:-1}"

# Clear screen on logout for privacy
export SENTINEL_SECURE_CLEAR_SCREEN="${SENTINEL_SECURE_CLEAR_SCREEN:-1}"

# Special directories to clean, colon-separated (optional)
export SENTINEL_SECURE_DIRS="${SENTINEL_SECURE_DIRS:-}"

# Workspace temp directory to clean
export SENTINEL_WORKSPACE_TEMP="${SENTINEL_WORKSPACE_TEMP:-}"

# Function to show current configuration
secure_logout_config() {
    cat << EOF
SENTINEL Secure Logout Configuration
===================================

The following items will be securely deleted on logout:

$([ "${SENTINEL_SECURE_BASH_HISTORY}" == "1" ] && echo "✓" || echo "✗") Bash history
$([ "${SENTINEL_SECURE_SSH_KNOWN_HOSTS}" == "1" ] && echo "✓" || echo "✗") SSH known hosts
$([ "${SENTINEL_SECURE_CLEAN_CACHE}" == "1" ] && echo "✓" || echo "✗") Cache directory
$([ "${SENTINEL_SECURE_BROWSER_CACHE}" == "1" ] && echo "✓" || echo "✗") Browser cache/cookies
$([ "${SENTINEL_SECURE_RECENT}" == "1" ] && echo "✓" || echo "✗") Recently used files list
$([ "${SENTINEL_SECURE_VIM_UNDO}" == "1" ] && echo "✓" || echo "✗") Vim undo history
$([ "${SENTINEL_SECURE_CLIPBOARD}" == "1" ] && echo "✓" || echo "✗") Clipboard contents
$([ "${SENTINEL_SECURE_CLEAR_SCREEN}" == "1" ] && echo "✓" || echo "✗") Clear screen on exit

Additional directories:
${SENTINEL_SECURE_DIRS:-(none)}

Workspace temp directory:
${SENTINEL_WORKSPACE_TEMP:-(none)}

To change these settings, edit your ~/.bashrc.postcustom file
or use the secure_logout_set function.
EOF
}

# Function to update a configuration option
secure_logout_set() {
    local option="$1"
    local value="$2"
    
    if [[ -z "$option" || -z "$value" ]]; then
        echo "Usage: secure_logout_set OPTION VALUE"
        echo "Example: secure_logout_set SENTINEL_SECURE_BROWSER_CACHE 1"
        return 1
    fi
    
    # Validate the option name
    if [[ ! "$option" =~ ^SENTINEL_SECURE_ ]]; then
        echo "Invalid option: $option"
        echo "Options should start with SENTINEL_SECURE_"
        return 1
    fi
    
    # Create or update the option in .bashrc.postcustom
    if [[ -f ~/.bashrc.postcustom ]]; then
        if grep -q "^export $option=" ~/.bashrc.postcustom; then
            # Update existing option
            sed -i "s/^export $option=.*$/export $option=\"$value\"/" ~/.bashrc.postcustom
        else
            # Add new option
            echo "export $option=\"$value\"" >> ~/.bashrc.postcustom
        fi
    else
        # Create .bashrc.postcustom if it doesn't exist
        echo "#!/usr/bin/env bash" > ~/.bashrc.postcustom
        echo "# SENTINEL custom configuration" >> ~/.bashrc.postcustom
        echo "export $option=\"$value\"" >> ~/.bashrc.postcustom
    fi
    
    # Update the current session
    export "$option"="$value"
    
    echo "Updated $option to $value"
    echo "Changes will take effect immediately and persist across sessions."
}

# Function to add a directory to secure cleanup list
secure_logout_add_dir() {
    local dir="$1"
    
    if [[ -z "$dir" ]]; then
        echo "Usage: secure_logout_add_dir DIRECTORY"
        return 1
    fi
    
    # Resolve to absolute path
    dir=$(readlink -f "$dir")
    
    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist: $dir"
        return 1
    fi
    
    # Add to secure dirs
    if [[ -z "$SENTINEL_SECURE_DIRS" ]]; then
        secure_logout_set "SENTINEL_SECURE_DIRS" "$dir"
    else
        # Check if already in list
        if [[ ":$SENTINEL_SECURE_DIRS:" == *":$dir:"* ]]; then
            echo "Directory already in secure cleanup list: $dir"
            return 0
        fi
        
        secure_logout_set "SENTINEL_SECURE_DIRS" "$SENTINEL_SECURE_DIRS:$dir"
    fi
    
    echo "Added $dir to secure cleanup list"
}

# Add aliases for convenience
alias secure-logout-config='secure_logout_config'
alias secure-logout-set='secure_logout_set'
alias secure-logout-add-dir='secure_logout_add_dir'

# Display initial message
echo -e "${GREEN}[+]${NC} Secure logout module loaded. Type 'secure-logout-config' for details."