#!/usr/bin/env bash
# SENTINEL Installation Script
# Secure ENhanced Terminal INtelligent Layer
#
# Based on original work, enhanced for the SENTINEL framework
# Last Update: 2023-08-14

# Set text color variables
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Perform initial checks
echo -e "${BLUE}${BOLD}Performing pre-installation checks${NC}"

# Check available disk space
check_disk_space() {
    local req_space=100000  # Required space in KB (100MB)
    local home_space
    
    if command -v df &>/dev/null; then
        home_space=$(df -k "${HOME}" | awk 'NR==2 {print $4}')
        if [ -n "$home_space" ] && [ "$home_space" -lt "$req_space" ]; then
            echo -e "${RED}Warning: Low disk space detected (${home_space}KB available)${NC}"
            echo -e "${YELLOW}The installation requires at least ${req_space}KB (100MB) of free space${NC}"
            echo -e "${YELLOW}Continue anyway? This may cause issues during installation.${NC}"
            read -p "$(echo -e "${YELLOW}Continue? [y/N] ${NC}")" continue_install
            case "$continue_install" in
                'Y'|'y'|'yes')
                    echo -e "${YELLOW}Continuing installation despite low disk space${NC}"
                    ;;
                *)
                    echo -e "${RED}Installation aborted due to insufficient disk space${NC}"
                    exit 1
                    ;;
            esac
        fi
    else
        echo -e "${YELLOW}Unable to check disk space - 'df' command not found${NC}"
        echo -e "${YELLOW}Continuing anyway, but installation may fail if disk space is insufficient${NC}"
    fi
}

# Check if running as root (not recommended)
check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${RED}Warning: Running this script as root is not recommended${NC}"
        echo -e "${YELLOW}The script will modify files in your home directory${NC}"
        echo -e "${YELLOW}It's better to run it as a regular user${NC}"
        echo -e "${YELLOW}Continue anyway?${NC}"
        read -p "$(echo -e "${YELLOW}Continue as root? [y/N] ${NC}")" continue_as_root
        case "$continue_as_root" in
            'Y'|'y'|'yes')
                echo -e "${YELLOW}Continuing as root user${NC}"
                ;;
            *)
                echo -e "${GREEN}Please run this script as a non-root user${NC}"
                exit 1
                ;;
        esac
    fi
}

# Run pre-installation checks
check_disk_space
check_root

# Create temporary directory for installation
TEMP_DIR=$(mktemp -d -t sentinel-XXXXXX)
if [ ! -d "$TEMP_DIR" ]; then
    echo -e "${RED}Failed to create temporary directory. Aborting.${NC}"
    exit 1
fi

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Temporary files removed successfully${NC}"
    else
        echo -e "${YELLOW}Warning: Failed to remove temporary directory: $TEMP_DIR${NC}"
    fi
}

# Register cleanup on script exit (normal, interrupt, error)
trap cleanup EXIT INT TERM

# Setup logging
LOG_FILE="$TEMP_DIR/sentinel_install.log"
exec &> >(tee -a "$LOG_FILE")
echo -e "${GREEN}Installation log will be saved to: $LOG_FILE${NC}"
echo -e "${GREEN}A copy will be moved to ~/.sentinel/install.log at the end${NC}"

# Install timestamp
echo "SENTINEL Installation Started: $(date)" > "$LOG_FILE"
echo "User: $(whoami)" >> "$LOG_FILE"
echo "System: $(uname -a)" >> "$LOG_FILE"
echo "----------------------" >> "$LOG_FILE"

# Print banner
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
echo -e "${BLUE}Installation Script${NC}"
echo -e "${BLUE}-----------------------------------${NC}\n"

# Function for progress indicator
progress() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to check and create backup
backup_file() {
    local file="$1"
    if [ -f "${HOME}/${file}" ]; then
        echo -e "${YELLOW}Found existing ${file}, backing up to ${file}.bak${NC}"
        
        # Check if backup already exists
        if [ -f "${HOME}/${file}.bak" ]; then
            echo -e "${YELLOW}Backup already exists, creating timestamped backup${NC}"
            cp -f "${HOME}/${file}" "${HOME}/${file}.bak.$(date +%Y%m%d%H%M%S)"
        else
            mv "${HOME}/${file}" "${HOME}/${file}.bak"
        fi
        
        return 0
    fi
    return 1
}

# Function to install file
install_file() {
    local source="$1"
    local dest="$2"
    
    if [ -f "./${source}" ]; then
        echo -e "${GREEN}Installing ${source}${NC}"
        cp -v "./${source}" "${dest}" 2>/dev/null || {
            echo -e "${RED}Error: Failed to copy ${source} to ${dest}${NC}"
            return 1
        }
        
        # Set proper permissions
        if [[ "$source" == *".sh" || "$source" == "bash_modules.d/"* ]]; then
            chmod 700 "${dest}" || echo -e "${YELLOW}Warning: Could not set execute permissions for ${dest}${NC}"
        else
            chmod 600 "${dest}" || echo -e "${YELLOW}Warning: Could not set permissions for ${dest}${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}Error: ${source} not found in current directory${NC}"
        return 1
    fi
}

# Function to create directory
create_directory() {
    local dir="$1"
    if [ ! -d "${dir}" ]; then
        echo -e "${GREEN}Creating ${dir}:${NC}"
        mkdir -pv "${dir}" || {
            echo -e "${RED}Failed to create directory ${dir}${NC}"
            return 1
        }
        chmod 0700 "${dir}" || {
            echo -e "${YELLOW}Warning: Could not set permissions for ${dir}${NC}"
        }
    fi
    return 0
}

