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
        cp -v "./${source}" "${dest}" 2>/dev/null | awk '{print "\t" $0}'
        
        # Set proper permissions
        if [[ "$source" == *".sh" || "$source" == "bash_modules.d/"* ]]; then
            chmod 700 "${dest}"
        else
            chmod 600 "${dest}"
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
        chmod 0700 "${dir}"
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
}

# Main installation process
echo -e "${BLUE}${BOLD}Step 1: Backing up existing files${NC}"
for old in .bashrc .bash_aliases .bash_completion .bash_functions .bash_modules .bash_logout; do
    backup_file "$old"
done

echo -e "\n${BLUE}${BOLD}Step 2: Installing core files${NC}"
for new in bashrc bash_aliases bash_functions bash_completion bash_modules bash_logout; do
    install_file "$new" "${HOME}/.${new}"
done

echo -e "\n${BLUE}${BOLD}Step 3: Handling custom configuration files${NC}"
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

echo -e "\n${BLUE}${BOLD}Step 4: Setting up directory structures${NC}"
for dir_base in bash_aliases.d bash_functions.d bash_completion.d bash_modules.d; do
    create_directory "${HOME}/.${dir_base}"
    install_directory_contents "${dir_base}" "${HOME}/.${dir_base}"
done

echo -e "\n${BLUE}${BOLD}Step 5: Running additional setup scripts${NC}"
if [ -f "./sync.sh" ]; then
    echo -e "${GREEN}Running sync.sh...${NC}"
    chmod +x ./sync.sh
    ./sync.sh &
    progress $!
else
    echo -e "${YELLOW}sync.sh not found in the current directory, skipping.${NC}"
fi

# Create necessary output directories
echo -e "\n${BLUE}${BOLD}Step 6: Creating additional required directories${NC}"
for extra_dir in "${HOME}/.hashcat/wordlists" "${HOME}/.hashcat/cracked" "${HOME}/.sentinel/logs" \
                "${HOME}/secure_workspace/obfuscation" "${HOME}/secure_workspace/crypto" \
                "${HOME}/secure_workspace/malware_analysis" "${HOME}/obfuscated_files" \
                "${HOME}/.sentinel/temp" "${HOME}/.distcc" "${HOME}/.ccache" \
                "${HOME}/build_workspace"; do
    create_directory "$extra_dir"
done

# Final steps
echo -e "\n${BLUE}${BOLD}Step 7: Finalizing installation${NC}"
# Set proper permissions for .bash_logout to ensure it runs on exit
if [ -f "${HOME}/.bash_logout" ]; then
    chmod 700 "${HOME}/.bash_logout"
    echo -e "${GREEN}Set executable permissions for .bash_logout${NC}"
fi

# Create a sample bookmark file for the 'j' function
if [ ! -f "${HOME}/.bookmarks" ]; then
    touch "${HOME}/.bookmarks"
    chmod 600 "${HOME}/.bookmarks"
    echo -e "${GREEN}Created empty bookmarks file${NC}"
fi

# Step 8: Install and activate special modules
echo -e "\n${BLUE}${BOLD}Step 8: Installing special modules${NC}"

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

# Create and install the distcc module
DISTCC_MODULE_CONTENT='#!/usr/bin/env bash
# SENTINEL Module: distcc
# Configure environment for distributed compilation with Distcc and Ccache

# Module metadata
SENTINEL_MODULE_VERSION="1.0.0"
SENTINEL_MODULE_DESCRIPTION="Configure environment for distributed compilation with Distcc and Ccache"
SENTINEL_MODULE_AUTHOR="John"
SENTINEL_MODULE_DEPENDENCIES=""

# Check if we'"'"'re being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced, not executed directly."
    exit 1
fi

# Configuration
DISTCC_DIR="${DISTCC_DIR:-$HOME/.distcc}"
CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
DISTCC_HOSTS="${DISTCC_HOSTS:-localhost}"
DISTCC_LOG="${DISTCC_LOG:-$HOME/.distcc/distcc.log}"
DISTCC_VERBOSE="${DISTCC_VERBOSE:-0}"
DISTCC_FALLBACK="${DISTCC_FALLBACK:-1}"
CCACHE_SIZE="${CCACHE_SIZE:-5G}"

# Create necessary directories
mkdir -p "$DISTCC_DIR" 2>/dev/null
mkdir -p "$CCACHE_DIR" 2>/dev/null
mkdir -p "$(dirname "$DISTCC_LOG")" 2>/dev/null

