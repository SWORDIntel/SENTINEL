#!/usr/bin/env bash
# SENTINEL Configuration Helper
# Provides easy commands for managing the SENTINEL configuration system
# Version: 1.0.0

# Set strict error handling
set -o pipefail

# Define colors for prettier output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
BOLD="\033[1m"
NC="\033[0m" # No Color

# Configuration file location
SENTINEL_CONFIG_FILE="${HOME}/.sentinel/sentinel_config.sh"
README_FILE="${HOME}/.sentinel/README_CONFIG.md"

# Print banner
echo -e "${BLUE}"
echo "███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗      "
echo "██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║      "
echo "███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║      "
echo "╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║      "
echo "███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗ "
echo "╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝ "
echo -e "${NC}"
echo -e "${BOLD}Configuration Helper${NC}\n"

# Check if the configuration file exists
if [[ ! -f "$SENTINEL_CONFIG_FILE" ]]; then
    echo -e "${RED}Error: Configuration file not found at $SENTINEL_CONFIG_FILE${NC}"
    echo "Would you like to create a default configuration file? (y/n)"
    read -r choice
    if [[ "$choice" == "y" ]]; then
        # Check if config_loader module exists and use it
        if [[ -f "${HOME}/Documents/GitHub/SENTINEL/bash_modules.d/config_loader.module" ]]; then
            source "${HOME}/Documents/GitHub/SENTINEL/bash_modules.d/config_loader.module"
            echo -e "${GREEN}Configuration file created successfully.${NC}"
        else
            echo -e "${RED}Error: Could not find config_loader.module${NC}"
            exit 1
        fi
    else
        echo "Exiting without creating configuration file."
        exit 1
    fi
fi

# Check syntax of configuration file
syntax_check() {
    if bash -n "$SENTINEL_CONFIG_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ Configuration file syntax is valid.${NC}"
    else
        echo -e "${RED}× Configuration file contains syntax errors:${NC}"
        bash -n "$SENTINEL_CONFIG_FILE"
        echo ""
        echo "Would you like to edit the file to fix these errors? (y/n)"
        read -r choice
        if [[ "$choice" == "y" ]]; then
            edit_config
        fi
    fi
}

# Count settings in configuration file
count_settings() {
    local setting_count=$(grep -c "export " "$SENTINEL_CONFIG_FILE")
    echo -e "Your configuration file contains ${BOLD}$setting_count${NC} settings."
}

# Edit configuration file
edit_config() {
    local editor="${EDITOR:-nano}"
    if command -v nano >/dev/null 2>&1; then
        editor="nano"
    fi
    
    # Create a backup before editing
    cp "$SENTINEL_CONFIG_FILE" "${SENTINEL_CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    echo -e "${YELLOW}Created backup of current configuration.${NC}"
    
    # Open the editor
    $editor "$SENTINEL_CONFIG_FILE"
    
    # Check syntax after editing
    echo ""
    syntax_check
}

# View documentation
view_docs() {
    if [[ -f "$README_FILE" ]]; then
        local viewer
        if command -v less >/dev/null 2>&1; then
            viewer="less"
        else
            viewer="cat"
        fi
        
        $viewer "$README_FILE"
    else
        echo -e "${RED}Documentation file not found at $README_FILE${NC}"
    fi
}

# Search for a setting
search_settings() {
    local search_term="$1"
    
    if [[ -z "$search_term" ]]; then
        echo "Enter a search term:"
        read -r search_term
    fi
    
    echo -e "\n${BOLD}Searching for: ${search_term}${NC}\n"
    
    # Search in configuration file
    local results=$(grep -i "$search_term" "$SENTINEL_CONFIG_FILE")
    
    if [[ -n "$results" ]]; then
        echo -e "${GREEN}Found the following settings:${NC}"
        echo "$results" | grep -v "^#" | while IFS= read -r line; do
            echo -e "  ${BLUE}$(echo "$line" | cut -d'=' -f1)${NC}=$(echo "$line" | cut -d'=' -f2-)"
        done
        
        # Also search comments
        local comments=$(grep -i "#.*$search_term" "$SENTINEL_CONFIG_FILE")
        if [[ -n "$comments" ]]; then
            echo -e "\n${YELLOW}Found in comments:${NC}"
            echo "$comments"
        fi
    else
        echo -e "${YELLOW}No settings found matching '$search_term'.${NC}"
        
        # Suggest related settings
        local suggestions=$(grep -i "export " "$SENTINEL_CONFIG_FILE" | grep -i -B1 -A1 "$(echo "$search_term" | sed 's/./[&]/g')")
        
        if [[ -n "$suggestions" ]]; then
            echo -e "\n${GREEN}You might be interested in these related settings:${NC}"
            echo "$suggestions"
        fi
    fi
}

# Show main menu
show_menu() {
    echo -e "\n${BOLD}SENTINEL Configuration Helper${NC}"
    echo -e "${BLUE}================================${NC}"
    echo "1. Edit configuration"
    echo "2. View documentation"
    echo "3. Check configuration syntax"
    echo "4. Search for settings"
    echo "5. Run configuration wizard"
    echo "6. Reload configuration"
    echo "7. Reset to defaults"
    echo "q. Quit"
    echo ""
    echo -ne "Enter choice: "
    read -r choice
    
    case "$choice" in
        1) edit_config; show_menu ;;
        2) view_docs; show_menu ;;
        3) syntax_check; count_settings; show_menu ;;
        4) search_settings; show_menu ;;
        5) 
           echo "Simple configuration wizard coming soon."
           read -p "Press Enter to continue..."
           show_menu 
           ;;
        6) 
           # Source the configuration directly
           source "$SENTINEL_CONFIG_FILE"
           echo -e "${GREEN}Configuration reloaded.${NC}"
           read -p "Press Enter to continue..."
           show_menu 
           ;;
        7) 
           echo -e "${RED}Warning: This will reset all settings to defaults.${NC}"
           echo "Are you sure? (yes/no)"
           read -r confirm
           if [[ "$confirm" == "yes" ]]; then
               cp "$SENTINEL_CONFIG_FILE" "${SENTINEL_CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
               echo "Backup created at ${SENTINEL_CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
               
               # Use config_loader to create a fresh config
               if [[ -f "${HOME}/Documents/GitHub/SENTINEL/bash_modules.d/config_loader.module" ]]; then
                   rm -f "$SENTINEL_CONFIG_FILE"
                   source "${HOME}/Documents/GitHub/SENTINEL/bash_modules.d/config_loader.module"
                   echo -e "${GREEN}Configuration reset to defaults.${NC}"
               else
                   echo -e "${RED}Error: Could not find config_loader.module${NC}"
               fi
           else
               echo "Reset cancelled."
           fi
           read -p "Press Enter to continue..."
           show_menu 
           ;;
        q|Q) echo "Exiting."; exit 0 ;;
        *) echo -e "${RED}Invalid choice.${NC}"; show_menu ;;
    esac
}

# Check initial status
syntax_check
count_settings
echo ""

# Start the menu
show_menu 