# Function to install directory contents
install_directory_contents() {
    local source="$1"
    local dest="$2"
    
    if [ -d "./${source}" ]; then
        echo -e "${GREEN}Installing files from ${source} to ${dest}${NC}"
        
        # Create destination if it doesn't exist
        create_directory "${dest}"
        
        # Copy files and set permissions
        find "./${source}" -type f | while read file; do
            local basename=$(basename "$file")
            local destfile="${dest}/${basename}"
            
            cp -v "$file" "$destfile" 2>/dev/null | awk '{print "\t" $0}'
            
            # Make scripts executable
            if [[ "$file" == *.sh || "$basename" == *"completion" ]]; then
                chmod 700 "$destfile"
            else
                chmod 600 "$destfile"
            fi
        done
        
        return 0
    else
        echo -e "${YELLOW}Warning: ${source} directory not found, skipping${NC}"
        return 1
    fi
}

# Function to create and install a module
install_module() {
    local module_name="$1"
    local module_content="$2"
    local module_file="${HOME}/.bash_modules.d/${module_name}.module"
    
    echo -e "${GREEN}Installing ${module_name} module...${NC}"
    
    # Create module file
    echo "$module_content" > "$module_file"
    chmod 700 "$module_file"
    
    # Add to enabled modules if not already there
    if ! grep -q "^${module_name}$" "${HOME}/.bash_modules" 2>/dev/null; then
        echo "$module_name" >> "${HOME}/.bash_modules"
        echo -e "${GREEN}Enabled ${module_name} module${NC}"
    fi
    
    # Sign the module with HMAC if openssl is available
    sign_module "$module_name"
}

# Function to sign a module with HMAC
sign_module() {
    local module_name="$1"
    local module_file="${HOME}/.bash_modules.d/${module_name}.module"
    
    # Check if openssl is available
    if command -v openssl &>/dev/null && [ -f "$module_file" ]; then
        echo -e "${GREEN}Signing ${module_name} module with HMAC...${NC}"
        
        # Generate a default HMAC key if one doesn't exist
        local hmac_key_file="${HOME}/.sentinel/hmac_key"
        local hmac_key
        
        if [ ! -f "$hmac_key_file" ]; then
            # Create .sentinel directory if it doesn't exist
            mkdir -p "${HOME}/.sentinel" 2>/dev/null || {
                echo -e "${RED}Failed to create .sentinel directory${NC}"
                return 1
            }
            
            # Generate a random key with higher entropy
            if command -v openssl &>/dev/null; then
                # Use OpenSSL's more secure random generator - 32 bytes (256 bits)
                hmac_key=$(openssl rand -hex 32)
            elif command -v uuidgen &>/dev/null; then
                # Combine multiple UUIDs for better entropy if OpenSSL isn't available
                hmac_key=$(uuidgen)$(uuidgen)
            else
                # Fallback to a combination of methods if neither is available
                hmac_key=$(date +%s%N)$(head -c 32 /dev/urandom 2>/dev/null | base64 2>/dev/null || echo "FallbackKey$$")
            fi
            
            # Save the key
            echo "$hmac_key" > "$hmac_key_file"
            chmod 600 "$hmac_key_file" || echo -e "${YELLOW}Warning: Could not set permissions for HMAC key file${NC}"
            echo -e "${GREEN}Generated HMAC key for module verification${NC}"
        else
            # Read existing key
            hmac_key=$(cat "$hmac_key_file")
        fi
        
        # Generate HMAC signature using SHA-256
        local hmac=$(openssl dgst -sha256 -hmac "$hmac_key" "$module_file" | cut -d' ' -f2)
        if [ -n "$hmac" ]; then
            echo "$hmac" > "${module_file}.hmac"
            chmod 600 "${module_file}.hmac" || echo -e "${YELLOW}Warning: Could not set permissions for HMAC signature file${NC}"
            echo -e "${GREEN}Module ${module_name} signed with HMAC${NC}"
            return 0
        else
            echo -e "${RED}Failed to generate HMAC signature${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}openssl not found, module not signed with HMAC${NC}"
        return 1
    fi
}

# Function to check for dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for required dependencies
    echo -e "${BLUE}Checking for required dependencies...${NC}"
    
    # Check for jq (required for autocomplete)
    if ! command -v jq &>/dev/null; then
        missing_deps+=("jq")
        echo -e "${YELLOW}jq not found - required for autocomplete module${NC}"
    else
        echo -e "${GREEN}jq found${NC}"
    fi
    
    # If missing dependencies, attempt to install them
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}Missing dependencies: ${missing_deps[*]}${NC}"
        
        # Try to detect package manager
        if command -v apt &>/dev/null; then
            # Debian/Ubuntu
            echo -e "${BLUE}Attempting to install missing dependencies using apt...${NC}"
            read -p "$(echo -e "${YELLOW}Install missing dependencies? [Y/n] ${NC}")" install_deps
            case "$install_deps" in
                'N'|'n'|'no')
                    echo -e "${YELLOW}Skipping dependency installation${NC}"
                    echo -e "${YELLOW}Note: Some features may not work correctly${NC}"
                    ;;
                *)
                    sudo apt update && sudo apt install -y "${missing_deps[@]}"
                    ;;
            esac
        elif command -v dnf &>/dev/null; then
            # Fedora/RHEL
            echo -e "${BLUE}Attempting to install missing dependencies using dnf...${NC}"
            read -p "$(echo -e "${YELLOW}Install missing dependencies? [Y/n] ${NC}")" install_deps
            case "$install_deps" in
                'N'|'n'|'no')
                    echo -e "${YELLOW}Skipping dependency installation${NC}"
                    echo -e "${YELLOW}Note: Some features may not work correctly${NC}"
                    ;;
                *)
                    sudo dnf install -y "${missing_deps[@]}"
                    ;;
            esac
        elif command -v pacman &>/dev/null; then
            # Arch Linux
            echo -e "${BLUE}Attempting to install missing dependencies using pacman...${NC}"
            read -p "$(echo -e "${YELLOW}Install missing dependencies? [Y/n] ${NC}")" install_deps
            case "$install_deps" in
                'N'|'n'|'no')
                    echo -e "${YELLOW}Skipping dependency installation${NC}"
                    echo -e "${YELLOW}Note: Some features may not work correctly${NC}"
                    ;;
                *)
                    sudo pacman -S --needed "${missing_deps[@]}"
                    ;;
            esac
        else
            echo -e "${RED}Could not detect package manager${NC}"
            echo -e "${YELLOW}Please install the following dependencies manually:${NC}"
            for dep in "${missing_deps[@]}"; do
                echo "  - $dep"
            done
            echo -e "${YELLOW}Then rerun the installer${NC}"
        fi
    fi
}

