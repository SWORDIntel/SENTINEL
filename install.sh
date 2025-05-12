#!/usr/bin/env bash
# SENTINEL Installation Script
# Version: 2.0
# This script installs the SENTINEL bash modules, aliases, and functions

# Set strict error handling
set -o pipefail

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}"
echo "███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗      "
echo "██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║      "
echo "███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║      "
echo "╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║      "
echo "███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗ "
echo "╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝ "
echo -e "${NC}"
echo -e "${GREEN}Installation Script${NC}"
echo

# Get the directory of the script (parent directory of SENTINEL)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if script is run from correct location
if [[ ! -f "${SCRIPT_DIR}/bashrc" ]]; then
    echo -e "${RED}Error: This script must be run from the SENTINEL directory.${NC}"
    exit 1
fi

# Check if .bashrc exists
if [[ ! -f "${HOME}/.bashrc" ]]; then
    echo -e "${RED}Error: ~/.bashrc not found. Creating an empty one.${NC}"
    touch "${HOME}/.bashrc"
fi

# Create necessary directories
echo -e "${BLUE}Creating directories...${NC}"

# Create .sentinel directory structure
SENTINEL_CONFIG_DIR="${HOME}/.sentinel"
if [[ ! -d "$SENTINEL_CONFIG_DIR" ]]; then
    mkdir -p "${SENTINEL_CONFIG_DIR}"
    mkdir -p "${SENTINEL_CONFIG_DIR}/logs"
    mkdir -p "${SENTINEL_CONFIG_DIR}/backups"
    mkdir -p "${SENTINEL_CONFIG_DIR}/cache"
    mkdir -p "${SENTINEL_CONFIG_DIR}/autocomplete"
    
    # Set secure permissions
    chmod 700 "${SENTINEL_CONFIG_DIR}"
    chmod 700 "${SENTINEL_CONFIG_DIR}/logs"
    chmod 700 "${SENTINEL_CONFIG_DIR}/backups"
    chmod 700 "${SENTINEL_CONFIG_DIR}/cache"
    chmod 700 "${SENTINEL_CONFIG_DIR}/autocomplete"
    
    echo -e "${GREEN}✓ Created .sentinel directory structure${NC}"
else
    echo -e "${YELLOW}⚠ .sentinel directory already exists${NC}"
fi

# Create configuration file
CONFIG_FILE="${SENTINEL_CONFIG_DIR}/sentinel_config.sh"
if [[ ! -f "$CONFIG_FILE" ]]; then
    # Source config_loader to create default config
    if [[ -f "${SCRIPT_DIR}/bash_modules.d/config_loader.module" ]]; then
        source "${SCRIPT_DIR}/bash_modules.d/config_loader.module"
    elif [[ -f "${SCRIPT_DIR}/bash_modules.d/suggestions/config_loader.module" ]]; then
        # Fallback to old location for backward compatibility
        source "${SCRIPT_DIR}/bash_modules.d/suggestions/config_loader.module"
    else
        echo "Error: Could not find config_loader.module"
        exit 1
    fi
    echo -e "${GREEN}✓ Created default configuration file${NC}"
else
    echo -e "${YELLOW}⚠ Configuration file already exists${NC}"
fi

# Ensure lazy loading is enabled in config
if [[ -f "$CONFIG_FILE" ]]; then
    echo -e "${BLUE}Updating configuration settings...${NC}"
    
    # Enable lazy loading in the configuration file
    if grep -q "U_LAZY_LOAD=" "$CONFIG_FILE"; then
        sed -i 's/U_LAZY_LOAD=0/U_LAZY_LOAD=1/g' "$CONFIG_FILE"
        echo -e "${GREEN}✓ Updated: Lazy loading enabled in configuration${NC}"
    else
        echo 'export U_LAZY_LOAD=1' >> "$CONFIG_FILE"
        echo -e "${GREEN}✓ Added: Lazy loading setting to configuration${NC}"
    fi
fi

# Fix configuration file duplication issue
echo -e "${BLUE}Checking for duplicate configuration files...${NC}"
SECONDARY_CONFIG="${SCRIPT_DIR}/bash_modules.d/sentinel_config.sh"

