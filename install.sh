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

# Function to fix permissions for all scripts
fix_file_permissions() {
    echo -e "${BLUE}${BOLD}Fixing file permissions${NC}"
    
    # Install dos2unix if not available
    if ! command -v dos2unix &> /dev/null; then
        echo -e "${YELLOW}dos2unix is not installed. Attempting to install it for better line ending support...${NC}"
        
        # Try to install dos2unix based on package manager
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y dos2unix
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y dos2unix
        elif command -v yum &> /dev/null; then
            sudo yum install -y dos2unix
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm dos2unix
        else
            echo -e "${YELLOW}Could not determine package manager. Will use Python method as fallback.${NC}"
        fi
    fi

    # Determine method for fixing line endings
    local USE_PYTHON=0
    if ! command -v dos2unix &> /dev/null; then
        if command -v python3 &> /dev/null; then
            echo -e "${YELLOW}Using Python for line ending conversion (dos2unix not available).${NC}"
            USE_PYTHON=1
        else
            echo -e "${YELLOW}Neither dos2unix nor Python 3 is available. Will use sed method.${NC}"
            USE_PYTHON=2
        fi
    else
        echo -e "${GREEN}Using dos2unix for line ending conversion.${NC}"
    fi
    
    # Function to fix line endings for a single file with enhanced detection and backup
    fix_line_endings_for_file() {
        local file="$1"
        local fixed=0
        
        # Create log directory
        mkdir -p "${HOME}/.sentinel/logs" 2>/dev/null
        
        # Check if file has CRLF using grep
        if grep -q $'\r' "$file" 2>/dev/null; then
            echo -e "  ${YELLOW}Fixing line endings:${NC} $file"
            
            # Create backup if it doesn't exist
            if [[ ! -f "${file}.bak-winformat" ]]; then
                cp "$file" "${file}.bak-winformat"
            fi
            
            # Apply the appropriate method
            if [ $USE_PYTHON -eq 1 ]; then
                # Python method
                python3 -c "
import sys
with open('$file', 'rb') as f:
    content = f.read()
with open('$file', 'wb') as f:
    f.write(content.replace(b'\r\n', b'\n'))
"
            elif [ $USE_PYTHON -eq 2 ]; then
                # Sed method
                sed -i 's/\r$//' "$file"
            else
                # dos2unix method
                dos2unix "$file"
            fi
            
            # Log the fixed file
            echo "$file" >> "${HOME}/.sentinel/logs/line_endings_fix.log"
            fixed=1
        fi
        
        return $fixed
    }
    
    # Initialize log file
    echo "SENTINEL Line Endings Fix Log" > "${HOME}/.sentinel/logs/line_endings_fix.log"
    echo "Started: $(date)" >> "${HOME}/.sentinel/logs/line_endings_fix.log"
    
    # Counter variables
    local TOTAL_FILES=0
    local FIXED_FILES=0
    
    echo -e "${YELLOW}Scanning for line ending issues...${NC}"
    
    # Process bash and shell scripts (more comprehensive than previous implementation)
    while IFS= read -r file; do
        TOTAL_FILES=$((TOTAL_FILES + 1))
        if fix_line_endings_for_file "$file"; then
            FIXED_FILES=$((FIXED_FILES + 1))
        fi
    done < <(find . -type f \( -name "*.sh" -o -name ".bash*" -o -name "bash_*" -o -path "*/bash_*/*" -o -path "*/.bash_*/*" \) 2>/dev/null)
    
    # Process completion files
    while IFS= read -r file; do
        TOTAL_FILES=$((TOTAL_FILES + 1))
        if fix_line_endings_for_file "$file"; then
            FIXED_FILES=$((FIXED_FILES + 1))
        fi
    done < <(find . -type f -path "*/bash_completion.d/*" 2>/dev/null)
    
    # Add summary to log
    echo "" >> "${HOME}/.sentinel/logs/line_endings_fix.log"
    echo "Summary:" >> "${HOME}/.sentinel/logs/line_endings_fix.log"
    echo "  Total files processed: $TOTAL_FILES" >> "${HOME}/.sentinel/logs/line_endings_fix.log"
    echo "  Files fixed: $FIXED_FILES" >> "${HOME}/.sentinel/logs/line_endings_fix.log"
    echo "Completed: $(date)" >> "${HOME}/.sentinel/logs/line_endings_fix.log"
    
    # Print summary
    if [ $FIXED_FILES -gt 0 ]; then
        echo -e "${YELLOW}Fixed line endings in $FIXED_FILES files (out of $TOTAL_FILES checked).${NC}"
    else
        echo -e "${GREEN}No line ending issues found in $TOTAL_FILES files.${NC}"
    fi
    
    # Set correct permissions on executable files
    echo -e "${YELLOW}Setting correct permissions on executable files...${NC}"
    find ./bash_functions.d/ -type f -exec chmod +x {} \; 2>/dev/null
    find ./bash_aliases.d/ -type f -exec chmod +x {} \; 2>/dev/null
    find ./bash_modules.d/ -type f -exec chmod +x {} \; 2>/dev/null
    find ./bash_completion.d/ -type f -exec chmod +x {} \; 2>/dev/null
    find ./contrib/ -name "*.py" -exec chmod +x {} \; 2>/dev/null
    find ./contrib/ -name "*.sh" -exec chmod +x {} \; 2>/dev/null
    
    echo -e "${GREEN}File permissions fixed successfully${NC}"
}