# Main installation process
echo -e "${BLUE}${BOLD}Step 1: Checking dependencies${NC}"
check_dependencies

echo -e "${BLUE}${BOLD}Step 2: Backing up existing files${NC}"
for old in .bashrc .bash_aliases .bash_completion .bash_functions .bash_modules; do
    backup_file "$old"
done

echo -e "\n${BLUE}${BOLD}Step 3: Installing core files${NC}"
for new in bashrc bash_aliases bash_functions bash_completion bash_modules; do
    install_file "$new" "${HOME}/.${new}"
done

echo -e "\n${BLUE}${BOLD}Step 4: Handling custom configuration files${NC}"
for custom in bashrc.precustom bashrc.postcustom; do
    if [ -f "./${custom}" ]; then
        if [ -f "${HOME}/.${custom}" ]; then
            loop=1
            while [ $loop -eq 1 ]; do
                read -p "$(echo -e "${YELLOW}Overwrite ${HOME}/.${custom}? [Y/n] ${NC}")" overwrite
                case "$overwrite" in
                    'Y'|'y'|'yes'|'')
                        install_file "$custom" "${HOME}/.${custom}"
                        loop=0
                        ;;
                    'N'|'n'|'no')
                        echo -e "${YELLOW}Keeping existing ${HOME}/.${custom}${NC}"
                        loop=0
                        ;;
                    *)
                        echo "Please type 'y' for yes or 'n' for no"
                        ;;
                esac
            done
        else
            install_file "$custom" "${HOME}/.${custom}"
        fi
    fi
done

echo -e "\n${BLUE}${BOLD}Step 5: Setting up directory structures${NC}"
for dir_base in bash_aliases.d bash_functions.d bash_completion.d bash_modules.d; do
    create_directory "${HOME}/.${dir_base}"
    install_directory_contents "${dir_base}" "${HOME}/.${dir_base}"
done

echo -e "\n${BLUE}${BOLD}Step 6: Running additional setup scripts${NC}"
if [ -f "./sync.sh" ]; then
    echo -e "${GREEN}Running sync.sh...${NC}"
    chmod +x ./sync.sh
    ./sync.sh &
    progress $!
else
    echo -e "${YELLOW}sync.sh not found in the current directory, skipping.${NC}"
fi

# Create necessary output directories
echo -e "\n${BLUE}${BOLD}Step 7: Creating additional required directories${NC}"
for extra_dir in "${HOME}/.hashcat/wordlists" "${HOME}/.hashcat/cracked" "${HOME}/.sentinel/logs" \
                "${HOME}/secure_workspace/obfuscation" "${HOME}/secure_workspace/crypto" \
                "${HOME}/secure_workspace/malware_analysis" "${HOME}/obfuscated_files" \
                "${HOME}/.sentinel/temp" "${HOME}/.distcc" "${HOME}/.ccache" \
                "${HOME}/build_workspace"; do
    create_directory "$extra_dir"
done

# Final steps
echo -e "\n${BLUE}${BOLD}Step 8: Finalizing installation${NC}"
# Create a sample bookmark file for the 'j' function
if [ ! -f "${HOME}/.bookmarks" ]; then
    touch "${HOME}/.bookmarks"
    chmod 600 "${HOME}/.bookmarks"
    echo -e "${GREEN}Created empty bookmarks file${NC}"
fi

# Step 9: Install and activate special modules
echo -e "\n${BLUE}${BOLD}Step 9: Installing special modules${NC}"

# Create the obfuscate module
echo -e "${GREEN}Installing obfuscation module...${NC}"
OBFUSCATE_MODULE="${HOME}/.bash_modules.d/obfuscate.module"
if [ ! -f "$OBFUSCATE_MODULE" ]; then
    if [ -f "./modules/obfuscate.sh" ]; then
        cp -v "./modules/obfuscate.sh" "$OBFUSCATE_MODULE"
    elif [ -f "./modules/obfuscate.module" ]; then
        cp -v "./modules/obfuscate.module" "$OBFUSCATE_MODULE"
    else
        echo -e "${YELLOW}Obfuscation module not found in ./modules directory${NC}"
        echo -e "${YELLOW}You'll need to install it manually later${NC}"
    fi
    
    # Make it executable
    if [ -f "$OBFUSCATE_MODULE" ]; then
        chmod 700 "$OBFUSCATE_MODULE"
    fi
    
    # Add to enabled modules
    if [ -f "$OBFUSCATE_MODULE" ]; then
        if ! grep -q "^obfuscate$" "${HOME}/.bash_modules" 2>/dev/null; then
            echo "obfuscate" >> "${HOME}/.bash_modules"
            echo -e "${GREEN}Enabled obfuscation module${NC}"
        fi
    fi