# Function to check for distcc and ccache installations
distcc_check_installation() {
    local missing=""
    
    # Check for distcc
    if ! command -v distcc &>/dev/null; then
        missing+="distcc "
    fi
    
    # Check for ccache
    if ! command -v ccache &>/dev/null; then
        missing+="ccache "
    fi
    
    if [[ -n "$missing" ]]; then
        echo -e "${YELLOW}Warning: The following tools are not installed: ${missing}${NC}"
        echo -e "You can install them with:"
        echo -e "  ${BLUE}sudo apt install $missing${NC}  # Debian/Ubuntu"
        echo -e "  ${BLUE}sudo dnf install $missing${NC}  # Fedora/RHEL"
        echo -e "  ${BLUE}sudo pacman -S $missing${NC}    # Arch Linux"
        
        return 1
    else
        return 0
    fi
}

# Function to setup distcc environment
distcc_setup() {
    # Configure distcc
    export DISTCC_DIR
    export DISTCC_HOSTS
    export DISTCC_LOG
    export DISTCC_VERBOSE
    export DISTCC_FALLBACK
    
    # Configure ccache
    export CCACHE_DIR
    
    # Set ccache size if not already configured
    if ! ccache -s | grep -q "max cache size.*$CCACHE_SIZE"; then
        ccache -M "$CCACHE_SIZE" >/dev/null
    fi
    
    # Add distcc and ccache to PATH
    local distcc_bin_paths=(
        "/usr/lib/distcc/bin"
        "/usr/lib64/distcc/bin"
        "/usr/local/lib/distcc/bin"
        "/opt/local/lib/distcc/bin"
    )
    
    local ccache_bin_paths=(
        "/usr/lib/ccache/bin"
        "/usr/lib64/ccache/bin"
        "/usr/local/lib/ccache/bin"
        "/opt/local/lib/ccache/bin"
    )
    
    # Find existing paths and add to PATH
    for p in "${distcc_bin_paths[@]}"; do
        if [[ -d "$p" && ":$PATH:" != *":$p:"* ]]; then
            export PATH="$p:$PATH"
            break
        fi
    done
    
    for p in "${ccache_bin_paths[@]}"; do
        if [[ -d "$p" && ":$PATH:" != *":$p:"* ]]; then
            export PATH="$p:$PATH"
            break
        fi
    done
    
    # Verify PATH updates
    if echo "$PATH" | grep -q "distcc\|ccache"; then
        echo -e "${GREEN}Distcc and Ccache added to PATH:${NC} $PATH"
    else
        echo -e "${YELLOW}Warning: Could not find distcc or ccache bin directories${NC}"
        echo -e "Standard paths were not found. You may need to manually set your PATH."
    fi
    
    echo -e "${GREEN}Distcc configured with hosts:${NC} $DISTCC_HOSTS"
}

# Function to configure distcc hosts
distcc_set_hosts() {
    if [[ -z "$1" ]]; then
        echo "Current DISTCC_HOSTS: $DISTCC_HOSTS"
        echo "Usage: distcc_set_hosts <host1> [host2] [host3] ..."
        echo "Examples:"
        echo "  distcc_set_hosts localhost"
        echo "  distcc_set_hosts 192.168.1.100 192.168.1.101"
        echo "  distcc_set_hosts localhost/4 192.168.1.100/8"
        return 0
    fi
    
    # Join all arguments with spaces
    DISTCC_HOSTS="$*"
    export DISTCC_HOSTS
    
    echo -e "${GREEN}DISTCC_HOSTS set to:${NC} $DISTCC_HOSTS"
    
    # Save to configuration
    if [[ -f "$HOME/.bashrc.postcustom" ]]; then
        if grep -q "export DISTCC_HOSTS=" "$HOME/.bashrc.postcustom"; then
            sed -i "s/export DISTCC_HOSTS=.*/export DISTCC_HOSTS=\"$DISTCC_HOSTS\"/" "$HOME/.bashrc.postcustom"
        else
            echo "export DISTCC_HOSTS=\"$DISTCC_HOSTS\"" >> "$HOME/.bashrc.postcustom"
        fi
    fi
}

