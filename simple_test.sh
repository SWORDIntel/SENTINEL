#!/usr/bin/env bash
# SENTINEL Unified Comprehensive Test Script
# Merges all major module, BLE.sh, snippet, TTY, and environment tests
# Version: 3.0.0

set -euo pipefail
trap 'echo -e "\033[0;31m[ERROR]\033[0m Error on line $LINENO"; exit 1' ERR

# Color setup
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

SENTINEL_DIR="$(pwd)"

# Banner
cat <<EOF
${BLUE}
███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗      
██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║      
███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║      
╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║      
███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗ 
╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝ 
${NC}${GREEN}Unified Comprehensive Test Script${NC}\nEOF

# =====================
# Common Fixes Section
# =====================
log "\n=== Common Fixes for Frequent Problems ==="

FIXES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/contrib"
INTEGRATION_FIX="$FIXES_DIR/integration/fix_blesh.sh"
LINE_ENDINGS_FIX="$FIXES_DIR/fix_line_endings.sh"
TTY_FIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fix_tty.sh"

fix_menu() {
    echo -e "${YELLOW}Select a fix to apply:${NC}"
    echo "  1) Fix BLE.sh integration"
    echo "  2) Fix line endings in Bash files"
    echo "  3) Reset TTY state"
    echo "  4) Apply ALL fixes"
    echo "  0) Continue without fixes"
    echo -n "Enter your choice [0-4]: "
    read -r fix_choice
    case "$fix_choice" in
        1)
            run_fix_blesh
            ;;
        2)
            run_fix_line_endings
            ;;
        3)
            run_fix_tty
            ;;
        4)
            run_fix_blesh
            run_fix_line_endings
            run_fix_tty
            ;;
        0)
            log "No fixes applied."
            ;;
        *)
            log_warn "Invalid choice. No fixes applied."
            ;;
    esac
}

run_fix_blesh() {
    if [[ -x "$INTEGRATION_FIX" ]]; then
        log "Running BLE.sh integration fix..."
        bash "$INTEGRATION_FIX"
        log_success "BLE.sh integration fix completed."
    else
        log_error "BLE.sh integration fix script not found or not executable: $INTEGRATION_FIX"
    fi
}

run_fix_line_endings() {
    if [[ -x "$LINE_ENDINGS_FIX" ]]; then
        log "Running line endings fix..."
        bash "$LINE_ENDINGS_FIX"
        log_success "Line endings fix completed."
    else
        log_error "Line endings fix script not found or not executable: $LINE_ENDINGS_FIX"
    fi
}

run_fix_tty() {
    if [[ -x "$TTY_FIX" ]]; then
        log "Running TTY state fix..."
        bash "$TTY_FIX"
        log_success "TTY state fix completed."
    else
        log_error "TTY fix script not found or not executable: $TTY_FIX"
    fi
}

# --- Auto-detect common issues and suggest fixes ---
BLESH_PATH="$HOME/.local/share/blesh/ble.sh"
BLESH_LOADER="$HOME/.sentinel/blesh_loader.sh"

NEED_BLESH_FIX=0
if [[ ! -f "$BLESH_PATH" ]] || [[ ! -f "$BLESH_LOADER" ]]; then
    log_warn "BLE.sh or its loader not found. BLE.sh integration fix is recommended."
    NEED_BLESH_FIX=1
fi

NEED_LINE_FIX=0
if find . -type f \( -name "*.sh" -o -name ".bash*" -o -name "bash_*" \) -exec grep -Il $'\r' {} + | grep -q .; then
    log_warn "Some shell scripts have CRLF (Windows) line endings. Line endings fix is recommended."
    NEED_LINE_FIX=1
fi

# TTY state is hard to auto-detect, always offer as a fix
NEED_TTY_FIX=1

if (( NEED_BLESH_FIX || NEED_LINE_FIX || NEED_TTY_FIX )); then
    fix_menu
else
    log_success "No common problems detected that require fixes."
fi