fi

# Configure environment variables for secure operations
echo -e "${GREEN}Configuring secure environment variables...${NC}"
POSTCUSTOM="${HOME}/.bashrc.postcustom"
if [ -f "$POSTCUSTOM" ]; then
    # Only add if not already present
    if ! grep -q "OBFUSCATE_OUTPUT_DIR" "$POSTCUSTOM"; then
        echo "" >> "$POSTCUSTOM"
        echo "# SENTINEL security workspace configuration" >> "$POSTCUSTOM"
        echo "export OBFUSCATE_OUTPUT_DIR=\"\$HOME/secure_workspace/obfuscation\"" >> "$POSTCUSTOM"
        echo "export OBFUSCATE_TEMP_DIR=\"\$HOME/.sentinel/temp\"" >> "$POSTCUSTOM"
        echo "export SENTINEL_SECURE_DIRS=\"\$HOME/secure_workspace\"" >> "$POSTCUSTOM"
        echo -e "${GREEN}Added secure environment variables to .bashrc.postcustom${NC}"
    fi
    
    # Add distcc configuration if not present
    if ! grep -q "DISTCC_HOSTS" "$POSTCUSTOM"; then
        echo "" >> "$POSTCUSTOM"
        echo "# SENTINEL build environment configuration" >> "$POSTCUSTOM"
        echo "export DISTCC_HOSTS=\"localhost\"" >> "$POSTCUSTOM"
        echo "export DISTCC_DIR=\"\$HOME/.distcc\"" >> "$POSTCUSTOM"
        echo "export CCACHE_DIR=\"\$HOME/.ccache\"" >> "$POSTCUSTOM"
        echo "export CCACHE_SIZE=\"5G\"" >> "$POSTCUSTOM"
        echo "export PATH=\"/usr/lib/ccache/bin:/usr/lib/distcc/bin:\${PATH}\"" >> "$POSTCUSTOM"
        echo -e "${GREEN}Added distcc environment variables to .bashrc.postcustom${NC}"
    fi
    
    # Add module security configuration if not present
    if ! grep -q "SENTINEL_VERIFY_MODULES" "$POSTCUSTOM"; then
        echo "" >> "$POSTCUSTOM"
        echo "# Module security configuration" >> "$POSTCUSTOM"
        echo "export SENTINEL_VERIFY_MODULES=0         # Enable HMAC verification for modules" >> "$POSTCUSTOM"
        echo "export SENTINEL_REQUIRE_HMAC=1           # Require HMAC signatures for all modules" >> "$POSTCUSTOM"
        echo "export SENTINEL_CHECK_MODULE_CONTENT=0   # Check modules for suspicious patterns" >> "$POSTCUSTOM"
        echo "export SENTINEL_DEBUG_MODULES=0          # Enable debug mode for module loading" >> "$POSTCUSTOM"
        echo "# export SENTINEL_HMAC_KEY=\"random_string\" # Custom HMAC key (uncomment and set for better security)" >> "$POSTCUSTOM"
        echo -e "${GREEN}Added module security configuration to .bashrc.postcustom${NC}"
    fi
fi

# Step 10: Setting up Machine Learning features
echo -e "\n${BLUE}${BOLD}Step 10: Setting up Machine Learning features${NC}"

# Create sentinel_ml module directory
create_directory "${HOME}/.bash_modules.d/sentchat"
create_directory "${HOME}/.bash_modules.d/suggestions"
create_directory "${HOME}/.sentinel/models"

# Create and set up Python virtual environment
echo -e "${GREEN}Setting up Python virtual environment...${NC}"
VENV_DIR="${HOME}/.sentinel/venv"
create_directory "$VENV_DIR"