# Function to check distcc status
distcc_status() {
    echo -e "${BLUE}Distcc Configuration:${NC}"
    echo -e "DISTCC_DIR:      $DISTCC_DIR"
    echo -e "DISTCC_HOSTS:    $DISTCC_HOSTS"
    echo -e "DISTCC_LOG:      $DISTCC_LOG"
    echo -e "DISTCC_VERBOSE:  $DISTCC_VERBOSE"
    echo -e "DISTCC_FALLBACK: $DISTCC_FALLBACK"
    
    echo -e "\n${BLUE}Ccache Configuration:${NC}"
    echo -e "CCACHE_DIR:      $CCACHE_DIR"
    ccache -s
    
    echo -e "\n${BLUE}System PATH:${NC}"
    echo "$PATH" | tr '"'"':'"'"' '"'"'\n'"'"' | grep -E '"'"'distcc|ccache'"'"'
}

# Function to show compile example
distcc_example() {
    cat << '"'"'EOF'"'"'
Distcc and Ccache Usage Examples:
---------------------------------

Basic compilation with distcc:
  $ CC="distcc gcc" ./configure
  $ make -j$(distcc -j)

Automake/Autoconf with distcc:
  $ export CC="distcc gcc"
  $ export CXX="distcc g++"
  $ ./configure
  $ make -j$(distcc -j)

CMake with distcc:
  $ cmake -DCMAKE_C_COMPILER_LAUNCHER=distcc -DCMAKE_CXX_COMPILER_LAUNCHER=distcc ..
  $ make -j$(distcc -j)

Check if distcc is being used:
  $ DISTCC_VERBOSE=1 make -j$(distcc -j)

Monitor distcc activity:
  $ distccmon-text        # Text-based monitor
  $ distccmon-gnome       # GUI monitor (if installed)
EOF
}

# Function to create monitor alias
distcc_monitor() {
    local type="${1:-text}"
    
    case "$type" in
        text)
            if command -v distccmon-text &>/dev/null; then
                distccmon-text 1
            else
                echo "distccmon-text not found. Install distcc-client package."
            fi
            ;;
        gui|gnome)
            if command -v distccmon-gnome &>/dev/null; then
                distccmon-gnome &
            else
                echo "distccmon-gnome not found. Install distcc-client package."
            fi
            ;;
        *)
            echo "Unknown monitor type. Use '"'"'text'"'"' or '"'"'gui'"'"'."
            ;;
    esac
}

# Function to display help information
distcc_help() {
    cat << EOF
${GREEN}SENTINEL Distcc Module Help${NC}
==============================

${BLUE}Available Commands:${NC}
  distcc_status       - Show distcc and ccache configuration
  distcc_set_hosts    - Configure distcc hosts
  distcc_monitor      - Monitor distcc activity
  distcc_example      - Show usage examples

${BLUE}Configuration Variables:${NC}
  DISTCC_HOSTS        - Space-separated list of compilation hosts
  DISTCC_DIR          - Directory for distcc files
  CCACHE_DIR          - Directory for ccache files
  CCACHE_SIZE         - Maximum size of ccache (default: 5G)
  
${BLUE}Example usage:${NC}
  distcc_set_hosts localhost 192.168.1.100
  distcc_monitor text
  
${BLUE}To use in build systems:${NC}
  export CC="distcc gcc"
  export CXX="distcc g++"
  ./configure && make -j\$(distcc -j)
  
For more information about distcc:
  man distcc
EOF
}

# Function to create automake environment
automake_env() {
    local type="${1:-gnu}"
    
    local configure_flags=""
    local num_jobs=$(distcc -j || echo 4)
    
    case "$type" in
        gnu)
            export CC="distcc gcc"
            export CXX="distcc g++"
            configure_flags="--prefix=/usr/local"
            ;;
        cmake)
            export CMAKE_C_COMPILER_LAUNCHER="distcc"
            export CMAKE_CXX_COMPILER_LAUNCHER="distcc"
            ;;
        *)
            echo "Unknown build type. Use '"'"'gnu'"'"' or '"'"'cmake'"'"'."
            return 1
            ;;
    esac
    
    echo -e "${GREEN}Automake environment set for $type builds${NC}"
    echo -e "Compilers: CC=$CC CXX=$CXX"
    echo -e "Configure flags: $configure_flags"
    echo -e "Parallel jobs: $num_jobs"
    
    echo -e "\n${BLUE}Build commands:${NC}"
    if [[ "$type" == "gnu" ]]; then
        echo -e "  ./configure $configure_flags"
        echo -e "  make -j$num_jobs"
    else
        echo -e "  mkdir -p build && cd build"
        echo -e "  cmake .."
        echo -e "  make -j$num_jobs"
    fi
}

