#!/usr/bin/env bash
# SENTINEL Comprehensive Test Script
# Tests all major modules and functionality
# Version: 2.0.0

# Exit on errors
set -e

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Path to sentinel config
SENTINEL_CONFIG="${HOME}/.sentinel/sentinel_config.sh"
SENTINEL_DIR="$(pwd)"

# Print banner
echo -e "${BLUE}"
echo "███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗      "
echo "██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║      "
echo "███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║      "
echo "╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║      "
echo "███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗ "
echo "╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝ "
echo -e "${NC}"
echo -e "${GREEN}Comprehensive Test Script${NC}\n"

# Show current directory
echo -e "${YELLOW}Current directory:${NC} $(pwd)"

# Function to report test status
function report() {
    local status=$1
    local message=$2
    
    if [[ "$status" -eq 0 ]]; then
        echo -e "${GREEN}✓${NC} $message"
    else
        echo -e "${RED}✗${NC} $message"
    fi
    
    return $status
}

# Function to run a test with a timeout
function run_test() {
    local name=$1
    local command=$2
    local timeout=${3:-5}
    
    echo -e "\n${BLUE}Testing: ${CYAN}$name${NC}"
    echo -e "${YELLOW}Command: ${NC}$command"
    
    # Run the command with a timeout
    local start_time=$(date +%s.%N)
    timeout $timeout bash -c "$command" > /tmp/sentinel_test_output 2>&1
    local status=$?
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    # Log output and timing 
    echo -e "${PURPLE}Duration: ${NC}${duration}s"
    
    if [[ "$status" -eq 0 ]]; then
        echo -e "${GREEN}Output (success):${NC}"
    else
        echo -e "${RED}Output (failed):${NC}"
    fi
    
    cat /tmp/sentinel_test_output
    
    return $status
}

# Function to test lazy loading
function test_lazy_loading() {
    echo -e "\n${CYAN}=== Testing Lazy Loading ====${NC}"
    
    # Test if lazy loading is enabled in config
    if [[ -f "$SENTINEL_CONFIG" ]]; then
        source "$SENTINEL_CONFIG"
        if grep -q "U_LAZY_LOAD=1" "$SENTINEL_CONFIG" || grep -q "CONFIG\[LAZY_LOAD\]=1" "$SENTINEL_DIR/bashrc"; then
            echo -e "${GREEN}✓${NC} Lazy loading is enabled in configuration"
        else
            echo -e "${YELLOW}⚠${NC} Lazy loading may not be enabled in configuration"
        fi
    fi
    
    # Create a test function to measure startup time
    echo -e "\n${BLUE}Measuring startup time with lazy loading${NC}"
    
    # Test with lazy loading enabled
    cat > /tmp/sentinel_test_lazy.sh << 'EOF'
#!/usr/bin/env bash
start=$(date +%s.%N)
export U_LAZY_LOAD=1
source ~/.bashrc
end=$(date +%s.%N)
echo "Startup time with lazy loading: $(echo "$end - $start" | bc) seconds"
EOF
    chmod +x /tmp/sentinel_test_lazy.sh
    /tmp/sentinel_test_lazy.sh
    
    # Test without lazy loading
    echo -e "\n${BLUE}Measuring startup time without lazy loading${NC}"
    cat > /tmp/sentinel_test_eager.sh << 'EOF'
#!/usr/bin/env bash
start=$(date +%s.%N)
export U_LAZY_LOAD=0
source ~/.bashrc
end=$(date +%s.%N)
echo "Startup time without lazy loading: $(echo "$end - $start" | bc) seconds"
EOF
    chmod +x /tmp/sentinel_test_eager.sh
    /tmp/sentinel_test_eager.sh
    
    # Test development environment loading
    echo -e "\n${BLUE}Testing development environment lazy loading${NC}"
    
    # Create a script to test if pyenv is loaded by default
    cat > /tmp/sentinel_test_pyenv.sh << 'EOF'
#!/usr/bin/env bash
export U_LAZY_LOAD=1
source ~/.bashrc
if type -t pyenv >/dev/null; then
    if [[ "$(type -t pyenv)" == "function" ]]; then
        echo "pyenv is properly lazy loaded as a function"
        exit 0
    else
        echo "pyenv is already loaded, not lazy loaded"
        exit 1
    fi
else
    echo "pyenv is not available"
    exit 2
fi
EOF
    chmod +x /tmp/sentinel_test_pyenv.sh
    /tmp/sentinel_test_pyenv.sh || echo -e "${YELLOW}⚠${NC} Pyenv test failed or not installed"
    
    # Create a script to test if NVM is loaded by default
    cat > /tmp/sentinel_test_nvm.sh << 'EOF'
#!/usr/bin/env bash
export U_LAZY_LOAD=1
source ~/.bashrc
if type -t nvm >/dev/null; then
    if [[ "$(type -t nvm)" == "function" ]]; then
        echo "nvm is properly lazy loaded as a function"
        exit 0
    else
        echo "nvm is already loaded, not lazy loaded"
        exit 1
    fi
else
    echo "nvm is not available"
    exit 2
fi
EOF
    chmod +x /tmp/sentinel_test_nvm.sh
    /tmp/sentinel_test_nvm.sh || echo -e "${YELLOW}⚠${NC} NVM test failed or not installed"
}