if command -v python3 &>/dev/null; then
    echo -e "${GREEN}Creating Python virtual environment in $VENV_DIR${NC}"
    python3 -m venv "$VENV_DIR"
    
    # Activate the virtual environment
    if [ -f "$VENV_DIR/bin/activate" ]; then
        # Source the activate script
        . "$VENV_DIR/bin/activate"
        echo -e "${GREEN}Virtual environment activated${NC}"
        
        # Upgrade pip in the virtual environment
        echo -e "${GREEN}Upgrading pip in virtual environment...${NC}"
        pip install --upgrade pip
        
        # Install Python dependencies in the virtual environment
        echo -e "${GREEN}Installing required Python packages for ML features...${NC}"
        
        # Function to verify pip package integrity
        verify_pip_package() {
            local package="$1"
            local expected_hash="$2"
            
            if [ -z "$expected_hash" ]; then
                # No hash provided, skip verification
                return 0
            fi
            
            # Get package info and extract the hash
            local package_info=$(pip show -f "$package" 2>/dev/null)
            if [ $? -ne 0 ]; then
                echo -e "${RED}Failed to get info for package $package${NC}"
                return 1
            fi
            
            # Compute hash of the package
            local package_file=$(echo "$package_info" | grep -o "^Location:.*" | cut -d' ' -f2)
            if [ -z "$package_file" ]; then
                echo -e "${RED}Could not find package location for $package${NC}"
                return 1
            fi
            
            local package_path="$package_file/$package"
            if [ ! -d "$package_path" ]; then
                echo -e "${RED}Package directory not found: $package_path${NC}"
                return 1
            fi
            
            # Compute hash of the main package file
            local computed_hash=$(find "$package_path" -name "*.py" -type f -exec sha256sum {} \; | sort | sha256sum | cut -d' ' -f1)
            
            # Compare hashes
            if [ "$computed_hash" != "$expected_hash" ]; then
                echo -e "${RED}WARNING: Hash mismatch for package $package${NC}"
                echo -e "${RED}Expected: $expected_hash${NC}"
                echo -e "${RED}Computed: $computed_hash${NC}"
                echo -e "${RED}This could indicate a security issue with the package!${NC}"
                return 1
            fi
            
            echo -e "${GREEN}Package $package integrity verified${NC}"
            return 0
        }

        # Install using provided script if available
        if [ -f "./contrib/install_deps.py" ]; then
            echo -e "${GREEN}Installing dependencies using provided script...${NC}"
            python3 ./contrib/install_deps.py --group ml
            
            # Verify the installation was successful
            if [ $? -ne 0 ]; then
                echo -e "${RED}Failed to install ML dependencies using script${NC}"
                echo -e "${YELLOW}Trying direct pip install as fallback...${NC}"
                pip install markovify numpy --user
            fi
        else
            # Fall back to direct pip install
            echo -e "${GREEN}Installing markovify and numpy...${NC}"
            pip install markovify numpy --user
            
            # Basic check that packages are installed
            python3 -c "import markovify, numpy; print('Packages installed successfully')" 2>/dev/null || {
                echo -e "${RED}Failed to import installed packages${NC}"
                echo -e "${YELLOW}You may need to install them manually later${NC}"
            }
        fi
        
        if python3 -c "import markovify, numpy" 2>/dev/null; then
            echo -e "${GREEN}ML dependencies installed successfully${NC}"
        else
            echo -e "${RED}Failed to install ML dependencies${NC}"
            echo -e "${YELLOW}You can install them manually later with:${NC}"
            echo -e "  source ${VENV_DIR}/bin/activate && pip install markovify numpy"
        fi
        
        # Deactivate the virtual environment
        deactivate
        
        # Add venv activation to .bashrc.postcustom
        POSTCUSTOM="${HOME}/.bashrc.postcustom"
        if [ -f "$POSTCUSTOM" ]; then
            # Only add if not already present
            if ! grep -q "SENTINEL_VENV_DIR" "$POSTCUSTOM"; then
                echo "" >> "$POSTCUSTOM"
                echo "# SENTINEL Python virtual environment" >> "$POSTCUSTOM"
                echo "export SENTINEL_VENV_DIR=\"$VENV_DIR\"" >> "$POSTCUSTOM"
                echo "# Add venv to PATH without activating" >> "$POSTCUSTOM"
                echo "export PATH=\"\$SENTINEL_VENV_DIR/bin:\$PATH\"" >> "$POSTCUSTOM"
                echo "# Alias for activating the environment" >> "$POSTCUSTOM"
                echo "alias sentinel-venv=\"source \$SENTINEL_VENV_DIR/bin/activate\"" >> "$POSTCUSTOM"
                echo -e "${GREEN}Added virtual environment configuration to .bashrc.postcustom${NC}"
            fi
        fi
    else
        echo -e "${RED}Failed to create virtual environment. Continuing without it.${NC}"
    fi
else
    echo -e "${YELLOW}Python 3 not found. ML features will be disabled.${NC}"
    echo -e "${YELLOW}Install Python 3 to enable ML features${NC}"
fi

# Install the sentinel_ml module
echo -e "${GREEN}Installing sentinel_ml module...${NC}"
if [ -f "./bash_modules.d/sentinel_ml.module" ]; then
    cp -v "./bash_modules.d/sentinel_ml.module" "${HOME}/.bash_modules.d/sentinel_ml"
    chmod 700 "${HOME}/.bash_modules.d/sentinel_ml"
    echo -e "${GREEN}Installed sentinel_ml module${NC}"
    
    # Enable module if Python and dependencies are available in the virtual environment
    if [ -f "$VENV_DIR/bin/activate" ] && command -v python3 &>/dev/null; then
        # Source the virtual environment
        . "$VENV_DIR/bin/activate"
        
        # Check if the required packages are installed
        if python3 -c "import importlib.util; print(importlib.util.find_spec('markovify') is not None)" 2>/dev/null | grep -q "True"; then
            if ! grep -q "^sentinel_ml$" "${HOME}/.bash_modules" 2>/dev/null; then
                echo "sentinel_ml" >> "${HOME}/.bash_modules"
                echo -e "${GREEN}Enabled sentinel_ml module${NC}"
            fi
        else
            echo -e "${YELLOW}ML dependencies not available in virtual environment. ML module not enabled.${NC}"
            echo -e "${YELLOW}Install dependencies with: sentinel-venv && pip install markovify numpy${NC}"
        fi
        
        # Deactivate the virtual environment
        deactivate
    fi
else
    echo -e "${YELLOW}sentinel_ml module not found, skipping${NC}"
fi

# Copy suggestion module files
echo -e "${GREEN}Installing suggestion module files...${NC}"
if [ -d "./bash_modules.d/suggestions" ]; then
    cp -rv "./bash_modules.d/suggestions/"* "${HOME}/.bash_modules.d/suggestions/"
    find "${HOME}/.bash_modules.d/suggestions" -type f -name "*.sh" -o -name "*.module" -exec chmod 700 {} \;
    echo -e "${GREEN}Installed suggestions module files${NC}"
fi

# Copy Python scripts
echo -e "${GREEN}Installing ML Python scripts...${NC}"
if [ -f "./contrib/sentinel_autolearn.py" ]; then
    cp -v "./contrib/sentinel_autolearn.py" "${HOME}/.sentinel/"
    chmod 700 "${HOME}/.sentinel/sentinel_autolearn.py"
    echo -e "${GREEN}Installed sentinel_autolearn.py${NC}"
fi