# Main setup
if distcc_check_installation; then
    distcc_setup
fi

# Create aliases for quick access
alias distcc-status='"'"'distcc_status'"'"'
alias distcc-monitor='"'"'distcc_monitor'"'"'
alias distcc-help='"'"'distcc_help'"'"'
alias distcc-example='"'"'distcc_example'"'"'
alias automake-distcc='"'"'automake_env gnu'"'"'
alias cmake-distcc='"'"'automake_env cmake'"'"'

# Display module loaded message
echo -e "${GREEN}[+]${NC} Distcc/Ccache module loaded. PATH configured for distributed compilation."
echo -e "    Type ${CYAN}distcc-help${NC} to see available commands."
'

install_module "distcc" "$DISTCC_MODULE_CONTENT"

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
fi

# Step 9: Setting up Machine Learning features
echo -e "\n${BLUE}${BOLD}Step 9: Setting up Machine Learning features${NC}"

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
        
        # Install using provided script if available
        if [ -f "./contrib/install_deps.py" ]; then
            python3 ./contrib/install_deps.py --group ml
        else
            # Fall back to direct pip install
            echo -e "${GREEN}Installing markovify and numpy...${NC}"
            pip install markovify numpy
        fi
        
        if [ $? -eq 0 ]; then
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
if [ -f "./bash_modules.d/sentinel_ml.fixed" ]; then
    cp -v "./bash_modules.d/sentinel_ml.fixed" "${HOME}/.bash_modules.d/sentinel_ml"
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

# Step 10: Set up the conversational assistant
echo -e "\n${BLUE}${BOLD}Step 10: Setting up conversational assistant${NC}"

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

VENV_DIR="${HOME}/.sentinel/venv"
if [ ! -f "$VENV_DIR/bin/activate" ]; then
    echo -e "Virtual environment not found. Creating one..."
    python3 -m venv "$VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Upgrade pip
pip install --upgrade pip

# Install dependencies
echo "Installing chat dependencies..."
pip install llama-cpp-python rich readline

echo "Dependencies installed. You can now use sentinel_chat."
EOF
        chmod 700 "$CHAT_DEPS_SCRIPT"
        
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
if [ -f "./bash_modules.d/sentinel_chat" ]; then
    cp -v "./bash_modules.d/sentinel_chat" "${HOME}/.bash_modules.d/sentinel_chat"
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
    cp -rv "./bash_modules.d/sentchat/"* "${HOME}/.bash_modules.d/sentchat/"
    find "${HOME}/.bash_modules.d/sentchat" -type f -name "*.sh" -o -name "*.module" -exec chmod 700 {} \;
    echo -e "${GREEN}Installed sentchat module files${NC}"
fi

# Fix permissions for any Python scripts
echo -e "${GREEN}Fixing permissions for Python scripts...${NC}"
find "${HOME}/.sentinel" -type f -name "*.py" -exec chmod 700 {} \;
find "${HOME}/.bash_modules.d" -type f -name "*.sh" -o -name "*.module" -exec chmod 700 {} \;

# Create wrapper scripts for Python utilities that use the virtual environment
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
  
${BLUE}Navigation:${NC}
  j [-a|-l|-r <num>|<name>] - Directory jumping tool
  mkcd <dir>              - Create directory and cd into it
  
${BLUE}Security Modules:${NC}
  obfuscate_help          - Show obfuscation module help
  obfuscate_check_tools   - Check for obfuscation tools
  hashdetect <hash>       - Identify hash type
  hashcrack <hash>        - Crack a hash with auto-detection
  
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
HELPTEXT
}
EOF
chmod 700 "$SENTINEL_HELP"

# Print completion message
echo -e "\n${GREEN}${BOLD}Installation completed successfully!${NC}"
echo -e "To activate SENTINEL, either:"
echo -e "  1. Start a new terminal session, or"
echo -e "  2. Run: ${BLUE}source ~/.bashrc${NC}"
echo -e "\nEnjoy your enhanced terminal environment!"
echo -e "${YELLOW}For help and documentation, type: ${BLUE}sentinel_help${NC} after activation.\n"