# Function to test core files
function test_core_files() {
    echo -e "\n${CYAN}=== Testing Core Files ====${NC}"
    
    # Test if core files exist
    for file in bashrc bash_aliases bash_functions bash_completion bash_modules; do
        if [[ -f "$SENTINEL_DIR/$file" ]]; then
            echo -e "${GREEN}✓${NC} Found core file: $file"
        else
            echo -e "${RED}✗${NC} Missing core file: $file"
        fi
    done
    
    # Test loading of core files
    run_test "bashrc" "source $SENTINEL_DIR/bashrc" || echo -e "${RED}Failed to source bashrc${NC}"
    run_test "bash_aliases" "source $SENTINEL_DIR/bash_aliases" || echo -e "${RED}Failed to source bash_aliases${NC}"
    run_test "bash_functions" "source $SENTINEL_DIR/bash_functions" || echo -e "${RED}Failed to source bash_functions${NC}"
    run_test "bash_completion" "source $SENTINEL_DIR/bash_completion" || echo -e "${RED}Failed to source bash_completion${NC}"
    run_test "bash_modules" "source $SENTINEL_DIR/bash_modules" || echo -e "${RED}Failed to source bash_modules${NC}"
}

# Function to test module system
function test_module_system() {
    echo -e "\n${CYAN}=== Testing Module System ====${NC}"
    
    # Source necessary files for module testing
    source "$SENTINEL_DIR/bashrc" 2>/dev/null || true
    
    # Test module directory exists
    if [[ -d "$SENTINEL_DIR/bash_modules.d" ]]; then
        echo -e "${GREEN}✓${NC} Module directory exists"
        
        # Count modules
        module_count=$(find "$SENTINEL_DIR/bash_modules.d" -type f -name "*.module" | wc -l)
        echo -e "${GREEN}→${NC} Found $module_count module files"
        
        # List available modules
        echo -e "${YELLOW}Available modules:${NC}"
        find "$SENTINEL_DIR/bash_modules.d" -type f -name "*.module" | while read -r module; do
            module_name=$(basename "$module" .module)
            echo -e "  - $module_name"
        done
    else
        echo -e "${RED}✗${NC} Module directory does not exist"
    fi
    
    # Test module commands if available
    if type module_list &>/dev/null; then
        run_test "module_list" "module_list"
    else
        echo -e "${YELLOW}⚠${NC} module_list function not available, skipping module command tests"
    fi
}

# Function to test bash completion
function test_bash_completion() {
    echo -e "\n${CYAN}=== Testing Bash Completion ====${NC}"
    
    # Source bashrc 
    source "$SENTINEL_DIR/bashrc" 2>/dev/null || true
    
    # Test for completion directory
    if [[ -d "$SENTINEL_DIR/bash_completion.d" ]]; then
        echo -e "${GREEN}✓${NC} Completion directory exists"
        
        # Count completion files
        completion_count=$(find "$SENTINEL_DIR/bash_completion.d" -type f | wc -l)
        echo -e "${GREEN}→${NC} Found $completion_count completion files"
    else
        echo -e "${YELLOW}⚠${NC} bash_completion.d directory not found"
    fi
    
    # Check if BLE.sh is installed
    if [[ -f "$HOME/.local/share/blesh/ble.sh" ]]; then
        echo -e "${GREEN}✓${NC} BLE.sh is installed"
    else
        echo -e "${YELLOW}⚠${NC} BLE.sh is not installed"
    fi
    
    # Test BLE.sh loader if available
    if type _sentinel_load_attempt &>/dev/null; then
        echo -e "${GREEN}✓${NC} BLE.sh loader function is available"
    else
        echo -e "${YELLOW}⚠${NC} BLE.sh loader function not found"
    fi
}