# Logging
log() { echo -e "${CYAN}[SENTINEL TEST]${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }

# Section: Core File and Module System Tests
log "Testing core files and module system..."
for file in bashrc bash_aliases bash_functions bash_completion bash_modules; do
    if [[ -f "$SENTINEL_DIR/$file" ]]; then
        log_success "Found core file: $file"
    else
        log_error "Missing core file: $file"
    fi
done

if [[ -d "$SENTINEL_DIR/bash_modules.d" ]]; then
    log_success "Module directory exists"
    module_count=$(find "$SENTINEL_DIR/bash_modules.d" -type f -name "*.module" | wc -l)
    log "Found $module_count module files"
else
    log_error "Module directory does not exist"
fi

# Section: BLE.sh Installation, Loader, and TTY Tests
log "\n=== BLE.sh Installation, Loader, and TTY Tests ==="

# Source installer module if available
INSTALLER_MODULE="$SENTINEL_DIR/bash_modules.d/blesh_installer.module"
if [[ -f "$INSTALLER_MODULE" ]]; then
    source "$INSTALLER_MODULE"
    log_success "Sourced blesh_installer.module"
else
    log_warn "blesh_installer.module not found, skipping installer tests"
fi

# Test uninstall and reinstall
if type -t uninstall_blesh &>/dev/null; then
    uninstall_blesh || log_warn "Uninstall failed (may not be installed)"
    log_success "Uninstall function ran"
fi
if type -t blesh_installer_main &>/dev/null; then
    blesh_installer_main || log_error "BLE.sh install failed"
    log_success "BLE.sh installed"
fi

# Loader test
if [[ -f "$BLESH_LOADER" ]]; then
    source "$BLESH_LOADER" && log_success "BLE.sh loader sourced" || log_error "BLE.sh loader failed"
else
    log_warn "BLE.sh loader script not found"
fi

# TTY fix test (from fix_blesh_tty.sh logic)
log "\n--- TTY State Fix Test ---"
stty sane; stty cooked; stty echo
if [[ -f "$BLESH_PATH" ]]; then
    # Patch and test detach function
    if ! grep -q "function ble-detach-sentinel" "$BLESH_PATH"; then
        cat >> "$BLESH_PATH" << 'EOL'
# SENTINEL patched detach function with comprehensive TTY fixes
function ble-detach-sentinel {
  local _saved_tty
  _saved_tty=$(stty -g 2>/dev/null || true)
  stty sane 2>/dev/null || true
  builtin eval -- "${_ble_detach_hook-}"
  ble/base/unload
  if [[ -n "$_saved_tty" ]]; then
    stty "$_saved_tty" 2>/dev/null || stty sane
  else
    stty sane; stty cooked; stty echo
  fi
  tput reset 2>/dev/null || true
}
function ble-detach { ble-detach-sentinel "$@"; }
EOL
        log_success "Patched BLE.sh detach function for TTY fixes"
    fi
    stty sane; stty cooked; stty echo
    log_success "TTY state reset"
else
    log_warn "BLE.sh not found for TTY patching"
fi

# Section: BLE.sh Loader and Option Tests (from test_blesh.sh, test_new_loader.sh)
log "\n--- BLE.sh Loader and Option Tests ---"
if [[ -f "$BLESH_PATH" ]]; then
    if source "$BLESH_PATH" --attach 2>/dev/null; then
        log_success "BLE.sh loaded with --attach"
    elif source "$BLESH_PATH" 2>/dev/null; then
        log_success "BLE.sh loaded without options"
    else
        log_error "Failed to load BLE.sh directly"
    fi
    bleopt | grep complete || log_warn "No 'complete' options found"
    bleopt | grep highlight || log_warn "No 'highlight' options found"
    bleopt complete_auto_delay=100
    bleopt complete_auto_complete=1
    log_success "BLE.sh options set"
else
    log_warn "BLE.sh not found for loader/option tests"
fi

# Section: Autocomplete and Fuzzy Correction Tests
log "\n=== Autocomplete and Fuzzy Correction Tests ==="
if [[ -d ~/.cache/blesh ]]; then rm -rf ~/.cache/blesh/*; fi
mkdir -p ~/.cache/blesh
if [[ -f ~/.sentinel/minimal_autocomplete.sh ]]; then
    source ~/.sentinel/minimal_autocomplete.sh
fi
if [[ -f ./bash_aliases.d/autocomplete ]]; then
    source ./bash_aliases.d/autocomplete && log_success "Autocomplete module loaded"
    if type -t @autocomplete &>/dev/null; then
        @autocomplete status || log_warn "@autocomplete status failed"
    fi
else
    log_warn "Autocomplete module not found"
fi

# Section: Snippet Management and Security Tests
log "\n=== Snippet Management and Security Tests ==="
SNIPPET_MODULE="$SENTINEL_DIR/bash_modules.d/snippets.module"
if [[ -f "$SNIPPET_MODULE" ]]; then
    source "$SNIPPET_MODULE"
    if type -t sentinel_snippet_list &>/dev/null; then
        sentinel_snippet_list || log_warn "Snippet list failed"
    fi
    if type -t sentinel_snippet_add &>/dev/null; then
        sentinel_snippet_add test_snip 'echo "Hello, Snippet!"' && log_success "Snippet add test passed" || log_warn "Snippet add failed"
        sentinel_snippet_show test_snip || log_warn "Snippet show failed"
        sentinel_snippet_delete test_snip && log_success "Snippet delete test passed" || log_warn "Snippet delete failed"
    fi
else
    log_warn "snippets.module not found"
fi

# Section: Cybersecurity, ML, and Chat Module Tests
log "\n=== Cybersecurity, ML, and Chat Module Tests ==="
if [[ -f "$SENTINEL_DIR/bash_modules.d/sentinel_ml.module" ]]; then
    log_success "ML module exists"
else
    log_warn "ML module not found"
fi
if [[ -f "$SENTINEL_DIR/bash_modules.d/sentinel_cybersec_ml.module" ]]; then
    log_success "Cybersecurity ML module exists"
else
    log_warn "Cybersecurity ML module not found"
fi
python3 -c "import sys; print('Python version:', sys.version)" || log_warn "Python not available"
python3 -c "import markovify; print('markovify version:', markovify.__version__)" 2>/dev/null || log_warn "markovify not installed"
python3 -c "import numpy; print('numpy version:', numpy.__version__)" 2>/dev/null || log_warn "numpy not installed"

# Section: Prompt and Bash Environment Tests
log "\n=== Prompt and Bash Environment Tests ==="
if type __set_prompt &>/dev/null; then
    __set_prompt; log_success "Prompt function exists"
else
    log_warn "__set_prompt function not found"
fi
if type __git_info &>/dev/null; then
    __git_info; log_success "Git info function exists"
else
    log_warn "__git_info function not found"
fi
if type __prompt_command_optimized &>/dev/null; then
    __prompt_command_optimized; log_success "Optimized prompt command exists"
else
    log_warn "__prompt_command_optimized function not found"
fi

# Section: Comprehensive Module Load and Functionality Tests
log "\n=== Comprehensive Module Load and Functionality Tests ==="
MODULES_DIR="$SENTINEL_DIR/bash_modules.d"
MODULE_FILES=("$MODULES_DIR"/*.module)

for module_file in "${MODULE_FILES[@]}"; do
    module_name=$(basename "$module_file")
    log "Testing module: $module_name"
    # Existence
    if [[ -f "$module_file" ]]; then
        log_success "Module file exists: $module_name"
    else
        log_error "Module file missing: $module_name"
        continue
    fi
    # Permissions
    perms=$(stat -c %a "$module_file")
    if [[ "$perms" =~ ^6[04]4$|^600$ ]]; then
        log_success "Permissions are secure ($perms)"
    else
        log_warn "Permissions may be insecure ($perms)"
    fi
    # Source in subshell to avoid polluting main shell
    (
        set +e
        if source "$module_file"; then
            log_success "Sourced $module_name without errors"
            # Check for key functions/aliases for known modules
            case "$module_name" in
                sentinel_context.module)
                    for fn in sentinel_context sentinel_show_context sentinel_update_context sentinel_smart_suggest; do
                        if type -t "$fn" &>/dev/null; then
                            log_success "$fn function available"
                        else
                            log_warn "$fn function missing"
                        fi
                    done
                    ;;
                sentinel_ml_enhanced.module)
                    for fn in sentinel_predict sentinel_fix sentinel_task sentinel_translate sentinel_script sentinel_explain; do
                        if type -t "$fn" &>/dev/null; then
                            log_success "$fn function available"
                        else
                            log_warn "$fn function missing"
                        fi
                    done
                    ;;
                sentinel_ml.module)
                    for fn in sentinel_ml_setup sentinel_ml_train; do
                        if type -t "$fn" &>/dev/null; then
                            log_success "$fn function available"
                        else
                            log_warn "$fn function missing"
                        fi
                    done
                    ;;
                sentinel_cybersec_ml.module)
                    # No specific function, just check for enablement
                    if [[ "${SENTINEL_CYBERSEC_ENABLED:-0}" == "1" ]]; then
                        log_success "Cybersec ML module enabled"
                    else
                        log_warn "Cybersec ML module not enabled (set SENTINEL_CYBERSEC_ENABLED=1)"
                    fi
                    ;;
                *)
                    # For other modules, just check for successful sourcing
                    :
                    ;;
            esac
        else
            log_error "Failed to source $module_name"
        fi
    )
done

# Section: ML Module Python Dependency Checks
log "\n=== ML Module Python Dependency Checks ==="
python3 -c "import numpy, markovify" 2>/dev/null && log_success "numpy and markovify installed" || log_warn "numpy and/or markovify missing"
python3 -c "import llama_cpp" 2>/dev/null && log_success "llama-cpp-python installed" || log_warn "llama-cpp-python not installed (optional)"

# Section: Runtime Checks for All Module Functions
log "\n=== Runtime Checks for All Module Functions ==="
for module_file in "${MODULE_FILES[@]}"; do
    module_name=$(basename "$module_file")
    (
        set +e
        source "$module_file"
        case "$module_name" in
            sentinel_context.module)
                log "Testing runtime: sentinel_context"
                sentinel_context || log_warn "sentinel_context runtime failed"
                sentinel_show_context || log_warn "sentinel_show_context runtime failed"
                sentinel_update_context || log_warn "sentinel_update_context runtime failed"
                sentinel_smart_suggest "ls" || log_warn "sentinel_smart_suggest runtime failed"
                ;;
            sentinel_ml_enhanced.module)
                log "Testing runtime: sentinel_ml_enhanced"
                sentinel_predict "ls" || log_warn "sentinel_predict runtime failed"
                sentinel_fix "ls" || log_warn "sentinel_fix runtime failed"
                sentinel_task detect || log_warn "sentinel_task detect runtime failed"
                sentinel_translate "list all files" || log_warn "sentinel_translate runtime failed"
                sentinel_script /tmp/test_script.sh "echo test" || log_warn "sentinel_script runtime failed"
                sentinel_explain "ls -l" || log_warn "sentinel_explain runtime failed"
                ;;
            sentinel_ml.module)
                log "Testing runtime: sentinel_ml"
                sentinel_ml_setup || log_warn "sentinel_ml_setup runtime failed"
                sentinel_ml_train || log_warn "sentinel_ml_train runtime failed"
                ;;
            sentinel_cybersec_ml.module)
                log "Testing runtime: sentinel_cybersec_ml"
                # No direct runtime function, just check enablement
                if [[ "${SENTINEL_CYBERSEC_ENABLED:-0}" == "1" ]]; then
                    log_success "Cybersec ML module enabled at runtime"
                else
                    log_warn "Cybersec ML module not enabled at runtime"
                fi
                ;;
            *)
                # For other modules, no specific runtime test
                :
                ;;
        esac
    )
done

# Section: Full BLE.sh Installation and Integration Checks
log "\n=== Full BLE.sh Installation and Integration Checks ==="
BLESH_DIR="$HOME/.local/share/blesh"
BLESH_MAIN="$BLESH_DIR/ble.sh"
BLESH_LOADER="$HOME/.sentinel/blesh_loader.sh"

# 1. Check installation status
log "Checking BLE.sh installation directory: $BLESH_DIR"
if [[ -d "$BLESH_DIR" ]]; then
    log_success "BLE.sh directory exists"
    ls -la "$BLESH_DIR"
else
    log_error "BLE.sh directory missing"
fi

log "Checking BLE.sh loader script: $BLESH_LOADER"
if [[ -f "$BLESH_LOADER" ]]; then
    log_success "BLE.sh loader script exists"
    ls -la "$BLESH_LOADER"
else
    log_error "BLE.sh loader script missing"
fi

# 2. Check BLE.sh function availability
log "Checking BLE.sh function availability (bleopt)"
if type -t bleopt &>/dev/null; then
    log_success "bleopt function available"
    bleopt --version 2>/dev/null || log_warn "bleopt version check failed"
else
    log_warn "bleopt function not available before sourcing loader"
fi

# 3. Source loader and check again
log "Sourcing BLE.sh loader script"
if [[ -f "$BLESH_LOADER" ]]; then
    (
        set +e
        source "$BLESH_LOADER"
        if type -t bleopt &>/dev/null; then
            log_success "bleopt function available after sourcing loader"
            bleopt --version 2>/dev/null || log_warn "bleopt version check failed after loader"
        else
            log_error "bleopt function still not available after sourcing loader"
        fi
    )
else
    log_error "Cannot source missing BLE.sh loader script"
fi

# 4. Check for BLE.sh environment variables
log "Checking for BLE.sh-related environment variables"
env | grep -i ble && log_success "BLE.sh environment variables found" || log_warn "No BLE.sh environment variables found"

# 5. Check for conflicting Readline configurations
log "Checking for conflicting Readline configurations in ~/.inputrc"
if [[ -f "$HOME/.inputrc" ]]; then
    grep -i readline "$HOME/.inputrc" && log_warn "Potential Readline conflicts found in ~/.inputrc" || log_success "No Readline conflicts in ~/.inputrc"
else
    log_success "No ~/.inputrc file found"
fi

# 6. Check for conflicting shell settings in ~/.bashrc
log "Checking for conflicting shell settings in ~/.bashrc"
grep -v '^#' "$HOME/.bashrc" | grep -i readline && log_warn "Potential Readline conflicts found in ~/.bashrc" || log_success "No Readline conflicts in ~/.bashrc"

# 7. Check bash version for BLE.sh compatibility
log "Checking bash version for BLE.sh compatibility"
bash --version | head -n1

# 8. Find all ble.sh instances on the system
log "Finding all ble.sh instances in home directory"
find ~ -name "ble.sh" 2>/dev/null

# 9. Check BLE.sh uninstall cleanup
log "Checking for BLE.sh uninstall cleanup paths"
for path in "$HOME/.sentinel" "$HOME/.local/share/blesh" "$HOME/.cache/blesh" "$HOME/.blerc" "$HOME/.sentinel/blesh_loader.sh"; do
    if [[ -e "$path" ]]; then
        log_warn "Path still exists after uninstall: $path"
    else
        log_success "Path cleaned up: $path"
    fi
    # (This check is only meaningful after running uninstall)
done

# 10. Check BLE.sh integration with autocomplete
log "Checking BLE.sh integration with autocomplete module"
if type -t @autocomplete &>/dev/null; then
    @autocomplete status || log_warn "@autocomplete status failed"
else
    log_warn "@autocomplete function not available"
fi

# Section: Cleanup
log "\n=== Cleanup Temporary Files ==="
rm -f /tmp/sentinel_test_*.sh /tmp/sentinel_test_output /tmp/test_blesh_loader.sh /tmp/blesh_test_load.*
log_success "Temporary files cleaned up"

log "\n${GREEN}======== SENTINEL Unified Test Complete ========${NC}"
exit 0 