if [ -f "./contrib/sentinel_suggest.py" ]; then
    cp -v "./contrib/sentinel_suggest.py" "${HOME}/.sentinel/"
    chmod 700 "${HOME}/.sentinel/sentinel_suggest.py"
    echo -e "${GREEN}Installed sentinel_suggest.py${NC}"
fi

# Step 11: Set up the conversational assistant
echo -e "\n${BLUE}${BOLD}Step 11: Setting up conversational assistant${NC}"

# Check for LLM dependencies using the virtual environment
echo -e "${GREEN}Checking for chat dependencies...${NC}"
CHAT_DEPS_AVAILABLE=0

if [ -f "$VENV_DIR/bin/activate" ]; then
    # Source the virtual environment
    . "$VENV_DIR/bin/activate"
    
    if python3 -c "import importlib.util; print(importlib.util.find_spec('llama_cpp') is not None)" 2>/dev/null | grep -q "True" && \
       python3 -c "import importlib.util; print(importlib.util.find_spec('rich') is not None)" 2>/dev/null | grep -q "True"; then
        CHAT_DEPS_AVAILABLE=1
        echo -e "${GREEN}Chat dependencies already installed in virtual environment${NC}"
    else
        echo -e "${YELLOW}Chat dependencies not installed in virtual environment${NC}"
        echo -e "${YELLOW}You can install them manually later with:${NC}"
        echo -e "  sentinel-venv && pip install llama-cpp-python rich readline"
        echo -e "${YELLOW}or run sentinel_chat_install_deps after installation${NC}"
        
        # Create installation script for chat dependencies
        CHAT_DEPS_SCRIPT="${HOME}/.sentinel/install_chat_deps.sh"
        cat > "$CHAT_DEPS_SCRIPT" << 'EOF'
#!/usr/bin/env bash
# Install chat dependencies in the virtual environment

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

VENV_DIR="${HOME}/.sentinel/venv"
if [ ! -f "$VENV_DIR/bin/activate" ]; then
    echo -e "${YELLOW}Virtual environment not found. Creating one...${NC}"
    python3 -m venv "$VENV_DIR" || {
        echo -e "${RED}Failed to create virtual environment. Please install python3-venv package.${NC}"
        exit 1
    }
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate" || {
    echo -e "${RED}Failed to activate virtual environment${NC}"
    exit 1
}

# Upgrade pip
echo -e "${GREEN}Upgrading pip...${NC}"
pip install --upgrade pip || {
    echo -e "${YELLOW}Warning: Failed to upgrade pip. Continuing anyway.${NC}"
}

# Install dependencies with progress indication
echo -e "${GREEN}Installing chat dependencies...${NC}"
echo -e "${YELLOW}Note: This may take some time, especially for llama-cpp-python which needs compilation.${NC}"
echo -e "${YELLOW}Installing rich...${NC}"
pip install rich || {
    echo -e "${RED}Failed to install rich${NC}"
    deactivate
    exit 1
}

echo -e "${YELLOW}Installing readline...${NC}"
pip install readline || {
    echo -e "${RED}Failed to install readline${NC}"
    deactivate
    exit 1
}

echo -e "${YELLOW}Installing llama-cpp-python (this may take a while)...${NC}"
pip install llama-cpp-python || {
    echo -e "${RED}Failed to install llama-cpp-python${NC}"
    echo -e "${YELLOW}Trying alternative installation method...${NC}"
    
    # Try with specific compiler flags for better compatibility
    CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS" pip install llama-cpp-python || {
        echo -e "${RED}Alternative installation also failed.${NC}"
        echo -e "${YELLOW}You may need to install development packages:${NC}"
        echo -e "${YELLOW}  - For Debian/Ubuntu: sudo apt install python3-dev build-essential cmake${NC}"
        echo -e "${YELLOW}  - For Fedora/RHEL: sudo dnf install python3-devel gcc-c++ cmake${NC}"
        echo -e "${YELLOW}  - For Arch: sudo pacman -S python-pip cmake gcc${NC}"
        deactivate
        exit 1
    }
}

# Verify installation
if python3 -c "import llama_cpp, rich, readline" 2>/dev/null; then
    echo -e "${GREEN}Dependencies installed successfully. You can now use sentinel_chat.${NC}"
else
    echo -e "${RED}Installation verification failed. Some packages may not be properly installed.${NC}"
    deactivate
    exit 1
fi

deactivate
EOF
        chmod 700 "$CHAT_DEPS_SCRIPT" || echo -e "${YELLOW}Warning: Could not set execute permissions for install_chat_deps.sh${NC}"
        
        # Create alias for installing chat dependencies
        if [ -f "$POSTCUSTOM" ]; then
            if ! grep -q "sentinel_chat_install_deps" "$POSTCUSTOM"; then
                echo "alias sentinel_chat_install_deps=\"${HOME}/.sentinel/install_chat_deps.sh\"" >> "$POSTCUSTOM"
            fi
        fi
    fi
    
    # Deactivate the virtual environment
    deactivate
else
    echo -e "${YELLOW}Virtual environment not available. Chat features may not work properly.${NC}"
    echo -e "${YELLOW}Run the following commands to set up chat dependencies:${NC}"
    echo -e "  python3 -m venv ${HOME}/.sentinel/venv"
    echo -e "  source ${HOME}/.sentinel/venv/bin/activate"
    echo -e "  pip install llama-cpp-python rich readline"
fi

