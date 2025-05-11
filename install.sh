#!/usr/bin/env bash
# SENTINEL Installation Script - Optimized Version
# Secure ENhanced Terminal INtelligent Layer

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Error handling and logging setup
set -e
TEMP_DIR=$(mktemp -d -t sentinel-XXXXXX)
LOG_FILE="$TEMP_DIR/sentinel_install.log"
exec &> >(tee -a "$LOG_FILE")
trap 'rm -rf $TEMP_DIR 2>/dev/null' EXIT INT TERM

# Banner display
show_banner() {
    echo -e "${BLUE}${BOLD}"
    echo '  ██████ ▓█████  ███▄    █ ▄▄▄█████▓ ██▓ ███▄    █ ▓█████  ██▓    '
    echo '▒██    ▒ ▓█   ▀  ██ ▀█   █ ▓  ██▒ ▓▒▓██▒ ██ ▀█   █ ▓█   ▀ ▓██▒    '
    echo '░ ▓██▄   ▒███   ▓██  ▀█ ██▒▒ ▓██░ ▒░▒██▒▓██  ▀█ ██▒▒███   ▒██░    '
    echo '  ▒   ██▒▒▓█  ▄ ▓██▒  ▐▌██▒░ ▓██▓ ░ ░██░▓██▒  ▐▌██▒▒▓█  ▄ ▒██░    '
    echo '▒██████▒▒░▒████▒▒██░   ▓██░  ▒██▒ ░ ░██░▒██░   ▓██░░▒████▒░██████▒'
    echo '▒ ▒▓▒ ▒ ░░░ ▒░ ░░ ▒░   ▒ ▒   ▒ ░░   ░▓  ░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▓  ░'
    echo '░ ░▒  ░ ░ ░ ░  ░░ ░░   ░ ▒░    ░     ▒ ░░ ░░   ░ ▒░ ░ ░  ░░ ░ ▒  ░'
    echo '░  ░  ░     ░      ░   ░ ░   ░       ▒ ░   ░   ░ ░    ░     ░ ░   '
    echo '      ░     ░  ░         ░           ░           ░    ░  ░    ░  ░'
    echo -e "${NC}"
    echo -e "${BLUE}${BOLD}Secure ENhanced Terminal INtelligent Layer${NC}"
    echo -e "${BLUE}Installation Script - Optimized${NC}"
    echo -e "${BLUE}-----------------------------------${NC}\n"
}

# Pre-installation checks
check_environment() {
    echo -e "${BLUE}${BOLD}Performing pre-installation checks${NC}"
    
    # Check disk space
    if command -v df &>/dev/null; then
        local req_space=100000
        local home_space=$(df -k "${HOME}" | awk 'NR==2 {print $4}')
        if [ -n "$home_space" ] && [ "$home_space" -lt "$req_space" ]; then
            echo -e "${RED}Warning: Low disk space (${home_space}KB available). Required: ${req_space}KB${NC}"
            read -p "$(echo -e "${YELLOW}Continue? [y/N] ${NC}")" response
            [[ "$response" =~ ^[Yy] ]] || { echo -e "${RED}Installation aborted.${NC}"; exit 1; }
        fi
    fi
    
    # Check if running as root
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${RED}Warning: Running as root is not recommended${NC}"
        read -p "$(echo -e "${YELLOW}Continue as root? [y/N] ${NC}")" response
        [[ "$response" =~ ^[Yy] ]] || { echo -e "${GREEN}Please run as a non-root user${NC}"; exit 1; }
    fi
    
    # Check for dependencies
    local missing_deps=()
    if ! command -v jq &>/dev/null; then
        missing_deps+=("jq")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}Missing dependencies: ${missing_deps[*]}${NC}"
        install_dependencies "${missing_deps[@]}"
    fi
}

