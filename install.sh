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
    if [[ -f "${SCRIPT_DIR}/bash_modules.d/suggestions/config_loader.module" ]]; then
        source "${SCRIPT_DIR}/bash_modules.d/suggestions/config_loader.module"
        echo -e "${GREEN}✓ Created default configuration file${NC}"
    else
        echo -e "${RED}× Failed to create configuration file (config_loader.module not found)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Configuration file already exists${NC}"
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
if [[ -f "${SCRIPT_DIR}/bash_modules.d/suggestions/sentinel_config_helper.sh" ]]; then
    cp "${SCRIPT_DIR}/bash_modules.d/suggestions/sentinel_config_helper.sh" "${SENTINEL_CONFIG_DIR}/sentinel_config_helper.sh"
    chmod +x "${SENTINEL_CONFIG_DIR}/sentinel_config_helper.sh"
    echo -e "${GREEN}✓ Installed sentinel_config_helper.sh${NC}"
fi

# Copy README_CONFIG.md to ~/.sentinel for documentation
if [[ -f "${SCRIPT_DIR}/bash_modules.d/suggestions/README_CONFIG.md" ]]; then
    cp "${SCRIPT_DIR}/bash_modules.d/suggestions/README_CONFIG.md" "${SENTINEL_CONFIG_DIR}/README_CONFIG.md"
    echo -e "${GREEN}✓ Installed README_CONFIG.md${NC}"
fi

# Add configuration helper command for user convenience
if ! line_exists "alias sentinel-config='~/.sentinel/sentinel_config_helper.sh'" "${SCRIPT_DIR}/bash_aliases"; then
    echo "alias sentinel-config='~/.sentinel/sentinel_config_helper.sh'" >> "${SCRIPT_DIR}/bash_aliases"
    echo -e "${GREEN}✓ Added sentinel-config alias${NC}"
fi

# Run configuration migration if needed
echo -e "${BLUE}Checking for configuration to migrate...${NC}"
if [[ -f "${SCRIPT_DIR}/bash_modules.d/suggestions/migrate_config.sh" ]]; then
    echo -e "${YELLOW}Would you like to run the configuration migration tool? (y/n)${NC}"
    read -r choice
    if [[ "$choice" == "y" ]]; then
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