# Install chat module
echo -e "${GREEN}Installing sentinel_chat module...${NC}"
if [ -f "./bash_modules.d/sentinel_chat.module" ]; then
    cp -v "./bash_modules.d/sentinel_chat.module" "${HOME}/.bash_modules.d/sentinel_chat"
    chmod 700 "${HOME}/.bash_modules.d/sentinel_chat"
    echo -e "${GREEN}Installed sentinel_chat module${NC}"
    
    # Enable module
    if ! grep -q "^sentinel_chat$" "${HOME}/.bash_modules" 2>/dev/null; then
        echo "sentinel_chat" >> "${HOME}/.bash_modules"
        echo -e "${GREEN}Enabled sentinel_chat module${NC}"
    fi
else
    echo -e "${YELLOW}sentinel_chat module not found, skipping${NC}"
fi

# Copy chat Python script
echo -e "${GREEN}Installing chat Python script...${NC}"
if [ -f "./contrib/sentinel_chat.py" ]; then
    cp -v "./contrib/sentinel_chat.py" "${HOME}/.sentinel/"
    chmod 700 "${HOME}/.sentinel/sentinel_chat.py"
    echo -e "${GREEN}Installed sentinel_chat.py${NC}"
fi

# Copy sentchat module files
echo -e "${GREEN}Installing sentchat module files...${NC}"
if [ -d "./bash_modules.d/sentchat" ]; then
    # Create Python module structure
    mkdir -p "${HOME}/.sentinel/sentchat"
    
    # Create __init__.py to make it a proper module
    cat > "${HOME}/.sentinel/sentchat/__init__.py" << 'EOF'
"""
SENTINEL Chat Module
Provides functionality for the SENTINEL conversational assistant.
"""

__version__ = "1.0.0"
EOF

    # Copy module files
    cp -rv "./bash_modules.d/sentchat/"* "${HOME}/.bash_modules.d/sentchat/"
    find "${HOME}/.bash_modules.d/sentchat" -type f -name "*.sh" -o -name "*.module" -exec chmod 700 {} \;
    
    # Copy additional Python files that might be part of the sentchat module
    if [ -f "./contrib/sentinel_chat_context.py" ]; then
        cp -v "./contrib/sentinel_chat_context.py" "${HOME}/.sentinel/sentchat/"
    fi
    
    if [ -f "./contrib/sentinel_context.py" ]; then
        cp -v "./contrib/sentinel_context.py" "${HOME}/.sentinel/sentchat/"
    fi
    
    # Add the sentchat module to Python path if virtual env is activated
    if [ -f "$VENV_DIR/bin/activate" ]; then
        . "$VENV_DIR/bin/activate"
        
        # Create .pth file to add .sentinel directory to Python path
        SITE_PACKAGES=$(python -c "import site; print(site.getsitepackages()[0])")
        echo "${HOME}/.sentinel" > "${SITE_PACKAGES}/sentinel.pth"
        
        deactivate
    fi
    
    echo -e "${GREEN}Installed sentchat module files${NC}"
else
    echo -e "${YELLOW}sentchat module not found, skipping${NC}"
fi

# Fix permissions for any Python scripts
echo -e "${GREEN}Fixing permissions for Python scripts...${NC}"
find "${HOME}/.sentinel" -type f -name "*.py" -exec chmod 700 {} \;
find "${HOME}/.bash_modules.d" -type f -name "*.sh" -o -name "*.module" -exec chmod 700 {} \;

# Sign all modules with HMAC for security
echo -e "\n${BLUE}${BOLD}Step 12: Signing modules with HMAC for security${NC}"
echo -e "${GREEN}Signing installed modules with HMAC for integrity verification...${NC}"
for module_file in "${HOME}/.bash_modules.d/"*.module; do
    if [ -f "$module_file" ]; then
        module_name=$(basename "$module_file" .module)
        sign_module "$module_name"
    fi
done

# Create the HMAC key environment variable in bashrc.postcustom
if [ -f "${HOME}/.sentinel/hmac_key" ] && [ -f "$POSTCUSTOM" ]; then
    hmac_key=$(cat "${HOME}/.sentinel/hmac_key")
    # Only add if not already set
    if ! grep -q "SENTINEL_HMAC_KEY=" "$POSTCUSTOM"; then
        sed -i 's/# export SENTINEL_HMAC_KEY="random_string"/export SENTINEL_HMAC_KEY="'"$hmac_key"'"/' "$POSTCUSTOM"
        echo -e "${GREEN}Added HMAC key to .bashrc.postcustom${NC}"
    fi
fi

# Create wrapper scripts for Python utilities that use the virtual environment
echo -e "\n${BLUE}${BOLD}Step 13: Creating Python virtual environment wrappers${NC}"
echo -e "${GREEN}Creating virtual environment wrappers for Python scripts...${NC}"
SENTINEL_WRAPPERS="${HOME}/.sentinel/wrappers"
create_directory "$SENTINEL_WRAPPERS"

# Create wrapper template
cat > "${SENTINEL_WRAPPERS}/wrapper_template.sh" << 'EOF'
#!/usr/bin/env bash
# Wrapper to run Python scripts within the SENTINEL virtual environment

VENV_DIR="${HOME}/.sentinel/venv"
SCRIPT_PATH="$1"
shift

if [ ! -f "$VENV_DIR/bin/activate" ]; then
    echo -e "\033[1;33mVirtual environment not found. Creating one...\033[0m"
    python3 -m venv "$VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Run the script with all arguments
python3 "$SCRIPT_PATH" "$@"
EXIT_CODE=$?

# Deactivate the virtual environment
deactivate

exit $EXIT_CODE
EOF
chmod 700 "${SENTINEL_WRAPPERS}/wrapper_template.sh"

# Create specific wrappers for key scripts
for script in "sentinel_autolearn.py" "sentinel_suggest.py" "sentinel_chat.py"; do
    if [ -f "${HOME}/.sentinel/$script" ]; then
        script_name=$(basename "$script" .py)
        wrapper="${SENTINEL_WRAPPERS}/${script_name}_wrapper.sh"
        
        echo -e "${GREEN}Creating wrapper for $script_name${NC}"
        cat > "$wrapper" << EOF