# Function to test fuzzy commands
function test_fuzzy_commands() {
    echo -e "\n${CYAN}=== Testing Fuzzy Commands ====${NC}"
    
    # Source bashrc
    source "$SENTINEL_DIR/bashrc" 2>/dev/null || true
    
    # Test fuzzy module files
    if [[ -f "$SENTINEL_DIR/bash_modules.d/suggestions/fuzzy_correction.module" ]]; then
        echo -e "${GREEN}✓${NC} Fuzzy correction module exists"
        
        # Source the fuzzy module directly
        if [[ -f "$SENTINEL_DIR/bash_modules.d/suggestions/fuzzy_correction.module" ]]; then
            source "$SENTINEL_DIR/bash_modules.d/suggestions/fuzzy_correction.module" 2>/dev/null
            
            # Check if any fuzzy functions are available
            if type sentinel_fuzzy_expand &>/dev/null; then
                echo -e "${GREEN}✓${NC} Fuzzy command functions are available"
            else
                echo -e "${YELLOW}⚠${NC} Fuzzy command functions not found after sourcing module"
            fi
        fi
    else
        echo -e "${YELLOW}⚠${NC} Fuzzy correction module not found"
    fi
    
    # Check if fuzzy is enabled in config
    if [[ -f "$SENTINEL_CONFIG" ]]; then
        if grep -q "SENTINEL_FUZZY_ENABLED=1" "$SENTINEL_CONFIG"; then
            echo -e "${GREEN}✓${NC} Fuzzy correction is enabled in configuration"
        else
            echo -e "${YELLOW}⚠${NC} Fuzzy correction may not be enabled in configuration"
        fi
    fi
}

# Function to test cybersecurity and ML features
function test_cybersec_ml() {
    echo -e "\n${CYAN}=== Testing Cybersecurity & ML Features ====${NC}"
    
    # Source bashrc
    source "$SENTINEL_DIR/bashrc" 2>/dev/null || true
    
    # Test ML modules
    if [[ -f "$SENTINEL_DIR/bash_modules.d/sentinel_ml.module" ]]; then
        echo -e "${GREEN}✓${NC} Machine learning module exists"
    else
        echo -e "${YELLOW}⚠${NC} Machine learning module not found"
    fi
    
    if [[ -f "$SENTINEL_DIR/bash_modules.d/sentinel_cybersec_ml.module" ]]; then
        echo -e "${GREEN}✓${NC} Cybersecurity ML module exists"
    else
        echo -e "${YELLOW}⚠${NC} Cybersecurity ML module not found"
    fi
    
    # Check for Python dependencies
    echo -e "\n${BLUE}Checking Python dependencies${NC}"
    python3 -c "import sys; print('Python version:', sys.version)" || echo -e "${YELLOW}⚠${NC} Python not available"
    python3 -c "import markovify; print('markovify version:', markovify.__version__)" 2>/dev/null || echo -e "${YELLOW}⚠${NC} markovify not installed"
    python3 -c "import numpy; print('numpy version:', numpy.__version__)" 2>/dev/null || echo -e "${YELLOW}⚠${NC} numpy not installed"
    
    # Check if ML modules are enabled in config
    if [[ -f "$SENTINEL_CONFIG" ]]; then
        if grep -q "SENTINEL_ML_ENABLED=1" "$SENTINEL_CONFIG"; then
            echo -e "${GREEN}✓${NC} ML module is enabled in configuration"
        else
            echo -e "${YELLOW}⚠${NC} ML module may not be enabled in configuration"
        fi
        
        if grep -q "SENTINEL_CYBERSEC_ENABLED=1" "$SENTINEL_CONFIG"; then
            echo -e "${GREEN}✓${NC} Cybersecurity ML module is enabled in configuration"
        else
            echo -e "${YELLOW}⚠${NC} Cybersecurity ML module may not be enabled in configuration"
        fi
    fi
}