# Install dependencies based on detected package manager
install_dependencies() {
    local deps=("$@")
    
    if [ ${#deps[@]} -eq 0 ]; then
        return 0
    fi
    
    read -p "$(echo -e "${YELLOW}Install missing dependencies? [Y/n] ${NC}")" response
    [[ "$response" =~ ^[Nn] ]] && return 1
    
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y "${deps[@]}"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "${deps[@]}"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --needed "${deps[@]}"
    else
        echo -e "${RED}Could not detect package manager.${NC}"
        echo -e "${YELLOW}Please install: ${deps[*]} manually.${NC}"
        return 1
    fi
}

# File operations
backup_file() {
    local file="$1"
    if [ -f "${HOME}/${file}" ]; then
        echo -e "${YELLOW}Backing up ${file}${NC}"
        if [ -f "${HOME}/${file}.bak" ]; then
            cp -f "${HOME}/${file}" "${HOME}/${file}.bak.$(date +%Y%m%d%H%M%S)"
        else
            mv "${HOME}/${file}" "${HOME}/${file}.bak"
        fi
        return 0
    fi
    return 1
}

install_file() {
    local source="$1"
    local dest="$2"
    
    if [ -f "./${source}" ]; then
        echo -e "${GREEN}Installing ${source}${NC}"
        cp "./${source}" "${dest}" || return 1
        
        # Set permissions
        if [[ "$source" == *".sh" || "$source" == "bash_modules.d/"* ]]; then
            chmod 700 "${dest}" 2>/dev/null || echo -e "${YELLOW}Warning: Could not set execute permissions${NC}"
        else
            chmod 600 "${dest}" 2>/dev/null || echo -e "${YELLOW}Warning: Could not set permissions${NC}"
        fi
        return 0
    else
        echo -e "${RED}Error: ${source} not found${NC}"
        return 1
    fi
}

create_directory() {
    local dir="$1"
    if [ ! -d "${dir}" ]; then
        echo -e "${GREEN}Creating ${dir}${NC}"
        mkdir -p "${dir}" || return 1
        chmod 0700 "${dir}" 2>/dev/null
    fi
    return 0
}

install_directory_contents() {
    local source="$1"
    local dest="$2"
    
    if [ ! -d "./${source}" ]; then
        echo -e "${YELLOW}Warning: ${source} directory not found, skipping${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Installing files from ${source} to ${dest}${NC}"
    create_directory "${dest}"
    
    # Copy files and set permissions
    find "./${source}" -type f -exec bash -c '
        src="$0"
        dst="$1/$(basename "$src")"
        cp "$src" "$dst" 2>/dev/null
        if [[ "$src" == *.sh || "$(basename "$src")" == *"completion" ]]; then
            chmod 700 "$dst" 2>/dev/null
        else
            chmod 600 "$dst" 2>/dev/null
        fi
    ' {} "${dest}" \;
    
    return 0
}

# Module management
install_module() {
    local module_name="$1"
    local module_content="$2"
    local module_file="${HOME}/.bash_modules.d/${module_name}.module"
    
    echo -e "${GREEN}Installing ${module_name} module...${NC}"
    echo "$module_content" > "$module_file"
    chmod 700 "$module_file"
    
    if ! grep -q "^${module_name}$" "${HOME}/.bash_modules" 2>/dev/null; then
        echo "$module_name" >> "${HOME}/.bash_modules"
    fi
    
    sign_module "$module_name"
}

sign_module() {
    local module_name="$1"
    local module_file="${HOME}/.bash_modules.d/${module_name}.module"
    
    if ! command -v openssl &>/dev/null || [ ! -f "$module_file" ]; then
        return 1
    fi
    
    # Generate/retrieve HMAC key
    local hmac_key_file="${HOME}/.sentinel/hmac_key"
    local hmac_key
    
    if [ ! -f "$hmac_key_file" ]; then
        mkdir -p "${HOME}/.sentinel" 2>/dev/null
        hmac_key=$(openssl rand -hex 32 2>/dev/null || uuidgen 2>/dev/null || date +%s%N)
        echo "$hmac_key" > "$hmac_key_file"
        chmod 600 "$hmac_key_file" 2>/dev/null
    else
        hmac_key=$(cat "$hmac_key_file")
    fi
    
    # Generate HMAC signature
    local hmac=$(openssl dgst -sha256 -hmac "$hmac_key" "$module_file" | cut -d' ' -f2)
    if [ -n "$hmac" ]; then
        echo "$hmac" > "${module_file}.hmac"
        chmod 600 "${module_file}.hmac" 2>/dev/null
        return 0
    fi
    return 1
}

# Python environment setup
setup_python_environment() {
    local VENV_DIR="${HOME}/.sentinel/venv"
    create_directory "$VENV_DIR"
    
    if ! command -v python3 &>/dev/null; then
        echo -e "${YELLOW}Python 3 not found. ML features will be disabled.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Creating Python virtual environment${NC}"
    python3 -m venv "$VENV_DIR" || return 1
    
    # Install basic ML dependencies
    if [ -f "$VENV_DIR/bin/activate" ]; then
        source "$VENV_DIR/bin/activate"
        pip install --upgrade pip >/dev/null 2>&1
        
        if [ -f "./contrib/install_deps.py" ]; then
            python3 ./contrib/install_deps.py --group ml || pip install markovify numpy --user
        else
            pip install markovify numpy --user
        fi
        
        # Update .bashrc.postcustom
        local POSTCUSTOM="${HOME}/.bashrc.postcustom"
        if [ -f "$POSTCUSTOM" ] && ! grep -q "SENTINEL_VENV_DIR" "$POSTCUSTOM"; then
            cat >> "$POSTCUSTOM" << EOF

# SENTINEL Python virtual environment
export SENTINEL_VENV_DIR="$VENV_DIR"
export PATH="\$SENTINEL_VENV_DIR/bin:\$PATH"
alias sentinel-venv="source \$SENTINEL_VENV_DIR/bin/activate"
EOF
        fi
        
        deactivate
        return 0
    fi
    
    return 1
}

# Autocomplete configuration
configure_autocomplete() {
    echo -e "\n${BLUE}${BOLD}Step 7: Configuring Autocomplete System${NC}"
    
    # Define POSTCUSTOM variable
    local POSTCUSTOM="${HOME}/.bashrc.postcustom"
    
    # Check for dialog availability
    local has_dialog=0
    if command -v dialog &>/dev/null; then
        has_dialog=1
    fi
    
    # Determine configuration mode
    local config_mode="basic"
    if [ $has_dialog -eq 1 ]; then
        # Offer configuration options via dialog
        dialog --title "SENTINEL Autocomplete Configuration" --menu "How would you like to configure the autocomplete system?" 15 60 3 \
            "basic" "Basic setup (recommended)" \
            "full" "Full interactive setup" \
            "skip" "Skip autocomplete setup" 2> /tmp/sentinel_config_choice
        
        config_mode=$(cat /tmp/sentinel_config_choice)
        rm -f /tmp/sentinel_config_choice
        
        # Handle empty choice (if user cancels)
        if [ -z "$config_mode" ]; then
            config_mode="basic"
        fi
    fi
    
    # Skip configuration if requested
    if [ "$config_mode" = "skip" ]; then
        echo -e "${YELLOW}Skipping autocomplete configuration.${NC}"
        echo -e "${YELLOW}You can configure it later by running the installation script again.${NC}"
        return 0
    fi
    
    # Create required directories
    for dir in "snippets" "context" "projects" "params"; do
        create_directory "${HOME}/.sentinel/autocomplete/${dir}"
    done
    
    # Create ble.sh loader script
    local blesh_loader="${HOME}/.sentinel/blesh_loader.sh"
    cat > "$blesh_loader" << 'EOF'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader
# This script loads ble.sh with proper error handling

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    # Try the standard loading method first
    source ~/.local/share/blesh/ble.sh 2>/dev/null
    
    # Check if it worked
    if ! type -t ble-bind &>/dev/null; then
        echo "Warning: ble.sh did not load properly. Trying alternative loading method..."
        # Try alternative loading with a different approach
        source <(cat ~/.local/share/blesh/ble.sh) 2>/dev/null
        
        # If still not working, fall back to basic completion
        if ! type -t ble-bind &>/dev/null; then
            echo "Warning: ble.sh could not be loaded. Using basic autocompletion instead."
            # Load bash standard completion as fallback
            [[ -f /etc/bash_completion ]] && source /etc/bash_completion
        fi
    fi
fi
EOF
    chmod 700 "$blesh_loader"
    
    # Create path_manager fix script
    local path_manager="${HOME}/.sentinel/fix_path_manager.sh"
    cat > "$path_manager" << 'EOF'
#!/usr/bin/env bash
# Fix for path_manager.sh loading issues

# Create a simplified version of the PATH management functionality
PATH_CONFIG_FILE="${HOME}/.sentinel_paths"

# Initialize path config file if it doesn't exist
[[ ! -f "${PATH_CONFIG_FILE}" ]] && touch "${PATH_CONFIG_FILE}"

# Load paths from configuration
load_custom_paths() {
    if [[ -f "${PATH_CONFIG_FILE}" ]]; then
        while IFS= read -r path_entry; do
            # Skip comments and empty lines
            [[ -z "${path_entry}" || "${path_entry}" =~ ^# ]] && continue
            
            # Only add if directory exists and isn't already in PATH
            if [[ -d "${path_entry}" && ":${PATH}:" != *":${path_entry}:"* ]]; then
                export PATH="${path_entry}:${PATH}"
            fi
        done < "${PATH_CONFIG_FILE}"
    fi
}

# Load custom paths
load_custom_paths
EOF
    chmod 700 "$path_manager"
    
    # Update .bashrc to include autocomplete components
    local bashrc="${HOME}/.bashrc"
    if [ -f "$bashrc" ] && ! grep -q "~/.sentinel/blesh_loader.sh" "$bashrc"; then
        echo -e "\n# SENTINEL ble.sh integration" >> "$bashrc"
        echo 'if [[ -f ~/.sentinel/blesh_loader.sh ]]; then' >> "$bashrc"
        echo '    source ~/.sentinel/blesh_loader.sh' >> "$bashrc"
        echo 'fi' >> "$bashrc"
    fi
    
    if [ -f "$bashrc" ] && ! grep -q "~/.sentinel/fix_path_manager.sh" "$bashrc"; then
        echo -e "\n# SENTINEL path_manager fix" >> "$bashrc"
        echo 'if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then' >> "$bashrc"
        echo '    source ~/.sentinel/fix_path_manager.sh' >> "$bashrc"
        echo 'fi' >> "$bashrc"
    fi
    
    # Check if ble.sh is installed
    local install_blesh=0
    if [ ! -d "${HOME}/.local/share/blesh" ]; then
        if [ "$config_mode" = "full" ] && [ $has_dialog -eq 1 ]; then
            dialog --title "Install ble.sh" --yesno "ble.sh is not installed.\nWould you like to install it now?" 8 50
            if [ $? -eq 0 ]; then
                install_blesh=1
            fi
        else
            # For basic mode, always try to install
            install_blesh=1
        fi
    fi
    
    # Install ble.sh if needed
    if [ $install_blesh -eq 1 ]; then
        echo -e "${YELLOW}Installing ble.sh...${NC}"
        
        # Create temporary directory
        local tmp_dir="/tmp/blesh_$RANDOM"
        mkdir -p "$tmp_dir"
        
        # Clone repository
        if [ "$config_mode" = "full" ] && [ $has_dialog -eq 1 ]; then
            # Show progress in dialog
            (
                echo "10"; sleep 0.2
                echo "# Cloning ble.sh repository..."
                
                git clone --depth 1 https://github.com/akinomyoga/ble.sh.git "$tmp_dir" 2>/dev/null
                
                echo "50"; sleep 0.2
                echo "# Installing ble.sh..."
                
                make -C "$tmp_dir" install PREFIX=~/.local 2>/dev/null
                
                echo "90"; sleep 0.2
                echo "# Cleaning up..."
                
                rm -rf "$tmp_dir"
                
                echo "100"; sleep 0.5
            ) | dialog --title "Installing ble.sh" --gauge "Please wait..." 10 70 0
        else
            # Standard installation output
            git clone --depth 1 https://github.com/akinomyoga/ble.sh.git "$tmp_dir" 2>/dev/null || {
                echo -e "${RED}Failed to clone ble.sh repository.${NC}"
                echo -e "${YELLOW}You can try again by running the installation script later.${NC}"
            }
            
            # Install if cloned successfully
            if [ -d "$tmp_dir" ]; then
                make -C "$tmp_dir" install PREFIX=~/.local 2>/dev/null || {
                    echo -e "${RED}Failed to install ble.sh.${NC}"
                    echo -e "${YELLOW}You can try again by running the installation script later.${NC}"
                }
                
                # Clean up
                rm -rf "$tmp_dir"
            fi
        fi
    fi
    
    # Additional configurations for full mode
    if [ "$config_mode" = "full" ] && [ $has_dialog -eq 1 ]; then
        # Option to enable secure operations
        dialog --title "Security Configuration" --yesno "Would you like to enable HMAC-based verification for secure operations?" 8 60
        if [ $? -eq 0 ]; then
            # Generate a secure key
            local hmac_key=$(openssl rand -hex 16 2>/dev/null || echo "$(hostname)_$(date +%s)")
            local sentinel_auth_key="${HOME}/.sentinel/auth_key"
            
            mkdir -p "$(dirname "$sentinel_auth_key")" 2>/dev/null
            echo "$hmac_key" > "$sentinel_auth_key"
            chmod 600 "$sentinel_auth_key"
            
            # Add to environment
            if [ -f "$POSTCUSTOM" ] && ! grep -q "SENTINEL_AUTH_KEY" "$POSTCUSTOM"; then
                echo "# Security configuration" >> "$POSTCUSTOM"
                echo "export SENTINEL_AUTH_KEY=\"$hmac_key\"" >> "$POSTCUSTOM"
            fi
        fi
    fi
    
    # Create the fix_autocomplete function in bash_functions.d
    local fix_autocomplete="${HOME}/.bash_functions.d/fix_autocomplete.sh"
    mkdir -p "${HOME}/.bash_functions.d" 2>/dev/null
    
    cat > "$fix_autocomplete" << 'EOF'
#!/usr/bin/env bash
# SENTINEL Autocomplete Fix Function

fix_autocomplete() {
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local NC='\033[0m'

    echo -e "${YELLOW}Fixing autocomplete issues...${NC}"
    
    # Fix permissions
    echo "Setting correct permissions..."
    find ~/.bash_functions.d/ -type f -exec chmod +x {} \; 2>/dev/null
    find ~/.bash_aliases.d/ -type f -exec chmod +x {} \; 2>/dev/null
    find ~/.bash_modules.d/ -type f -exec chmod +x {} \; 2>/dev/null
    find ~/.bash_completion.d/ -type f -exec chmod +x {} \; 2>/dev/null
    
    # Create directories
    echo "Creating required directories..."
    mkdir -p ~/.sentinel/autocomplete/snippets 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/context 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/projects 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/params 2>/dev/null
    
    # Check if ble.sh is installed
    echo "Checking ble.sh installation..."
    if [[ ! -f ~/.local/share/blesh/ble.sh ]]; then
        echo -e "${YELLOW}ble.sh not found. Installing...${NC}"
        
        # Create temporary directory
        local tmp_dir="/tmp/blesh_fix_$RANDOM"
        mkdir -p "$tmp_dir"
        
        # Clone repository
        git clone --depth 1 https://github.com/akinomyoga/ble.sh.git "$tmp_dir" 2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            # Install ble.sh
            make -C "$tmp_dir" install PREFIX=~/.local 2>/dev/null
            
            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN}✓ ble.sh installed successfully${NC}"
            else
                echo -e "${RED}✗ Failed to install ble.sh${NC}"
            fi
            
            # Clean up
            rm -rf "$tmp_dir"
        else
            echo -e "${RED}✗ Failed to clone ble.sh repository${NC}"
        fi
    else
        echo -e "${GREEN}✓ ble.sh is already installed${NC}"
    fi
    
    # Update or create loader scripts
    echo "Creating ble.sh loader script..."
    cat > ~/.sentinel/blesh_loader.sh << 'EOFINNER'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader
# This script loads ble.sh with proper error handling

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    # Try the standard loading method first
    source ~/.local/share/blesh/ble.sh 2>/dev/null
    
    # Check if it worked
    if ! type -t ble-bind &>/dev/null; then
        echo "Warning: ble.sh did not load properly. Trying alternative loading method..."
        # Try alternative loading with a different approach
        source <(cat ~/.local/share/blesh/ble.sh) 2>/dev/null
        
        # If still not working, fall back to basic completion
        if ! type -t ble-bind &>/dev/null; then
            echo "Warning: ble.sh could not be loaded. Using basic autocompletion instead."
            # Load bash standard completion as fallback
            [[ -f /etc/bash_completion ]] && source /etc/bash_completion
        fi
    fi
fi
EOFINNER
    chmod +x ~/.sentinel/blesh_loader.sh
    
    echo "Creating path_manager fix script..."
    cat > ~/.sentinel/fix_path_manager.sh << 'EOFINNER'
#!/usr/bin/env bash
# Fix for path_manager.sh loading issues

# Create a simplified version of the PATH management functionality
PATH_CONFIG_FILE="${HOME}/.sentinel_paths"

# Initialize path config file if it doesn't exist
[[ ! -f "${PATH_CONFIG_FILE}" ]] && touch "${PATH_CONFIG_FILE}"

# Load paths from configuration
load_custom_paths() {
    if [[ -f "${PATH_CONFIG_FILE}" ]]; then
        while IFS= read -r path_entry; do
            # Skip comments and empty lines
            [[ -z "${path_entry}" || "${path_entry}" =~ ^# ]] && continue
            
            # Only add if directory exists and isn't already in PATH
            if [[ -d "${path_entry}" && ":${PATH}:" != *":${path_entry}:"* ]]; then
                export PATH="${path_entry}:${PATH}"
            fi
        done < "${PATH_CONFIG_FILE}"
    fi
}

# Load custom paths
load_custom_paths
EOFINNER
    chmod +x ~/.sentinel/fix_path_manager.sh
    
    # Update .bashrc if needed
    if ! grep -q "~/.sentinel/blesh_loader.sh" ~/.bashrc; then
        echo '# SENTINEL ble.sh integration' >> ~/.bashrc
        echo 'if [[ -f ~/.sentinel/blesh_loader.sh ]]; then' >> ~/.bashrc
        echo '    source ~/.sentinel/blesh_loader.sh' >> ~/.bashrc
        echo 'fi' >> ~/.bashrc
    fi
    
    if ! grep -q "~/.sentinel/fix_path_manager.sh" ~/.bashrc; then
        echo '# SENTINEL path_manager fix' >> ~/.bashrc
        echo 'if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then' >> ~/.bashrc
        echo '    source ~/.sentinel/fix_path_manager.sh' >> ~/.bashrc
        echo 'fi' >> ~/.bashrc
    fi
    
    # Clean up temporary files
    find /tmp -maxdepth 1 -type d -name "blesh*" -exec rm -rf {} \; 2>/dev/null || true
    
    echo -e "${GREEN}✓ Autocomplete fixes have been applied successfully!${NC}"
    echo -e "${YELLOW}Please restart your terminal for changes to take effect, or run:${NC}"
    echo -e "source ~/.sentinel/blesh_loader.sh"
    echo -e "source ~/.sentinel/fix_path_manager.sh"
}
EOF
    chmod 700 "$fix_autocomplete"
    
    # Create an alias for the fix function
    if [ -f "$POSTCUSTOM" ] && ! grep -q "fix_autocomplete" "$POSTCUSTOM"; then
        echo "alias autocomplete_fix='fix_autocomplete'" >> "$POSTCUSTOM"
    fi
    
    echo -e "${GREEN}Autocomplete configuration completed.${NC}"
    echo -e "${YELLOW}For fixing autocomplete issues later, run: autocomplete_fix${NC}"
}

# Main installation function
install_sentinel() {
    show_banner
    check_environment
    
    echo -e "\n${BLUE}${BOLD}Step 1: Backing up existing files${NC}"
    for file in .bashrc .bash_aliases .bash_completion .bash_functions .bash_modules; do
        backup_file "$file"
    done
    
    echo -e "\n${BLUE}${BOLD}Step 2: Installing core files${NC}"
    for file in bashrc bash_aliases bash_functions bash_completion bash_modules; do
        install_file "$file" "${HOME}/.${file}"
    done
    
    echo -e "\n${BLUE}${BOLD}Step 3: Installing custom configurations${NC}"
    for custom in bashrc.precustom bashrc.postcustom; do
        if [ -f "./${custom}" ]; then
            if [ -f "${HOME}/.${custom}" ]; then
                read -p "$(echo -e "${YELLOW}Overwrite ${HOME}/.${custom}? [Y/n] ${NC}")" response
                [[ "$response" =~ ^[Nn] ]] || install_file "$custom" "${HOME}/.${custom}"
            else
                install_file "$custom" "${HOME}/.${custom}"
            fi
        fi
    done
    
    echo -e "\n${BLUE}${BOLD}Step 4: Setting up directory structures${NC}"
    for dir in bash_aliases.d bash_functions.d bash_completion.d bash_modules.d; do
        create_directory "${HOME}/.${dir}"
        install_directory_contents "${dir}" "${HOME}/.${dir}"
    done
    
    echo -e "\n${BLUE}${BOLD}Step 5: Creating required directories${NC}"
    for dir in "${HOME}/.hashcat/wordlists" "${HOME}/.hashcat/cracked" "${HOME}/.sentinel/logs" \
               "${HOME}/secure_workspace/obfuscation" "${HOME}/secure_workspace/crypto" \
               "${HOME}/secure_workspace/malware_analysis" "${HOME}/obfuscated_files" \
               "${HOME}/.sentinel/temp" "${HOME}/.distcc" "${HOME}/.ccache" \
               "${HOME}/build_workspace" "${HOME}/.bash_modules.d/sentchat" \
               "${HOME}/.bash_modules.d/suggestions" "${HOME}/.sentinel/models" \
               "${HOME}/.sentinel/wrappers"; do
        create_directory "$dir"
    done
    
    # Create bookmarks file
    if [ ! -f "${HOME}/.bookmarks" ]; then
        touch "${HOME}/.bookmarks"
        chmod 600 "${HOME}/.bookmarks"
    fi
    
    echo -e "\n${BLUE}${BOLD}Step 6: Installing modules${NC}"
    # Install special modules like obfuscate
    if [ -f "./modules/obfuscate.sh" ]; then
        cp "./modules/obfuscate.sh" "${HOME}/.bash_modules.d/obfuscate.module"
        chmod 700 "${HOME}/.bash_modules.d/obfuscate.module"
        if ! grep -q "^obfuscate$" "${HOME}/.bash_modules" 2>/dev/null; then
            echo "obfuscate" >> "${HOME}/.bash_modules"
        fi
    elif [ -f "./modules/obfuscate.module" ]; then
        cp "./modules/obfuscate.module" "${HOME}/.bash_modules.d/obfuscate.module"
        chmod 700 "${HOME}/.bash_modules.d/obfuscate.module"
        if ! grep -q "^obfuscate$" "${HOME}/.bash_modules" 2>/dev/null; then
            echo "obfuscate" >> "${HOME}/.bash_modules"
        fi
    fi
    
    # Configure environment variables
    if [ -f "$POSTCUSTOM" ]; then
        # Add secure workspace variables
        if ! grep -q "OBFUSCATE_OUTPUT_DIR" "$POSTCUSTOM"; then
            cat >> "$POSTCUSTOM" << EOF

# SENTINEL security workspace configuration
export OBFUSCATE_OUTPUT_DIR="\$HOME/secure_workspace/obfuscation"
export OBFUSCATE_TEMP_DIR="\$HOME/.sentinel/temp"
export SENTINEL_SECURE_DIRS="\$HOME/secure_workspace"
EOF
        fi
        
        # Add distcc configuration
        if ! grep -q "DISTCC_HOSTS" "$POSTCUSTOM"; then
            cat >> "$POSTCUSTOM" << EOF

# SENTINEL build environment configuration
export DISTCC_HOSTS="localhost"
export DISTCC_DIR="\$HOME/.distcc"
export CCACHE_DIR="\$HOME/.ccache"
export CCACHE_SIZE="5G"
export PATH="/usr/lib/ccache/bin:/usr/lib/distcc/bin:\${PATH}"
EOF
        fi
        
        # Add module security configuration
        if ! grep -q "SENTINEL_VERIFY_MODULES" "$POSTCUSTOM"; then
            cat >> "$POSTCUSTOM" << EOF

# Module security configuration
export SENTINEL_VERIFY_MODULES=0         # Enable HMAC verification for modules
export SENTINEL_REQUIRE_HMAC=1           # Require HMAC signatures for all modules
export SENTINEL_CHECK_MODULE_CONTENT=0   # Check modules for suspicious patterns
export SENTINEL_DEBUG_MODULES=0          # Enable debug mode for module loading
# export SENTINEL_HMAC_KEY="random_string" # Custom HMAC key (uncomment and set for better security)
EOF
        fi
    fi
    
    echo -e "\n${BLUE}${BOLD}Step 7: Configuring Autocomplete System${NC}"
    configure_autocomplete
    
    echo -e "\n${BLUE}${BOLD}Step 8: Setting up Python environment${NC}"
    setup_python_environment
    
    # Install ML modules
    if [ -f "./bash_modules.d/sentinel_ml.module" ]; then
        cp "./bash_modules.d/sentinel_ml.module" "${HOME}/.bash_modules.d/sentinel_ml"
        chmod 700 "${HOME}/.bash_modules.d/sentinel_ml"
        if ! grep -q "^sentinel_ml$" "${HOME}/.bash_modules" 2>/dev/null; then
            echo "sentinel_ml" >> "${HOME}/.bash_modules"
        fi
    fi
    
    # Copy module files
    if [ -d "./bash_modules.d/suggestions" ]; then
        cp -r "./bash_modules.d/suggestions/"* "${HOME}/.bash_modules.d/suggestions/" 2>/dev/null
        find "${HOME}/.bash_modules.d/suggestions" -type f -name "*.sh" -o -name "*.module" -exec chmod 700 {} \; 2>/dev/null
    fi
    
    # Copy Python scripts
    for script in "./contrib/sentinel_autolearn.py" "./contrib/sentinel_suggest.py" "./contrib/sentinel_chat.py"; do
        if [ -f "$script" ]; then
            cp "$script" "${HOME}/.sentinel/"
            chmod 700 "${HOME}/.sentinel/$(basename "$script")" 2>/dev/null
        fi
    done
    
    # Install chat module
    if [ -f "./bash_modules.d/sentinel_chat.module" ]; then
        cp "./bash_modules.d/sentinel_chat.module" "${HOME}/.bash_modules.d/sentinel_chat"
        chmod 700 "${HOME}/.bash_modules.d/sentinel_chat"
        if ! grep -q "^sentinel_chat$" "${HOME}/.bash_modules" 2>/dev/null; then
            echo "sentinel_chat" >> "${HOME}/.bash_modules"
        fi
    fi
    
    # Copy sentchat module files
    if [ -d "./bash_modules.d/sentchat" ]; then
        mkdir -p "${HOME}/.sentinel/sentchat"
        
        # Create __init__.py
        cat > "${HOME}/.sentinel/sentchat/__init__.py" << 'EOF'
"""
SENTINEL Chat Module
Provides functionality for the SENTINEL conversational assistant.
"""

__version__ = "1.0.0"
EOF
        
        # Copy files
        cp -r "./bash_modules.d/sentchat/"* "${HOME}/.bash_modules.d/sentchat/" 2>/dev/null
        find "${HOME}/.bash_modules.d/sentchat" -type f -name "*.sh" -o -name "*.module" -exec chmod 700 {} \; 2>/dev/null
        
        # Copy Python files
        for pyfile in "./contrib/sentinel_chat_context.py" "./contrib/sentinel_context.py"; do
            if [ -f "$pyfile" ]; then
                cp "$pyfile" "${HOME}/.sentinel/sentchat/"
            fi
        done
    fi
    
    # Create chat dependencies installer
    cat > "${HOME}/.sentinel/install_chat_deps.sh" << 'EOF'
#!/usr/bin/env bash
# Install chat dependencies in the virtual environment

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

VENV_DIR="${HOME}/.sentinel/venv"
[ ! -f "$VENV_DIR/bin/activate" ] && python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate" || exit 1
pip install --upgrade pip
pip install rich readline || exit 1
pip install llama-cpp-python || CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS" pip install llama-cpp-python || {
    echo -e "${RED}Installation failed. You may need development packages:${NC}"
    echo -e "${YELLOW}  - Debian/Ubuntu: sudo apt install python3-dev build-essential cmake${NC}"
    echo -e "${YELLOW}  - Fedora/RHEL: sudo dnf install python3-devel gcc-c++ cmake${NC}"
    echo -e "${YELLOW}  - Arch: sudo pacman -S python-pip cmake gcc${NC}"
    deactivate
    exit 1
}
deactivate
EOF
    chmod 700 "${HOME}/.sentinel/install_chat_deps.sh"
    
    if [ -f "$POSTCUSTOM" ] && ! grep -q "sentinel_chat_install_deps" "$POSTCUSTOM"; then
        echo "alias sentinel_chat_install_deps=\"${HOME}/.sentinel/install_chat_deps.sh\"" >> "$POSTCUSTOM"
    fi
    
    # Create Python wrappers
    cat > "${HOME}/.sentinel/wrappers/wrapper_template.sh" << 'EOF'
#!/usr/bin/env bash
# Wrapper to run Python scripts within the SENTINEL virtual environment

VENV_DIR="${HOME}/.sentinel/venv"
SCRIPT_PATH="$1"
shift

[ ! -f "$VENV_DIR/bin/activate" ] && python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
python3 "$SCRIPT_PATH" "$@"
EXIT_CODE=$?
deactivate
exit $EXIT_CODE
EOF
    chmod 700 "${HOME}/.sentinel/wrappers/wrapper_template.sh"
    
    # Create specific wrappers
    for script in "sentinel_autolearn.py" "sentinel_suggest.py" "sentinel_chat.py"; do
        if [ -f "${HOME}/.sentinel/$script" ]; then
            script_name=$(basename "$script" .py)
            wrapper="${HOME}/.sentinel/wrappers/${script_name}_wrapper.sh"
            
            cat > "$wrapper" << EOF
#!/usr/bin/env bash
# Wrapper for $script_name

"${HOME}/.sentinel/wrappers/wrapper_template.sh" "${HOME}/.sentinel/$script" "\$@"
EOF
            chmod 700 "$wrapper"
            
            if [ -f "$POSTCUSTOM" ] && ! grep -q "alias ${script_name}=" "$POSTCUSTOM"; then
                echo "alias ${script_name}=\"${wrapper}\"" >> "$POSTCUSTOM"
            fi
        fi
    done
    
    # Create help function
    cat > "${HOME}/.bash_functions.d/sentinel_help.sh" << 'EOF'
#!/usr/bin/env bash
# SENTINEL Help Function

sentinel_help() {
    local BOLD='\033[1m'
    local BLUE='\033[0;34m'
    local YELLOW='\033[0;33m'
    local NC='\033[0m'
    
    cat << HELPTEXT
${BOLD}SENTINEL - Secure ENhanced Terminal INtelligent Layer${NC}

${BLUE}Core Features:${NC}
  secure_rm_toggle        - Toggle secure file deletion on/off
  secure_clean [scope]    - Manually trigger secure cleanup
  secure-logout-config    - View secure logout configuration
  rebash                  - Reload bash configuration
  
${BLUE}Module Management:${NC}
  module_list             - List available modules
  module_enable <name>    - Enable a module
  module_disable <name>   - Disable a module
  module_info <name>      - Show information about a module
  module_sign <name>      - Sign a module with HMAC for verification
  module_debug [on|off]   - Toggle debug mode for module loading
  module_diagnose         - Run diagnostics on the module system
  
${BLUE}Navigation:${NC}
  j [-a|-l|-r <num>|<name>] - Directory jumping tool
  mkcd <dir>              - Create directory and cd into it
  
${BLUE}Security Modules:${NC}
  obfuscate_help          - Show obfuscation module help
  obfuscate_check_tools   - Check for obfuscation tools
  hashdetect <hash>       - Identify hash type
  hashcrack <hash>        - Crack a hash with auto-detection
  
${BLUE}Machine Learning Features:${NC}
  sentinel_suggest <cmd>  - Get ML-powered command suggestions
  sentinel_ml_train       - Retrain ML model with your commands
  sentinel_ml_stats       - Show command frequency statistics
  sentinel_chat           - Interactive AI shell assistant
  
${BLUE}Other Utilities:${NC}
  extract <archive>       - Extract various archive formats
  sysinfo                 - Show system information
  netcheck                - View network connections
  
${YELLOW}Workspace directories:${NC}
  ~/secure_workspace/     - For security-related files
  ~/build_workspace/      - For compilation projects
HELPTEXT
}
EOF
    chmod 700 "${HOME}/.bash_functions.d/sentinel_help.sh"
    
    echo -e "\n${BLUE}${BOLD}Step 9: Signing modules with HMAC${NC}"
    find "${HOME}/.bash_modules.d" -type f -name "*.module" | while read module_file; do
        module_name=$(basename "$module_file" .module)
        sign_module "$module_name"
    done
    
    # Update HMAC key in bashrc.postcustom
    if [ -f "${HOME}/.sentinel/hmac_key" ] && [ -f "$POSTCUSTOM" ]; then
        hmac_key=$(cat "${HOME}/.sentinel/hmac_key")
        sed -i 's/# export SENTINEL_HMAC_KEY="random_string"/export SENTINEL_HMAC_KEY="'"$hmac_key"'"/' "$POSTCUSTOM" 2>/dev/null
    fi
    
    # Verify installation
    echo -e "\n${BLUE}${BOLD}Verifying installation...${NC}"
    local critical_files=(".bashrc" ".bash_aliases" ".bash_functions" ".bash_completion" ".bash_modules" ".sentinel/hmac_key")
    local critical_dirs=(".bash_modules.d" ".sentinel/logs" ".sentinel/temp" ".sentinel/models")
    
    for file in "${critical_files[@]}"; do
        [ -f "${HOME}/${file}" ] && echo "✓ ${HOME}/${file}" || echo "✗ ${HOME}/${file} (MISSING)"
    done
    
    for dir in "${critical_dirs[@]}"; do
        [ -d "${HOME}/${dir}" ] && echo "✓ ${HOME}/${dir}" || echo "✗ ${HOME}/${dir} (MISSING)"
    done
    
    # Store installation log
    mkdir -p "${HOME}/.sentinel/logs" 2>/dev/null
    cp "$LOG_FILE" "${HOME}/.sentinel/logs/install-$(date +%Y%m%d-%H%M%S).log" 2>/dev/null
    
    echo -e "\n${GREEN}${BOLD}Installation completed!${NC}"
    echo -e "To activate SENTINEL, either:"
    echo -e "  1. Start a new terminal session, or"
    echo -e "  2. Run: ${BLUE}source ~/.bashrc${NC}"
    echo -e "\nFor help, type: ${BLUE}sentinel_help${NC} after activation."
    echo -e "For autocomplete configuration, run: ${BLUE}autocomplete_fix${NC}\n"
    
    # Offer to activate configuration right away
    if command -v dialog &>/dev/null; then
        dialog --title "SENTINEL Installation" --yesno "Would you like to activate the configuration now?" 8 60
        if [ $? -eq 0 ]; then
            source ~/.bashrc
            fix_autocomplete
        fi
    else
        read -p "$(echo -e "${YELLOW}Would you like to activate the configuration now? [y/N] ${NC}")" response
        if [[ "$response" =~ ^[Yy] ]]; then
            source ~/.bashrc
            fix_autocomplete
        fi
    fi
}

# Execute the main installation
install_sentinel