# Enhanced shell integration fix function
fix_shell_integration() {
    echo -e "${BLUE}${BOLD}Fixing shell integration and autocomplete${NC}"
    
    # Create activation script
    local activation_script="${HOME}/.sentinel/activate_integration.sh"
    mkdir -p "$(dirname "$activation_script")" 2>/dev/null
    
    # Create path manager script for consistency across environments
    local path_manager="${HOME}/.sentinel/fix_path_manager.sh"
    cat > "$path_manager" << 'EOF'
#!/usr/bin/env bash
# SENTINEL Path Manager
# Ensures consistent PATH across different environments

# Check if we are already initialized
if [[ -n "$SENTINEL_PATH_FIXED" ]]; then
    return 0
fi

# Ensure unique paths by removing duplicates
clean_path() {
    local old_PATH="$1"
    local new_PATH=""
    local IFS=":"
    
    for dir in $old_PATH; do
        if [[ ! $new_PATH =~ (^|:)$dir(:|$) ]]; then
            if [[ -z "$new_PATH" ]]; then
                new_PATH="$dir"
            else
                new_PATH="$new_PATH:$dir"
            fi
        fi
    done
    
    echo "$new_PATH"
}

# Important paths to ensure they exist
CRITICAL_PATHS=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.sentinel/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
)

# Add critical paths if they don't exist
for p in "${CRITICAL_PATHS[@]}"; do
    if [[ -d "$p" && ! $PATH =~ (^|:)$p(:|$) ]]; then
        PATH="$p:$PATH"
    fi
done

# Clean the PATH to remove duplicates
PATH=$(clean_path "$PATH")
export PATH

# Mark as initialized
export SENTINEL_PATH_FIXED=1
EOF
    chmod 700 "$path_manager"
    
    # Create script with enhanced security features
    cat > "$activation_script" << 'EOF'
#!/usr/bin/env bash
# SENTINEL Integration Activator
# Auto-generated by SENTINEL Installer

# First, fix the PATH to ensure all necessary directories are included
if [[ -f ~/.sentinel/fix_path_manager.sh ]]; then
    source ~/.sentinel/fix_path_manager.sh
fi

# Generate HMAC-signed token for security
_sentinel_generate_token() {
    local timestamp=$(date +%s)
    local nonce=$(openssl rand -hex 8)
    local key="${SENTINEL_AUTH_KEY:-$(hostname | openssl dgst -sha256 | cut -d' ' -f2)}"
    local data="${timestamp}:${nonce}"
    local hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$key" | cut -d' ' -f2)
    echo "${data}:${hmac}"
}