# Function to test chat module
function test_chat_module() {
    echo -e "\n${CYAN}=== Testing Chat Module ====${NC}"
    
    # Source bashrc
    source "$SENTINEL_DIR/bashrc" 2>/dev/null || true
    
    # Test chat module file
    if [[ -f "$SENTINEL_DIR/bash_modules.d/sentinel_chat.module" ]]; then
        echo -e "${GREEN}✓${NC} Chat module exists"
    else
        echo -e "${YELLOW}⚠${NC} Chat module not found"
    fi
    
    # Check if modules enabled
    if [[ -f "$SENTINEL_CONFIG" ]]; then
        if grep -q "SENTINEL_CHAT_ENABLED=1" "$SENTINEL_CONFIG"; then
            echo -e "${GREEN}✓${NC} Chat module is enabled in configuration"
        else
            echo -e "${YELLOW}⚠${NC} Chat module may not be enabled in configuration"
        fi
    fi
    
    # Test if chat functions are available
    if type sentinel_chat &>/dev/null; then
        echo -e "${GREEN}✓${NC} sentinel_chat function is available"
    else
        echo -e "${YELLOW}⚠${NC} sentinel_chat function not found"
    fi
    
    if type sentinel_chat_status &>/dev/null; then
        echo -e "${BLUE}Testing chat status (non-blocking)${NC}"
        sentinel_chat_status &>/dev/null &
        echo -e "${GREEN}→${NC} Chat status command executed in background"
    else
        echo -e "${YELLOW}⚠${NC} sentinel_chat_status function not found"
    fi
}

# Function to test prompt rendering
function test_prompt() {
    echo -e "\n${CYAN}=== Testing Prompt Rendering ====${NC}"
    
    # Source bashrc and functions
    source "$SENTINEL_DIR/bashrc" 2>/dev/null || true
    
    # Test if prompt functions exist
    if type __set_prompt &>/dev/null; then
        echo -e "${GREEN}✓${NC} Prompt function exists"
    else
        echo -e "${YELLOW}⚠${NC} __set_prompt function not found"
    fi
    
    if type __git_info &>/dev/null; then
        echo -e "${GREEN}✓${NC} Git info function exists"
    else
        echo -e "${YELLOW}⚠${NC} __git_info function not found"
    fi
    
    if type __prompt_command_optimized &>/dev/null; then
        echo -e "${GREEN}✓${NC} Optimized prompt command exists"
    else
        echo -e "${YELLOW}⚠${NC} __prompt_command_optimized function not found"
    fi
    
    # Test prompt rendering (capture output)
    echo -e "\n${BLUE}Testing prompt rendering${NC}"
    echo -e "${YELLOW}Standard prompt:${NC}"
    if type __set_prompt &>/dev/null; then
        __set_prompt
        echo "$PS1" | sed 's/\\\[//g' | sed 's/\\\]//g'
    else
        echo -e "${YELLOW}⚠${NC} Cannot render standard prompt"
    fi
    
    echo -e "\n${YELLOW}Optimized prompt:${NC}"
    if type __prompt_command_optimized &>/dev/null; then
        __prompt_command_optimized
        echo "$PS1" | sed 's/\\\[//g' | sed 's/\\\]//g'
    else
        echo -e "${YELLOW}⚠${NC} Cannot render optimized prompt"
    fi
}

