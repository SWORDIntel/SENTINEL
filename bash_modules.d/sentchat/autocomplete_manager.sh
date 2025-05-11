#!/usr/bin/env bash
# SENTINEL Autocomplete Manager
# Handles the loading and coordination of all autocomplete modules
# Version: 1.0.0

# Module information
AUTOCOMPLETE_MANAGER_VERSION="1.0.0"
AUTOCOMPLETE_MANAGER_DESCRIPTION="Main manager for SENTINEL autocomplete system"
AUTOCOMPLETE_MANAGER_AUTHOR="SENTINEL Team"

# Ensure log directory exists
mkdir -p ~/.sentinel/logs

# Logging functions
_autocomplete_log_error() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $msg" >> ~/.sentinel/logs/autocomplete-$(date +%Y%m%d).log
}

_autocomplete_log_info() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $msg" >> ~/.sentinel/logs/autocomplete-$(date +%Y%m%d).log
}

_autocomplete_log_warning() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $msg" >> ~/.sentinel/logs/autocomplete-$(date +%Y%m%d).log
}

# Global variables for module management
declare -A SENTINEL_AUTOCOMPLETE_MODULES
declare -A SENTINEL_AUTOCOMPLETE_MODULE_PATHS

# Function to handle @autocomplete command
@autocomplete() {
    sentinel_autocomplete_command "$@"
}

# Implementation of the autocomplete command
sentinel_autocomplete_command() {
    local cmd="$1"
    shift
    
    case "$cmd" in
        help|--help|-h|"")
            sentinel_autocomplete_help
            ;;
        status|--status|-s)
            sentinel_autocomplete_status
            ;;
        fix|--fix|-f)
            sentinel_autocomplete_fix
            ;;
        reload|--reload|-r)
            sentinel_autocomplete_reload
            ;;
        install|--install|-i)
            sentinel_autocomplete_install
            ;;
        modules|--modules|-m)
            sentinel_autocomplete_list_modules
            ;;
        *)
            # Check if a module-specific command was given
            if [[ "$cmd" == *":"* ]]; then
                local module_name="${cmd%%:*}"
                local module_cmd="${cmd#*:}"
                
                # Call module-specific command if it exists
                local module_func="sentinel_${module_name}_${module_cmd}"
                if type -t "$module_func" &>/dev/null; then
                    "$module_func" "$@"
                else
                    echo "Unknown module command: $cmd"
                    echo "Available modules: $(sentinel_autocomplete_list_modules_names)"
                fi
            else
                echo "Unknown command: $cmd"
                echo "Available commands: help, status, fix, reload, install, modules"
                echo "Or use module:command format for module-specific commands"
            fi
            ;;
    esac
}