if [[ -f "$SECONDARY_CONFIG" && -f "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}⚠ Secondary configuration file detected${NC}"
    
    # Backup the secondary config
    BACKUP_FILE="${SECONDARY_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$SECONDARY_CONFIG" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backed up: ${SECONDARY_CONFIG} → ${BACKUP_FILE}${NC}"
    
    # Remove the file and create a symlink to maintain centralized configuration
    rm -f "$SECONDARY_CONFIG"
    ln -sf "$CONFIG_FILE" "$SECONDARY_CONFIG"
    echo -e "${GREEN}✓ Created symlink: ${SECONDARY_CONFIG} → ${CONFIG_FILE}${NC}"
fi

# Create the link files (symbolic links in home directory)
create_link() {
    local source_file="$1"
    local target_link="$2"
    local backup=true
    
    # Check if the third parameter is provided and is "false"
    if [[ -n "$3" && "$3" == "false" ]]; then
        backup=false
    fi
    
    # If the target link already exists as a regular file, back it up
    if [[ -f "$target_link" && ! -L "$target_link" && "$backup" == true ]]; then
        local timestamp=$(date +%Y%m%d%H%M%S)
        local backup_file="${target_link}.bak.${timestamp}"
        echo -e "${YELLOW}⚠ Backing up existing file: ${target_link} → ${backup_file}${NC}"
        mv "$target_link" "$backup_file"
    fi
    
    # If the target link already exists as a symbolic link, remove it
    if [[ -L "$target_link" ]]; then
        rm "$target_link"
    fi
    
    # Create the symbolic link
    ln -sf "$source_file" "$target_link"
    echo -e "${GREEN}✓ Created link: ${source_file} → ${target_link}${NC}"
}

echo -e "${BLUE}Creating links...${NC}"
create_link "${SCRIPT_DIR}/bashrc" "${HOME}/.bashrc.sentinel"
create_link "${SCRIPT_DIR}/bash_aliases" "${HOME}/.bash_aliases.sentinel"
create_link "${SCRIPT_DIR}/bash_functions" "${HOME}/.bash_functions.sentinel"
create_link "${SCRIPT_DIR}/bash_completion" "${HOME}/.bash_completion.sentinel"
create_link "${SCRIPT_DIR}/bash_modules" "${HOME}/.bash_modules.sentinel"

# Create subdirectory links to preserve module structure
echo -e "${BLUE}Creating module directory structure...${NC}"
mkdir -p "${HOME}/.bash_modules.d"

# Function to copy or link module subdirectories
setup_modules_dir() {
    local source_dir="$1"
    local target_dir="$2"
    
    # Create the target directory if it doesn't exist
    mkdir -p "$target_dir"
    
    # Link subdirectories from source to target
    for dir in "$source_dir"/*; do
        if [[ -d "$dir" ]]; then
            local dir_name=$(basename "$dir")
            local target_subdir="$target_dir/$dir_name"
            
            # If target subdirectory doesn't exist, create it
            if [[ ! -d "$target_subdir" ]]; then
                mkdir -p "$target_subdir"
                echo -e "${GREEN}✓ Created module subdirectory: $target_subdir${NC}"
            fi
            
            # Copy module files from subdirectory
            for module_file in "$dir"/*.module "$dir"/*.sh; do
                if [[ -f "$module_file" ]]; then
                    local file_name=$(basename "$module_file")
                    cp -f "$module_file" "$target_subdir/$file_name"
                    chmod +x "$target_subdir/$file_name"
                    echo -e "${GREEN}✓ Installed module: $file_name in $target_subdir${NC}"
                fi
            done
        fi
    done
}

# Setup module directories
setup_modules_dir "${SCRIPT_DIR}/bash_modules.d" "${HOME}/.bash_modules.d"

# Function to check if a line exists in a file
line_exists() {
    local line="$1"
    local file="$2"
    grep -qF "$line" "$file"
}

# Function to add line to file if it doesn't exist
add_line_if_not_exists() {
    local line="$1"
    local file="$2"
    if ! line_exists "$line" "$file"; then
        echo "$line" >> "$file"
        echo -e "${GREEN}✓ Added: ${line} → ${file}${NC}"
    else
        echo -e "${YELLOW}⚠ Line already exists in ${file}${NC}"
    fi
}

# Add source lines to .bashrc
echo -e "${BLUE}Updating .bashrc...${NC}"

# Lines to add to .bashrc
BASHRC_LINES=(
    "# SENTINEL Integration - DO NOT MODIFY THIS SECTION"
    "if [[ -f ~/.bashrc.sentinel ]]; then"
    "    source ~/.bashrc.sentinel"
    "fi"
    "# End of SENTINEL Integration"
)

# Check if SENTINEL integration already exists
if grep -q "SENTINEL Integration" "${HOME}/.bashrc"; then
    echo -e "${YELLOW}⚠ SENTINEL integration already exists in .bashrc${NC}"
else
    # Add an empty line if .bashrc doesn't end with one
    if [[ -s "${HOME}/.bashrc" ]] && [[ $(tail -c 1 "${HOME}/.bashrc" | wc -l) -eq 0 ]]; then
        echo "" >> "${HOME}/.bashrc"
    fi
    
    # Add the integration lines
    for line in "${BASHRC_LINES[@]}"; do
        echo "$line" >> "${HOME}/.bashrc"
    done
    echo -e "${GREEN}✓ Added SENTINEL integration to .bashrc${NC}"
fi

# Create or append to .bashrc.postcustom
if [[ ! -f "${SCRIPT_DIR}/bashrc.postcustom" ]]; then
    cat > "${SCRIPT_DIR}/bashrc.postcustom" << EOL
#!/usr/bin/env bash
# SENTINEL Post-Custom Configuration
# This file is loaded at the end of .bashrc.sentinel
# Add your custom configurations here

# Source centralized configuration
if [[ -f \$HOME/.sentinel/sentinel_config.sh ]]; then
    source \$HOME/.sentinel/sentinel_config.sh
fi

# Add your customizations below this line
# Example: export SENTINEL_CYBERSEC_ENABLED=0  # Disable cybersecurity module

EOL
    echo -e "${GREEN}✓ Created bashrc.postcustom with default content${NC}"
else
    # Check if centralized config sourcing exists, add if not
    if ! grep -q "source \$HOME/.sentinel/sentinel_config.sh" "${SCRIPT_DIR}/bashrc.postcustom"; then
        # Create a temporary file
        TEMP_FILE=$(mktemp)
        
        # Add sourcing at the top of the file
        cat > "$TEMP_FILE" << EOL
#!/usr/bin/env bash
# SENTINEL Post-Custom Configuration
# This file is loaded at the end of .bashrc.sentinel
# Add your custom configurations here

# Source centralized configuration
if [[ -f \$HOME/.sentinel/sentinel_config.sh ]]; then
    source \$HOME/.sentinel/sentinel_config.sh
fi

EOL
        
        # Append the existing content
        cat "${SCRIPT_DIR}/bashrc.postcustom" >> "$TEMP_FILE"
        
        # Replace the original file
        mv "$TEMP_FILE" "${SCRIPT_DIR}/bashrc.postcustom"
        echo -e "${GREEN}✓ Updated bashrc.postcustom to source centralized configuration${NC}"
    else
        echo -e "${YELLOW}⚠ bashrc.postcustom already sources centralized configuration${NC}"
    fi
fi

# Create precustom file if it doesn't exist
if [[ ! -f "${SCRIPT_DIR}/bashrc.precustom" ]]; then
    cat > "${SCRIPT_DIR}/bashrc.precustom" << EOL
#!/usr/bin/env bash
# SENTINEL Pre-Custom Configuration
# This file is loaded at the beginning of .bashrc.sentinel
# Add your custom pre-configurations here

EOL
    echo -e "${GREEN}✓ Created bashrc.precustom with default content${NC}"
fi

# Make sure all scripts are executable
echo -e "${BLUE}Setting permissions...${NC}"
chmod +x "${SCRIPT_DIR}/bash_aliases"
chmod +x "${SCRIPT_DIR}/bash_functions"
chmod +x "${SCRIPT_DIR}/bash_completion"
chmod +x "${SCRIPT_DIR}/bash_modules"
chmod +x "${SCRIPT_DIR}/bashrc"
if [[ -f "${SCRIPT_DIR}/bashrc.postcustom" ]]; then
    chmod +x "${SCRIPT_DIR}/bashrc.postcustom"
fi
if [[ -f "${SCRIPT_DIR}/bashrc.precustom" ]]; then
    chmod +x "${SCRIPT_DIR}/bashrc.precustom"
fi
echo -e "${GREEN}✓ Set executable permissions${NC}"

# Copy config_helper to ~/.sentinel for easier access
if [[ -f "${SCRIPT_DIR}/bash_modules.d/sentinel_config_helper.sh" ]]; then
    cp "${SCRIPT_DIR}/bash_modules.d/sentinel_config_helper.sh" "${SENTINEL_CONFIG_DIR}/sentinel_config_helper.sh"
elif [[ -f "${SCRIPT_DIR}/bash_modules.d/suggestions/sentinel_config_helper.sh" ]]; then
    # Fallback to old location for backward compatibility
    cp "${SCRIPT_DIR}/bash_modules.d/suggestions/sentinel_config_helper.sh" "${SENTINEL_CONFIG_DIR}/sentinel_config_helper.sh" 
fi

# Set up BLE.sh loader
echo -e "${BLUE}Setting up BLE.sh loader...${NC}"
BLE_LOADER="${SENTINEL_CONFIG_DIR}/blesh_loader.sh"

# Create the loader with improved reliability
cat > "$BLE_LOADER" << 'EOL'
#!/usr/bin/env bash
# SENTINEL BLE.sh integration loader
# Version: 3.0
# This script loads the BLE.sh (Bash Line Editor) with robust error handling

# Set strict error handling
set -o pipefail

# Define logging functions
_blesh_log() {
    local level="$1"
    local message="$2"
    echo "[BLE.sh $level] $message"
}

_blesh_debug() {
    [[ "${SENTINEL_BLESH_DEBUG:-0}" == "1" ]] && _blesh_log "DEBUG" "$1"
}

_blesh_info() {
    _blesh_log "INFO" "$1"
}

_blesh_warn() {
    _blesh_log "WARN" "$1" >&2
}

_blesh_error() {
    _blesh_log "ERROR" "$1" >&2
}

# Clean up BLE.sh cache and lock files
_blesh_cleanup() {
    _blesh_debug "Running cleanup routine"
    
    if [[ -d "${HOME}/.cache/blesh" ]]; then
        # Fix permissions
        chmod -R 755 "${HOME}/.cache/blesh" 2>/dev/null
        
        # Remove lock files
        find "${HOME}/.cache/blesh" -name "*.lock" -type f -delete 2>/dev/null
        
        # Remove incomplete download files
        find "${HOME}/.cache/blesh" -name "*.part" -type f -delete 2>/dev/null
        
        # Remove any problematic cache files
        find "${HOME}/.cache/blesh" -name "decode.readline.*.txt*" -type f -delete 2>/dev/null
    fi
}

# BLE.sh loading methods
_blesh_load_direct() {
    _blesh_debug "Attempting direct source method"
    # Direct source method
    if source "${HOME}/.local/share/blesh/ble.sh" 2>/dev/null; then
        _blesh_debug "Direct source successful"
        return 0
    fi
    return 1
}

_blesh_load_cat() {
    _blesh_debug "Attempting cat source method"
    # Use cat to avoid issues with shell interpolation
    if source <(cat "${HOME}/.local/share/blesh/ble.sh") 2>/dev/null; then
        _blesh_debug "Cat source successful"
        return 0
    fi
    return 1
}

_blesh_load_eval() {
    _blesh_debug "Attempting eval method"
    # Last resort method using eval
    if eval "$(cat "${HOME}/.local/share/blesh/ble.sh")" 2>/dev/null; then
        _blesh_debug "Eval method successful"
        return 0
    fi
    return 1
}

# Install BLE.sh if permitted and not found
_blesh_install() {
    _blesh_info "BLE.sh not found. Attempting installation..."
    
    # Check if we have git and installation is allowed
    if command -v git >/dev/null && [[ "${SENTINEL_BLESH_AUTO_INSTALL:-1}" == "1" ]]; then
        local temp_dir="/tmp/blesh_install_$(date +%s)"
        mkdir -p "${HOME}/.local/share"
        
        # Clone the repository
        if git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git "$temp_dir"; then
            # Run the make install
            if (cd "$temp_dir" && make install PREFIX="${HOME}/.local"); then
                rm -rf "$temp_dir"
                _blesh_info "BLE.sh installed successfully"
                return 0
            else
                _blesh_error "Make installation failed"
                rm -rf "$temp_dir"
                return 1
            fi
        else
            _blesh_error "Failed to clone BLE.sh repository"
            return 1
        fi
    else
        _blesh_warn "Automatic installation disabled or git not available"
        _blesh_info "Install manually with: git clone --recursive https://github.com/akinomyoga/ble.sh.git ~/.local/share/blesh"
        return 1
    fi
}

# Configure BLE.sh settings
_blesh_configure() {
    _blesh_debug "Configuring BLE.sh settings"
    
    # Core settings
    bleopt complete_auto_delay=100
    bleopt complete_auto_complete=1
    bleopt complete_menu_complete=1
    
    # Appearance
    bleopt highlight_auto_completion='fg=242'
    bleopt highlight_syntax='true'
    
    # Key bindings
    ble-bind -m auto_complete -f right 'auto_complete/accept-line'
    
    # History settings
    bleopt history_share=1
    
    _blesh_debug "Configuration complete"
    return 0
}

# Main BLE.sh loader function
load_blesh() {
    # Run cleanup first
    _blesh_cleanup
    
    # Check if BLE.sh exists
    if [[ -f "${HOME}/.local/share/blesh/ble.sh" ]]; then
        _blesh_debug "Found BLE.sh installation"
        
        # Try all loading methods
        if _blesh_load_direct || _blesh_load_cat || _blesh_load_eval; then
            _blesh_info "BLE.sh loaded successfully"
            _blesh_configure
            return 0
        else
            _blesh_error "All loading methods failed"
            return 1
        fi
    else
        # Try to install
        if _blesh_install; then
            # Try loading after installation
            if _blesh_load_direct || _blesh_load_cat || _blesh_load_eval; then
                _blesh_info "BLE.sh loaded successfully after installation"
                _blesh_configure
                return 0
            else
                _blesh_error "Failed to load after installation"
                return 1
            fi
        else
            _blesh_error "BLE.sh not found and installation failed"
            return 1
        fi
    fi
}

# Only attempt to load if enabled in configuration
if [[ "${SENTINEL_BLESH_ENABLED:-1}" == "1" ]]; then
    # Attempt to load BLE.sh
    if ! load_blesh; then
        _blesh_warn "Falling back to standard bash completion"
        [[ -f /etc/bash_completion ]] && source /etc/bash_completion
    fi
else
    _blesh_info "BLE.sh loading disabled in configuration"
    _blesh_info "Enable with: export SENTINEL_BLESH_ENABLED=1"
    [[ -f /etc/bash_completion ]] && source /etc/bash_completion
fi
EOL

chmod +x "$BLE_LOADER"
echo -e "${GREEN}✓ Created improved BLE.sh loader${NC}"

# Add BLE.sh loader to bashrc.postcustom if not already there
if ! grep -q "# Load BLE\.sh" "${SCRIPT_DIR}/bashrc.postcustom"; then
    cat >> "${SCRIPT_DIR}/bashrc.postcustom" << 'EOL'

# Load BLE.sh if available
if [[ -f "${HOME}/.sentinel/blesh_loader.sh" ]]; then
    source "${HOME}/.sentinel/blesh_loader.sh"
fi
EOL
    echo -e "${GREEN}✓ Added BLE.sh loader to bashrc.postcustom${NC}"
fi

# Add lazy loading configuration for development tools if not already there
if ! grep -q "Lazy loading for development tools" "${SCRIPT_DIR}/bashrc.postcustom"; then
    cat >> "${SCRIPT_DIR}/bashrc.postcustom" << 'EOL'

# Lazy loading for development tools
if [[ "${CONFIG[LAZY_LOAD]}" == "1" || "$U_LAZY_LOAD" == "1" ]]; then
    # Lazy load pyenv if installed
    function pyenv() {
        unset -f pyenv
        if [[ -d "$HOME/.pyenv" ]]; then
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(command pyenv init -)"
            eval "$(command pyenv virtualenv-init -)"
            pyenv "$@"
        else
            echo "pyenv is not installed"
            return 1
        fi
    }
    
    # Lazy load NVM if installed
    function nvm() {
        unset -f nvm
        if [[ -d "$HOME/.nvm" ]]; then
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
            [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
            nvm "$@"
        else
            echo "nvm is not installed"
            return 1
        fi
    }
    
    # Add shortcuts for common commands to trigger lazy loading
    function node() {
        unset -f node
        nvm >/dev/null 2>&1
        node "$@"
    }
    
    function npm() {
        unset -f npm
        nvm >/dev/null 2>&1
        npm "$@"
    }
    
    function python() {
        unset -f python
        pyenv >/dev/null 2>&1
        python "$@"
    }
    
    function pip() {
        unset -f pip
        pyenv >/dev/null 2>&1
        pip "$@"
    }
fi
EOL
    echo -e "${GREEN}✓ Added development environment lazy loading to bashrc.postcustom${NC}"
fi

# Copy README_CONFIG.md to ~/.sentinel for documentation
if [[ -f "${SCRIPT_DIR}/bash_modules.d/README_CONFIG.md" ]]; then
    cp "${SCRIPT_DIR}/bash_modules.d/README_CONFIG.md" "${SENTINEL_CONFIG_DIR}/README_CONFIG.md"
elif [[ -f "${SCRIPT_DIR}/bash_modules.d/suggestions/README_CONFIG.md" ]]; then
    # Fallback to old location for backward compatibility
    cp "${SCRIPT_DIR}/bash_modules.d/suggestions/README_CONFIG.md" "${SENTINEL_CONFIG_DIR}/README_CONFIG.md"
fi

# Add configuration helper command for user convenience
if ! line_exists "alias sentinel-config='~/.sentinel/sentinel_config_helper.sh'" "${SCRIPT_DIR}/bash_aliases"; then
    echo "alias sentinel-config='~/.sentinel/sentinel_config_helper.sh'" >> "${SCRIPT_DIR}/bash_aliases"
    echo -e "${GREEN}✓ Added sentinel-config alias${NC}"
fi

# Run configuration migration if needed
echo -e "${BLUE}Checking for configuration to migrate...${NC}"
if [[ -f "${SCRIPT_DIR}/bash_modules.d/migrate_config.sh" ]]; then
    echo -e "${YELLOW}Would you like to run the configuration migration tool? (y/n)${NC}"
    read -r choice
    if [[ "$choice" == "y" ]]; then
        bash "${SCRIPT_DIR}/bash_modules.d/migrate_config.sh"
        echo -e "${GREEN}✓ Configuration migration completed${NC}"
    else
        echo -e "${YELLOW}Skipping configuration migration${NC}"
        echo -e "You can run it later with: bash ${SCRIPT_DIR}/bash_modules.d/migrate_config.sh"
    fi
elif [[ -f "${SCRIPT_DIR}/bash_modules.d/suggestions/migrate_config.sh" ]]; then
    # Fallback to old location for backward compatibility
    echo -e "${YELLOW}Would you like to run the configuration migration tool? (y/n)${NC}"
    read -r choice
    if [[ "$choice" == "y" ]]; then
        echo -e "${YELLOW}Running migration script...${NC}"
        bash "${SCRIPT_DIR}/bash_modules.d/suggestions/migrate_config.sh"
        echo -e "${GREEN}✓ Configuration migration completed${NC}"
    else
        echo -e "${YELLOW}Skipping configuration migration${NC}"
        echo -e "You can run it later with: bash ${SCRIPT_DIR}/bash_modules.d/suggestions/migrate_config.sh"
    fi
else
    echo -e "${YELLOW}⚠ Configuration migration tool not found${NC}"
fi

echo
echo -e "${GREEN}SENTINEL has been installed successfully!${NC}"
echo -e "${YELLOW}To activate SENTINEL, please restart your terminal or run:${NC}"
echo -e "${BLUE}source ~/.bashrc${NC}"
echo 
echo -e "${YELLOW}The configuration system has been set up at:${NC}"
echo -e "${BLUE}~/.sentinel/sentinel_config.sh${NC}"
echo 
echo -e "${YELLOW}You can configure SENTINEL with:${NC}"
echo -e "${BLUE}sentinel-config${NC}"
echo