#!/usr/bin/env bash
# Wrapper for $script_name

"${SENTINEL_WRAPPERS}/wrapper_template.sh" "${HOME}/.sentinel/$script" "\$@"
EOF
        chmod 700 "$wrapper"
        
        # Add to postcustom if needed
        if [ -f "$POSTCUSTOM" ]; then
            if ! grep -q "alias ${script_name}=" "$POSTCUSTOM"; then
                echo "alias ${script_name}=\"${wrapper}\"" >> "$POSTCUSTOM"
                echo -e "${GREEN}Added alias for $script_name to .bashrc.postcustom${NC}"
            fi
        fi
    fi
done

# Create a sentinel help command
echo -e "${GREEN}Creating sentinel help command...${NC}"
SENTINEL_HELP="${HOME}/.bash_functions.d/sentinel_help.sh"
cat > "$SENTINEL_HELP" << 'EOF'
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
  
${BLUE}Module Security:${NC}
  module_sign <name>      - Sign a module with HMAC
  module_verify <name>    - Verify a module's HMAC signature
  module_verbose [on|off] - Toggle verbose mode for modules
  module_debug [on|off]   - Toggle debug mode for modules
  
${BLUE}Build Environment:${NC}
  distcc-help             - Show distcc module help
  distcc-status           - Show distributed compilation status
  automake-distcc         - Set up GNU Automake with distcc
  cmake-distcc            - Set up CMake with distcc
  
${BLUE}Python Virtual Environment:${NC}
  sentinel-venv           - Activate the Python virtual environment
  sentinel_chat_install_deps - Install chat dependencies

${BLUE}Machine Learning Features:${NC}
  sentinel_suggest <cmd>  - Get ML-powered command suggestions
  sentinel_ml_train       - Retrain ML model with your commands
  sentinel_ml_stats       - Show command frequency statistics
  sentinel_chat           - Interactive AI shell assistant
  sentinel_chat_status    - Check chat assistant status

${BLUE}Text Processing:${NC}
  upper/lower             - Convert text to upper/lowercase
  csvview                 - Format CSV for better viewing
  jsonpp                  - Pretty print JSON with syntax highlighting
  
${BLUE}Other Utilities:${NC}
  extract <archive>       - Extract various archive formats
  sysinfo                 - Show system information
  netcheck                - View network connections
  
For more detailed help on specific features:
  obfuscate_help          - Help with file obfuscation
  hchelp                  - Help with hashcat module
  secure_rm_help          - Help with secure deletion
  distcc-help             - Help with distributed compilation

${YELLOW}Workspace directories:${NC}
  ~/secure_workspace/     - For security-related files
  ~/build_workspace/      - For compilation projects
  
${YELLOW}Security configuration:${NC}
  ~/.bashrc.postcustom    - Contains security settings
  SENTINEL_VERIFY_MODULES=1  - Enable HMAC verification
  SENTINEL_REQUIRE_HMAC=1    - Require HMAC signatures
  SENTINEL_HMAC_KEY          - Key for HMAC signatures
HELPTEXT
}
EOF
chmod 700 "$SENTINEL_HELP" || echo -e "${YELLOW}Warning: Could not set execute permissions for sentinel_help.sh${NC}"

# Print completion message
echo -e "\n${GREEN}${BOLD}Installation completed successfully!${NC}"
echo -e "To activate SENTINEL, either:"
echo -e "  1. Start a new terminal session, or"
echo -e "  2. Run: ${BLUE}source ~/.bashrc${NC}"
echo -e "\nEnjoy your enhanced terminal environment!"
echo -e "${YELLOW}For help and documentation, type: ${BLUE}sentinel_help${NC} after activation.\n"

# Final cleanup and log saving
echo -e "Installation completed: $(date)" >> "$LOG_FILE"
mkdir -p "${HOME}/.sentinel/logs" 2>/dev/null
cp "$LOG_FILE" "${HOME}/.sentinel/logs/install-$(date +%Y%m%d-%H%M%S).log" 2>/dev/null

# Verify critical components
echo -e "${BLUE}${BOLD}Verifying critical components...${NC}"
INSTALL_VERIFICATION="$TEMP_DIR/verification.txt"

# Check for critical files
echo "Verifying installed files..." > "$INSTALL_VERIFICATION"
for critical_file in "${HOME}/.bashrc" "${HOME}/.bash_aliases" "${HOME}/.bash_functions" \
                     "${HOME}/.bash_completion" "${HOME}/.bash_modules" \
                     "${HOME}/.sentinel/hmac_key"; do
    if [ -f "$critical_file" ]; then
        echo "✓ $critical_file" >> "$INSTALL_VERIFICATION"
    else
        echo "✗ $critical_file (MISSING)" >> "$INSTALL_VERIFICATION"
    fi
done

# Check for critical directories
for critical_dir in "${HOME}/.bash_modules.d" "${HOME}/.sentinel/logs" \
                    "${HOME}/.sentinel/temp" "${HOME}/.sentinel/models"; do
    if [ -d "$critical_dir" ]; then
        echo "✓ $critical_dir" >> "$INSTALL_VERIFICATION"
    else
        echo "✗ $critical_dir (MISSING)" >> "$INSTALL_VERIFICATION"
    fi
done

# Display verification results
cat "$INSTALL_VERIFICATION"
cp "$INSTALL_VERIFICATION" "${HOME}/.sentinel/logs/verification-$(date +%Y%m%d-%H%M%S).txt" 2>/dev/null

# Exit success
exit 0