# Help function for autocomplete
sentinel_autocomplete_help() {
    echo -e "\033[1;32mSENTINEL Autocomplete Commands:\033[0m"
    echo -e "  \033[1;34m@autocomplete\033[0m                   - Show this help"
    echo -e "  \033[1;34m@autocomplete status\033[0m            - Check autocomplete status"
    echo -e "  \033[1;34m@autocomplete fix\033[0m               - Fix common issues"
    echo -e "  \033[1;34m@autocomplete reload\033[0m            - Reload autocomplete system"
    echo -e "  \033[1;34m@autocomplete install\033[0m           - Force reinstall"
    echo -e "  \033[1;34m@autocomplete modules\033[0m           - List loaded modules"
    
    # Module-specific commands
    echo -e "\n\033[1;32mModule Commands:\033[0m"
    
    # List BLE.sh module commands if available
    if type -t sentinel_blesh_status &>/dev/null; then
        echo -e "  \033[1;34m@autocomplete blesh:status\033[0m      - Check BLE.sh status"
        echo -e "  \033[1;34m@autocomplete blesh:fix\033[0m         - Fix BLE.sh issues"
        echo -e "  \033[1;34m@autocomplete blesh:reload\033[0m      - Reload BLE.sh"
    fi
    
    # List categories module commands if available
    if type -t sentinel_categories_status &>/dev/null; then
        echo -e "  \033[1;34m@autocomplete categories:status\033[0m  - Check command categories status"
        echo -e "  \033[1;34m@autocomplete categories:fix\033[0m     - Fix command categories issues"
        echo -e "  \033[1;34msentinel_add_category\033[0m <cmd> <category> [color] - Add/update command category"
    fi
    
    # List available snippets if module is loaded
    if [[ -d ~/.sentinel/autocomplete/snippets ]] && type -t sentinel_snippet_add &>/dev/null; then
        echo -e "  \033[1;34msentinel_snippet_add\033[0m <name> <command> - Add a new snippet"
        
        local snippets=($(find ~/.sentinel/autocomplete/snippets -name "*.snippet" 2>/dev/null | sort))
        if [[ ${#snippets[@]} -gt 0 ]]; then
            echo -e "\n\033[1;32mAvailable Snippets:\033[0m"
            for snippet in "${snippets[@]}"; do
                local name=$(basename "$snippet" .snippet)
                echo -e "  \033[1;34msnippet:$name\033[0m"
            done
        fi
    fi
    
    echo -e "\n\033[1;32mUsage:\033[0m"
    echo -e "  - Press \033[1;34mTab\033[0m to see suggestions"
    echo -e "  - Press \033[1;34mRight Arrow\033[0m to accept suggestion"
    if type -t _sentinel_run_corrected_command &>/dev/null; then
        echo -e "  - Type \033[1;34m!!:fix\033[0m to correct last failed command"
    fi
    if type -t _sentinel_suggest_next_command &>/dev/null; then
        echo -e "  - Type \033[1;34m!!:next\033[0m to run most likely next command"
    fi
    
    echo -e "\n\033[1;32mTroubleshooting:\033[0m"
    echo -e "  If autocomplete isn't working, try:"
    echo -e "  1. Run '@autocomplete fix'"
    echo -e "  2. Close and reopen your terminal"
    echo -e "  3. If still not working, run '@autocomplete install'"
}

# Status function for autocomplete
sentinel_autocomplete_status() {
    echo -e "\033[1;32mSENTINEL Autocomplete Status:\033[0m"
    _autocomplete_log_info "Checking autocomplete status"
    
    # Check module loading status
    echo -e "\n\033[1;32mLoaded Modules:\033[0m"
    for module in "${!SENTINEL_AUTOCOMPLETE_MODULES[@]}"; do
        local version="${SENTINEL_AUTOCOMPLETE_MODULES[$module]}"
        echo -e "  \033[1;34m$module\033[0m v$version"
    done
    
    # Check BLE.sh status if module is loaded
    if type -t sentinel_blesh_status &>/dev/null; then
        echo -e "\n\033[1;32mBLE.sh Status:\033[0m"
        sentinel_blesh_status | sed 's/^/  /'
    else
        echo -e "\n\033[1;31mBLE.sh module not loaded\033[0m"
    fi
    
    # Check categories status if module is loaded
    if type -t sentinel_categories_status &>/dev/null; then
        echo -e "\n\033[1;32mCategories Status:\033[0m"
        sentinel_categories_status | sed 's/^/  /'
    else
        echo -e "\n\033[1;31mCategories module not loaded\033[0m"
    fi
    
    # Check directories
    echo -e "\n\033[1;32mDirectories:\033[0m"
    for dir in ~/.sentinel/autocomplete ~/.sentinel/logs ~/.cache/blesh; do
        echo -n "  $dir: "
        if [[ -d "$dir" ]]; then
            echo -e "\033[1;32mExists\033[0m"
        else
            echo -e "\033[1;31mMissing\033[0m"
        fi
    done
    
    _autocomplete_log_info "Autocomplete status check completed"
}

# Fix function for autocomplete
sentinel_autocomplete_fix() {
    echo "Fixing autocomplete issues..."
    _autocomplete_log_info "Running autocomplete fix procedure"
    
    # Create necessary directories
    mkdir -p ~/.sentinel/autocomplete/{snippets,context,projects,params} 2>/dev/null
    mkdir -p ~/.sentinel/logs 2>/dev/null
    chmod 755 ~/.sentinel/{autocomplete,logs} 2>/dev/null
    
    # Fix BLE.sh issues if module is loaded
    if type -t sentinel_fix_blesh &>/dev/null; then
        sentinel_fix_blesh
    else
        echo "BLE.sh module not loaded, skipping BLE.sh fixes"
    fi
    
    # Fix categories issues if module is loaded
    if type -t sentinel_categories_fix &>/dev/null; then
        sentinel_categories_fix
    else
        echo "Categories module not loaded, skipping categories fixes"
    fi
    
    echo -e "\nAll issues fixed. Please \033[1;32mclose and reopen your terminal\033[0m for changes to take full effect."
    _autocomplete_log_info "Autocomplete fix procedure completed"
}

# Reload function for autocomplete
sentinel_autocomplete_reload() {
    echo "Reloading autocomplete system..."
    _autocomplete_log_info "Reloading autocomplete system"
    
    # Reload BLE.sh if module is loaded
    if type -t sentinel_reload_blesh &>/dev/null; then
        sentinel_reload_blesh
    fi
    
    # Reload all modules
    for module_path in "${SENTINEL_AUTOCOMPLETE_MODULE_PATHS[@]}"; do
        if [[ -f "$module_path" ]]; then
            echo "Reloading module: $module_path"
            source "$module_path"
        fi
    done
    
    echo "Autocomplete system reloaded."
    _autocomplete_log_info "Autocomplete system reload completed"
}

# Install function for autocomplete
sentinel_autocomplete_install() {
    echo "Installing autocomplete system..."
    _autocomplete_log_info "Installing autocomplete system"
    
    # Install BLE.sh if module is loaded
    if type -t sentinel_reinstall_blesh &>/dev/null; then
        sentinel_reinstall_blesh
    else
        echo "BLE.sh module not loaded, skipping BLE.sh installation"
    fi
    
    echo "Autocomplete system installation complete. Please restart your terminal."
    _autocomplete_log_info "Autocomplete system installation completed"
}

# List modules function
sentinel_autocomplete_list_modules() {
    echo -e "\033[1;32mLoaded Autocomplete Modules:\033[0m"
    _autocomplete_log_info "Listing autocomplete modules"
    
    for module in "${!SENTINEL_AUTOCOMPLETE_MODULES[@]}"; do
        local version="${SENTINEL_AUTOCOMPLETE_MODULES[$module]}"
        local path="${SENTINEL_AUTOCOMPLETE_MODULE_PATHS[$module]}"
        echo -e "  \033[1;34m$module\033[0m v$version - $path"
    done
}

# Get just the module names for completions
sentinel_autocomplete_list_modules_names() {
    local names=""
    for module in "${!SENTINEL_AUTOCOMPLETE_MODULES[@]}"; do
        names+=" $module"
    done
    echo "$names"
}

# Function to register a module
sentinel_autocomplete_register_module() {
    local module_name="$1"
    local module_version="$2"
    local module_path="$3"
    
    SENTINEL_AUTOCOMPLETE_MODULES["$module_name"]="$module_version"
    SENTINEL_AUTOCOMPLETE_MODULE_PATHS["$module_name"]="$module_path"
    
    _autocomplete_log_info "Registered module: $module_name v$module_version at $module_path"
}

# Main setup function for autocomplete
sentinel_setup_autocomplete() {
    # Skip setup if not in interactive shell
    [[ $- != *i* ]] && return 0
    
    _autocomplete_log_info "Initializing autocomplete system"
    
    # Set up reliable error handling
    set -o pipefail
    
    # Register this module
    sentinel_autocomplete_register_module "manager" "$AUTOCOMPLETE_MANAGER_VERSION" "${BASH_SOURCE[0]}"
    
    # Get the base directory
    local base_dir="$(dirname "${BASH_SOURCE[0]}")"
    
    # Load BLE.sh module if available
    local blesh_module="$base_dir/blesh_module.sh"
    if [[ -f "$blesh_module" ]]; then
        source "$blesh_module"
        _autocomplete_log_info "Loaded BLE.sh module from $blesh_module"
        
        # Check and initialize BLE.sh
        if type -t sentinel_check_blesh &>/dev/null; then
            sentinel_check_blesh
        fi
    else
        _autocomplete_log_warning "BLE.sh module not found at $blesh_module"
    fi
    
    # Load Categories module if available
    local categories_module="$base_dir/categories_module.sh"
    if [[ -f "$categories_module" ]]; then
        source "$categories_module"
        _autocomplete_log_info "Loaded Categories module from $categories_module"
    else
        _autocomplete_log_warning "Categories module not found at $categories_module"
    fi
    
    # Additional modules will be loaded here as they are created
    
    _autocomplete_log_info "Autocomplete system initialized successfully"
    echo "SENTINEL Autocomplete Manager v${AUTOCOMPLETE_MANAGER_VERSION} loaded with ${#SENTINEL_AUTOCOMPLETE_MODULES[@]} modules"
}

# Export functions for use in other modules
export -f sentinel_autocomplete_command
export -f @autocomplete
export -f sentinel_autocomplete_register_module

# Run the setup function to initialize the system
sentinel_setup_autocomplete 