# Function to setup and activate autocomplete
setup_and_activate_autocomplete() {
    # Load aliases which contain autocomplete functions
    if [[ -f ~/.bash_aliases ]]; then
        source ~/.bash_aliases
    fi
    
    # Load specific autocomplete functionality
    if [[ -f ~/.bash_aliases.d/autocomplete ]]; then
        source ~/.bash_aliases.d/autocomplete
    fi
    
    # Try to activate the autocomplete system
    if type -t sentinel_setup_autocomplete &>/dev/null; then
        sentinel_setup_autocomplete &>/dev/null
    fi
    
    # Check if blesh loader exists and load it
    if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
        source ~/.sentinel/blesh_loader.sh &>/dev/null
    fi
}

# Check compatibility before activating
check_shell_compatibility() {
    local shell_issues=0
    
    # Check if bash version is sufficient (4.3+)
    if [[ -z "${BASH_VERSINFO[0]}" || ${BASH_VERSINFO[0]} -lt 4 || (${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 3) ]]; then
        echo "Warning: SENTINEL works best with Bash 4.3+. Current version: $BASH_VERSION"
        shell_issues=1
    fi
    
    # Check if necessary commands exist
    for cmd in grep sed find readlink dirname; do
        if ! command -v $cmd &>/dev/null; then
            echo "Warning: Required command '$cmd' not found!"
            shell_issues=1
        fi
    done
    
    return $shell_issues
}

# Check shell compatibility
check_shell_compatibility

# Setup and activate autocomplete
setup_and_activate_autocomplete

# Return secure token for verification
_sentinel_token=$(_sentinel_generate_token)
echo "SENTINEL integration activated with token: $_sentinel_token"
EOF

    chmod 700 "$activation_script"
    
    # Create a robust autocomplete fixer function in bash_functions.d
    mkdir -p "${HOME}/.bash_functions.d" 2>/dev/null
    local autocomplete_fixer="${HOME}/.bash_functions.d/fix_autocomplete.sh"
    
    cat > "$autocomplete_fixer" << 'EOF'
#!/usr/bin/env bash
# SENTINEL Autocomplete Fixer
# This function helps resolve common autocomplete issues

fix_autocomplete() {
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local NC='\033[0m'
    
    echo -e "${YELLOW}Fixing autocomplete issues...${NC}"
    
    # Ensure required directories exist
    mkdir -p ~/.sentinel/autocomplete/snippets 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/context 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/projects 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/params 2>/dev/null
    
    # Fix permissions
    chmod 700 ~/.sentinel/autocomplete 2>/dev/null
    find ~/.sentinel/autocomplete -type d -exec chmod 700 {} \; 2>/dev/null
    find ~/.sentinel/autocomplete -type f -exec chmod 600 {} \; 2>/dev/null
    
    # Ensure autocomplete alias file exists and is loaded
    if [[ ! -f ~/.bash_aliases.d/autocomplete ]]; then
        echo -e "${YELLOW}Autocomplete alias file missing, creating it...${NC}"
        mkdir -p ~/.bash_aliases.d 2>/dev/null
        
        cat > ~/.bash_aliases.d/autocomplete << 'EOL'
#!/usr/bin/env bash
# SENTINEL Autocomplete Functions

# Setup autocomplete function
sentinel_setup_autocomplete() {
    # Create required directories
    mkdir -p ~/.sentinel/autocomplete/snippets 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/context 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/projects 2>/dev/null
    mkdir -p ~/.sentinel/autocomplete/params 2>/dev/null
    
    # Load ble.sh if available (enhanced autocompletion)
    if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
        source ~/.sentinel/blesh_loader.sh &>/dev/null
    fi
}

# Main autocomplete command - help and control
@autocomplete() {
    local cmd="${1:-help}"
    shift 2>/dev/null
    
    case "$cmd" in
        help)
            echo "SENTINEL Autocomplete System"
            echo "Usage: @autocomplete [command]"
            echo ""
            echo "Commands:"
            echo "  status      - Check current autocomplete status"
            echo "  fix         - Fix common autocomplete issues"
            echo "  reload      - Reload autocomplete configuration"
            echo "  clear       - Clear autocomplete cache"
            ;;
        status)
            echo "SENTINEL Autocomplete Status:"
            if type -t ble-bind &>/dev/null; then
                echo "✅ Enhanced autocomplete (ble.sh) is active"
            else
                echo "❌ Enhanced autocomplete is not active"
            fi
            
            if [[ -d ~/.sentinel/autocomplete ]]; then
                echo "✅ Autocomplete directories exist"
            else
                echo "❌ Autocomplete directories missing"
            fi
            ;;
        fix)
            if type -t fix_autocomplete &>/dev/null; then
                fix_autocomplete
            else
                echo "Fix function not available. Please source ~/.bashrc first."
            fi
            ;;
        reload)
            sentinel_setup_autocomplete
            echo "Autocomplete configuration reloaded."
            ;;
        clear)
            rm -rf ~/.sentinel/autocomplete/context/* 2>/dev/null
            echo "Autocomplete cache cleared."
            ;;
        *)
            echo "Unknown command: $cmd"
            echo "Use '@autocomplete help' for available commands."
            ;;
    esac
}
EOL
        chmod 700 ~/.bash_aliases.d/autocomplete
    fi
    
    # Install ble.sh if not already installed
    if [[ ! -d ~/.local/share/blesh ]]; then
        echo -e "${YELLOW}Installing ble.sh for enhanced autocomplete...${NC}"
        mkdir -p ~/.local/share 2>/dev/null
        
        # Try to clone from GitHub if git is available
        if command -v git &>/dev/null; then
            git clone --depth 1 https://github.com/akinomyoga/ble.sh.git ~/.local/share/blesh 2>/dev/null || {
                echo -e "${RED}Failed to download ble.sh. Will try to use basic autocomplete.${NC}"
            }
        else
            echo -e "${YELLOW}Git not available. Using basic autocomplete.${NC}"
        fi
    fi
    
    # Create blesh_loader if it doesn't exist
    if [[ ! -f ~/.sentinel/blesh_loader.sh ]]; then
        mkdir -p ~/.sentinel 2>/dev/null
        cat > ~/.sentinel/blesh_loader.sh << 'EOL'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader

# Ensure cache directory exists with proper permissions
mkdir -p ~/.cache/blesh 2>/dev/null
chmod 755 ~/.cache/blesh 2>/dev/null

# Clean up any lock files that might cause issues
find ~/.cache/blesh -name "*.lock" -delete 2>/dev/null
find ~/.cache/blesh -name "*.part" -delete 2>/dev/null

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    # Configure BLE to disable unused module caching files that cause errors
    export _ble_suppress_stderr=1
    export _ble_keymap_initialize=0
    
    source ~/.local/share/blesh/ble.sh 2>/dev/null
    if ! type -t ble-bind &>/dev/null; then
        echo "Warning: ble.sh did not load properly. Trying alternative loading method..."
        # Try alternative loading with a different approach
        source <(cat ~/.local/share/blesh/ble.sh) 2>/dev/null
        
        if ! type -t ble-bind &>/dev/null; then
            echo "Warning: ble.sh could not be loaded. Using basic autocompletion instead."
            # Load bash standard completion as fallback
            [[ -f /etc/bash_completion ]] && source /etc/bash_completion
        fi
    fi
fi

# Configure ble.sh features if available
if type -t ble-bind &>/dev/null; then
    # Configure auto suggestions with PowerShell-like behavior
    bleopt complete_auto_delay=100 2>/dev/null || true
    bleopt complete_auto_complete=1 2>/dev/null || true
    
    # Set suggestion style to be grey (similar to PowerShell)
    bleopt highlight_auto_completion='fg=242' 2>/dev/null || true
    
    # Configure right arrow to accept suggestions
    ble-bind -m auto_complete -f right 'auto_complete/accept-line' 2>/dev/null || true
    
    # History-based completion
    bleopt complete_ambiguous=1 2>/dev/null || true
    bleopt complete_auto_history=1 2>/dev/null || true
fi
EOL
        chmod 700 ~/.sentinel/blesh_loader.sh
    fi
    
    # Validate the ~/.bashrc hook
    if ! grep -q "~/.sentinel/activate_integration.sh" ~/.bashrc; then
        echo -e "${YELLOW}Adding integration activator to ~/.bashrc${NC}"
        echo -e "\n# SENTINEL integration activator" >> ~/.bashrc
        echo 'if [[ -f ~/.sentinel/activate_integration.sh ]]; then' >> ~/.bashrc
        echo '    source ~/.sentinel/activate_integration.sh &>/dev/null' >> ~/.bashrc
        echo 'fi' >> ~/.bashrc
    fi
    
    echo -e "${GREEN}Autocomplete system fixed successfully${NC}"
}

# Function to check and fix symbolic links
fix_symbolic_links() {
    echo -e "${BLUE}${BOLD}Checking for broken symbolic links${NC}"
    
    declare -a broken_links=()
    local broken_count=0
    
    # Find all symbolic links
    while IFS= read -r link; do
        if [[ ! -e "$link" ]]; then
            broken_links+=("$link")
            broken_count=$((broken_count + 1))
            echo -e "${YELLOW}WARNING: Broken symbolic link found: $link -> $(readlink "$link")${NC}"
        fi
    done < <(find . -type l 2>/dev/null)
    
    if [ $broken_count -eq 0 ]; then
        echo -e "${GREEN}No broken symbolic links found.${NC}"
    else
        echo -e "${YELLOW}Attempting to fix $broken_count broken symbolic links...${NC}"
        
        for link in "${broken_links[@]}"; do
            # Extract the link target
            local target=$(readlink "$link")
            
            # Check if target exists as a path relative to HOME
            if [[ -e "${HOME}/$target" ]]; then
                rm "$link"
                ln -s "${HOME}/$target" "$link"
                echo -e "${GREEN}Fixed: $link -> ${HOME}/$target${NC}"
            elif [[ -e "$(dirname "$link")/$target" ]]; then
                # Check if target exists relative to the link's directory
                rm "$link"
                ln -s "$(dirname "$link")/$target" "$link"
                echo -e "${GREEN}Fixed: $link -> $(dirname "$link")/$target${NC}"
            else
                echo -e "${RED}Could not fix broken link: $link${NC}"
            fi
        done
    fi
}

# Main installation function
install_sentinel() {
    show_banner
    check_environment
    
    echo -e "\n${BLUE}${BOLD}Step 1: Checking Linux compatibility${NC}"
    check_compatibility
    
    echo -e "\n${BLUE}${BOLD}Step 2: Backing up existing files${NC}"
    for file in .bashrc .bash_aliases .bash_completion .bash_functions .bash_modules; do
        backup_file "$file"
    done
    
    echo -e "\n${BLUE}${BOLD}Step 3: Fixing file permissions and line endings${NC}"
    fix_file_permissions
    
    echo -e "\n${BLUE}${BOLD}Step 4: Checking and fixing symbolic links${NC}" 
    fix_symbolic_links
    
    echo -e "\n${BLUE}${BOLD}Step 5: Installing core files${NC}"
    for file in bashrc bash_aliases bash_functions bash_completion bash_modules; do
        install_file "$file" "${HOME}/.${file}"
    done
    
    echo -e "\n${BLUE}${BOLD}Step 6: Installing custom configurations${NC}"
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
    
    echo -e "\n${BLUE}${BOLD}Step 7: Setting up directory structures${NC}"
    for dir in bash_aliases.d bash_functions.d bash_completion.d bash_modules.d; do
        create_directory "${HOME}/.${dir}"
        install_directory_contents "${dir}" "${HOME}/.${dir}"
    done
    
    echo -e "\n${BLUE}${BOLD}Step 8: Creating required directories${NC}"
    for dir in "${HOME}/.hashcat/wordlists" "${HOME}/.hashcat/cracked" "${HOME}/.sentinel/logs" \
               "${HOME}/secure_workspace/obfuscation" "${HOME}/secure_workspace/crypto" \
               "${HOME}/secure_workspace/malware_analysis" "${HOME}/obfuscated_files" \
               "${HOME}/.sentinel/temp" "${HOME}/.distcc" "${HOME}/.ccache" \
               "${HOME}/build_workspace" "${HOME}/.bash_modules.d/sentchat" \
               "${HOME}/.bash_modules.d/suggestions" "${HOME}/.sentinel/models" \
               "${HOME}/.sentinel/wrappers" "${HOME}/.sentinel/autocomplete/snippets" \
               "${HOME}/.sentinel/autocomplete/context" "${HOME}/.sentinel/autocomplete/projects" \
               "${HOME}/.sentinel/autocomplete/params"; do
        create_directory "$dir"
    done
    
    # Create bookmarks file
    if [ ! -f "${HOME}/.bookmarks" ]; then
        touch "${HOME}/.bookmarks"
        chmod 600 "${HOME}/.bookmarks"
    fi
    
    echo -e "\n${BLUE}${BOLD}Step 9: Installing modules${NC}"
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
    
    echo -e "\n${BLUE}${BOLD}Step 10: Configuring Autocomplete System${NC}"
    fix_shell_integration
    
    echo -e "\n${BLUE}${BOLD}Step 11: Setting up Python environment${NC}"
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
  
${BLUE}Autocomplete Features:${NC}
  @autocomplete           - Show autocomplete command help
  @autocomplete status    - Check autocomplete status
  @autocomplete fix       - Fix common autocomplete issues
  
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
    
    echo -e "\n${BLUE}${BOLD}Step 12: Signing modules with HMAC${NC}"
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
    local critical_files=(".bashrc" ".bash_aliases" ".bash_functions" ".bash_completion" ".bash_modules" 
                         ".sentinel/hmac_key" ".sentinel/blesh_loader.sh" ".sentinel/fix_path_manager.sh" 
                         ".sentinel/activate_integration.sh" ".bash_aliases.d/autocomplete")
    local critical_dirs=(".bash_modules.d" ".sentinel/logs" ".sentinel/temp" ".sentinel/models" ".sentinel/autocomplete")
    
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
    echo -e "For autocomplete fixes, run: ${BLUE}@autocomplete fix${NC}\n"
    
    # Offer to activate configuration right away
    if command -v dialog &>/dev/null; then
        dialog --title "SENTINEL Installation" --yesno "Would you like to activate the configuration now?" 8 60
        if [ $? -eq 0 ]; then
            source ~/.bashrc
            @autocomplete fix 2>/dev/null || echo -e "${YELLOW}Autocomplete command not yet available. Please restart your terminal.${NC}"
            echo -e "\n${GREEN}Configuration activated. All integrated fixes applied.${NC}"
            echo -e "${YELLOW}Note: The standalone fix scripts (fix_line_endings.sh, linux_compatibility_check.sh, etc.) are no longer needed as their functionality has been integrated into the installer.${NC}"
        fi
    else
        read -p "$(echo -e "${YELLOW}Would you like to activate the configuration now? [y/N] ${NC}")" response
        if [[ "$response" =~ ^[Yy] ]]; then
            source ~/.bashrc
            @autocomplete fix 2>/dev/null || echo -e "${YELLOW}Autocomplete command not yet available. Please restart your terminal.${NC}"
            echo -e "\n${GREEN}Configuration activated. All integrated fixes applied.${NC}"
            echo -e "${YELLOW}Note: The standalone fix scripts (fix_line_endings.sh, linux_compatibility_check.sh, etc.) are no longer needed as their functionality has been integrated into the installer.${NC}"
        fi
    fi
}

# Execute the main installation
install_sentinel