# Function to fix configuration file duplication
function fix_config_duplication() {
    echo -e "\n${CYAN}=== Resolving Configuration Files Duplication ====${NC}"
    
    # Path to both config files
    MAIN_CONFIG="${HOME}/.sentinel/sentinel_config.sh"
    SECONDARY_CONFIG="${SENTINEL_DIR}/bash_modules.d/suggestions/sentinel_config.sh"
    
    # Check if both files exist
    if [[ -f "$MAIN_CONFIG" && -f "$SECONDARY_CONFIG" ]]; then
        echo -e "${YELLOW}⚠${NC} Duplicate configuration files detected:"
        echo -e "  1. Main config: ${MAIN_CONFIG}"
        echo -e "  2. Secondary config: ${SECONDARY_CONFIG}"
        
        # Compare the files
        echo -e "\n${BLUE}Analyzing differences between config files${NC}"
        echo -e "${YELLOW}File difference summary:${NC}"
        if diff -q "$MAIN_CONFIG" "$SECONDARY_CONFIG" &>/dev/null; then
            echo -e "${GREEN}✓${NC} Files are identical in content"
        else
            echo -e "${YELLOW}⚠${NC} Files have different content"
            
            # Check which file is more complete
            MAIN_LINES=$(wc -l < "$MAIN_CONFIG")
            SECONDARY_LINES=$(wc -l < "$SECONDARY_CONFIG")
            
            echo -e "Main config has $MAIN_LINES lines"
            echo -e "Secondary config has $SECONDARY_LINES lines"
            
            # Check references in codebase
            echo -e "\n${BLUE}Checking references in codebase${NC}"
            MAIN_REFS=$(grep -r --include="*.sh" --include="*.module" "$MAIN_CONFIG" "$SENTINEL_DIR" | wc -l)
            SECONDARY_REFS=$(grep -r --include="*.sh" --include="*.module" "$SECONDARY_CONFIG" "$SENTINEL_DIR" | wc -l)
            
            echo -e "Main config referenced $MAIN_REFS times in code"
            echo -e "Secondary config referenced $SECONDARY_REFS times in code"
            
            # Determine which file to keep
            echo -e "\n${BLUE}Resolution recommendation${NC}"
            
            if [[ $MAIN_LINES -gt $SECONDARY_LINES && $MAIN_REFS -gt $SECONDARY_REFS ]]; then
                echo -e "${GREEN}→${NC} Keep the main config file, which is more complete and used in the codebase"
                
                # Make backup of secondary config
                BACKUP_FILE="${SECONDARY_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
                echo -e "${YELLOW}Creating backup of secondary config:${NC} $BACKUP_FILE"
                cp "$SECONDARY_CONFIG" "$BACKUP_FILE"
                
                # Create a symlink instead
                echo -e "${GREEN}→${NC} Creating symlink from secondary config to main config"
                if [[ -w "$(dirname "$SECONDARY_CONFIG")" ]]; then
                    ln -sf "$MAIN_CONFIG" "$SECONDARY_CONFIG"
                    echo -e "${GREEN}✓${NC} Created symlink: $SECONDARY_CONFIG -> $MAIN_CONFIG"
                else
                    echo -e "${RED}✗${NC} Cannot create symlink: no write permission"
                fi
            else
                echo -e "${YELLOW}⚠${NC} Manual analysis required to merge configurations"
                echo -e "Run this command to see detailed differences:"
                echo -e "diff -u \"$MAIN_CONFIG\" \"$SECONDARY_CONFIG\" | less"
            fi
        fi
    elif [[ -f "$MAIN_CONFIG" ]]; then
        echo -e "${GREEN}✓${NC} Only the main config file exists at: $MAIN_CONFIG"
    elif [[ -f "$SECONDARY_CONFIG" ]]; then
        echo -e "${YELLOW}⚠${NC} Only the secondary config file exists at: $SECONDARY_CONFIG"
        echo -e "${YELLOW}Missing main config at: $MAIN_CONFIG${NC}"
        
        # Create main config directory if needed
        if [[ ! -d "$(dirname "$MAIN_CONFIG")" ]]; then
            mkdir -p "$(dirname "$MAIN_CONFIG")"
        fi
        
        # Copy secondary to main
        echo -e "${GREEN}→${NC} Copying secondary config to main config location"
        cp "$SECONDARY_CONFIG" "$MAIN_CONFIG"
        
        # Create a symlink back
        echo -e "${GREEN}→${NC} Creating symlink to maintain compatibility"
        mv "$SECONDARY_CONFIG" "${SECONDARY_CONFIG}.original"
        ln -sf "$MAIN_CONFIG" "$SECONDARY_CONFIG"
        
        echo -e "${GREEN}✓${NC} Config consolidated to: $MAIN_CONFIG"
    else
        echo -e "${RED}✗${NC} No configuration file found at either location"
    fi
    
    # Check subdirectory module loading
    echo -e "\n${CYAN}=== Verifying Module Loading from Subdirectories ====${NC}"
    
    # Check if bash_modules handles subdirectories properly
    BASH_MODULES_FILE="${SENTINEL_DIR}/bash_modules"
    if [[ -f "$BASH_MODULES_FILE" ]]; then
        echo -e "${BLUE}Checking if bash_modules handles subdirectories${NC}"
        
        # Check if _load_all_modules function exists
        if grep -q "_load_all_modules" "$BASH_MODULES_FILE"; then
            echo -e "${GREEN}✓${NC} Found _load_all_modules function for recursive module loading"
        else
            echo -e "${YELLOW}⚠${NC} The _load_all_modules function wasn't found"
            echo -e "${YELLOW}⚠${NC} Subdirectory module loading might not be working correctly"
            echo -e "${YELLOW}⚠${NC} Please update bash_modules to include recursive module loading"
        fi
        
        # Check if find_all_modules function exists
        if grep -q "find_all_modules" "$BASH_MODULES_FILE"; then
            echo -e "${GREEN}✓${NC} Found find_all_modules function for recursive module discovery"
        else
            echo -e "${YELLOW}⚠${NC} The find_all_modules function wasn't found"
            echo -e "${YELLOW}⚠${NC} Subdirectory module discovery might not be working correctly"
        fi
    else
        echo -e "${RED}✗${NC} bash_modules file not found at ${BASH_MODULES_FILE}"
    fi
    
    # Check if bash_functions handles subdirectories properly
    BASH_FUNCTIONS_FILE="${SENTINEL_DIR}/bash_functions"
    if [[ -f "$BASH_FUNCTIONS_FILE" ]]; then
        echo -e "${BLUE}Checking if bash_functions handles subdirectories${NC}"
        
        # Check if loadRcDir has recursive parameter
        if grep -q "recursive=\"\${2:-0}\"" "$BASH_FUNCTIONS_FILE"; then
            echo -e "${GREEN}✓${NC} loadRcDir function supports recursive loading"
        else
            echo -e "${YELLOW}⚠${NC} loadRcDir function might not support recursive loading"
        fi
        
        # Check if loadRcDir is called with recursive flag
        if grep -qE "loadRcDir.*1" "$BASH_FUNCTIONS_FILE"; then
            echo -e "${GREEN}✓${NC} loadRcDir is called with recursive flag"
        else
            echo -e "${YELLOW}⚠${NC} loadRcDir might not be called with recursive flag"
        fi
    else
        echo -e "${RED}✗${NC} bash_functions file not found at ${BASH_FUNCTIONS_FILE}"
    fi
    
    # Check if bash_completion handles subdirectories properly
    BASH_COMPLETION_FILE="${SENTINEL_DIR}/bash_completion"
    if [[ -f "$BASH_COMPLETION_FILE" ]]; then
        echo -e "${BLUE}Checking if bash_completion handles subdirectories${NC}"
        
        # Check if load_completions_recursive function exists
        if grep -q "load_completions_recursive" "$BASH_COMPLETION_FILE"; then
            echo -e "${GREEN}✓${NC} Found load_completions_recursive function for recursive completion loading"
        else
            echo -e "${YELLOW}⚠${NC} Bash completion might not load from subdirectories"
        fi
    else
        echo -e "${RED}✗${NC} bash_completion file not found at ${BASH_COMPLETION_FILE}"
    fi
}

# Run all tests
echo -e "\n${CYAN}======== Starting SENTINEL Comprehensive Tests ========${NC}"

# Test core files and structure first
test_core_files

# Test module system
test_module_system

# Test lazy loading implementation
test_lazy_loading

# Fix configuration file duplication
fix_config_duplication

# Test bash completion
test_bash_completion

# Test fuzzy commands
test_fuzzy_commands

# Test cybersecurity and ML features
test_cybersec_ml

# Test chat module
test_chat_module

# Test prompt rendering
test_prompt

echo -e "\n${CYAN}======== SENTINEL Test Complete ========${NC}"

# Clean up temporary files
rm -f /tmp/sentinel_test_*.sh /tmp/sentinel_test_output

# Return success
exit 0 