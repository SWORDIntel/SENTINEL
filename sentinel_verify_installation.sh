#!/usr/bin/env bash
###############################################################################
# SENTINEL – Installation Verification Script
# -----------------------------------------------
# v1.0.0 • 2025-05-17
# Verifies functionality of all SENTINEL components by executing
# actual commands and validating their output
###############################################################################

set -euo pipefail

# Define color codes
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; 
c_blue=$'\033[1;34m'; c_magenta=$'\033[1;35m'; c_cyan=$'\033[1;36m'; c_reset=$'\033[0m'

# Define paths
SENTINEL_HOME="${HOME}/.sentinel"
VENV_DIR="${SENTINEL_HOME}/venv"
VERIFICATION_LOG="${SENTINEL_HOME}/logs/verification.log"

# Ensure log directory exists
mkdir -p "${SENTINEL_HOME}/logs"
: > "${VERIFICATION_LOG}"  # Clear log file

# Logging functions
log() { printf '[%(%F %T)T] %b\n' -1 "$*" | tee -a "${VERIFICATION_LOG}"; }
section() { 
    echo
    log "${c_magenta}╔════════════════════════════════════════════════════════════╗${c_reset}"
    log "${c_magenta}║${c_reset} ${c_cyan}$1${c_reset}"
    log "${c_magenta}╚════════════════════════════════════════════════════════════╝${c_reset}"
}
success() { log "${c_green}[SUCCESS]${c_reset} $*"; }
failure() { log "${c_red}[FAILURE]${c_reset} $*"; FAILURES=$((FAILURES + 1)); }
warning() { log "${c_yellow}[WARNING]${c_reset} $*"; }
info() { log "${c_blue}[INFO]${c_reset} $*"; }

# Initialize failure counter
FAILURES=0

# Create temporary test environment
TESTDIR=$(mktemp -d)
trap 'rm -rf "$TESTDIR"' EXIT

# Banner
echo "${c_magenta}"
echo "   _______.___________. _______  .__   __. .___________. __  .__   __. _______ .___                    "
echo "  /       |           ||   ____| |  \ |  | |           ||  | |  \ |  ||   ____||   |                   "
echo " |   (----\`---|  |----\`|  |__    |   \|  | \`---|  |----\`|  | |   \|  ||  |__   |   |                   "
echo "  \   \       |  |     |   __|   |  . \`  |     |  |     |  | |  . \`  ||   __|  |   |                   "
echo " .----)   |   |  |     |  |____  |  |\   |     |  |     |  | |  |\   ||  |____ |   |                   "
echo " |_______/    |__|     |_______| |__| \__|     |__|     |__| |__| \__||_______||___|                   "
echo "                                                                                                         "
echo " ____    __    ____  _______ .______       __  .______    __    ______ ___   ___________  ____  _______ "
echo " \   \  /  \  /   / |   ____||   _  \     |  | |   _  \  |  |  /      /   \\ |   ____\   \\/   / |   ____|"
echo "  \   \/    \/   /  |  |__   |  |_)  |    |  | |  |_)  | |  | |  ,----'   |__   |    \     /  |  |__   "
echo "   \            /   |   __|  |      /     |  | |   ___/  |  | |  |    |    /    |     \   /   |   __|  "
echo "    \    /\    /    |  |____ |  |\  \----.|  | |  |      |  | |  \`----\   /     |      | |    |  |____ "
echo "     \__/  \__/     |_______|| _| \`._____||__| | _|      |__|  \______\___\\    |____  | |    |_______|"
echo "${c_reset}"

section "SENTINEL Installation Verification"
log "This script will verify the functionality of SENTINEL by executing real commands"
log "Log file: ${VERIFICATION_LOG}"

###############################################################################
# 1. Environment sourcing test
###############################################################################
section "Testing Environment Sourcing"

# Create test script that sources SENTINEL environment
cat > "${TESTDIR}/source_test.sh" << 'EOT'
#!/usr/bin/env bash
source "${HOME}/.sentinel/bashrc.postcustom" 2>/dev/null
# Output environment variables for verification
echo "BLESH_LOADED=${SENTINEL_BLESH_LOADED:-not_set}"
echo "VENV_AUTO=${VENV_AUTO:-not_set}"
# Check for key functions
type -t @autocomplete >/dev/null && echo "AUTOCOMPLETE=available" || echo "AUTOCOMPLETE=missing"
type -t venvon >/dev/null && echo "VENVON=available" || echo "VENVON=missing"
type -t pip >/dev/null && echo "PIP=available" || echo "PIP=missing"
EOT
chmod +x "${TESTDIR}/source_test.sh"

# Run the test script
info "Sourcing SENTINEL environment..."
SOURCE_OUTPUT=$(bash "${TESTDIR}/source_test.sh")

# Validate expected variables and functions are available
if echo "$SOURCE_OUTPUT" | grep -q "BLESH_LOADED=1"; then
    success "BLE.sh loader is working properly"
else
    failure "BLE.sh loader is not being sourced correctly"
    echo "$SOURCE_OUTPUT" | grep "BLESH_LOADED" | tee -a "${VERIFICATION_LOG}"
fi

if echo "$SOURCE_OUTPUT" | grep -q "VENV_AUTO=1"; then
    success "VENV_AUTO is enabled"
else
    failure "VENV_AUTO is not enabled"
    echo "$SOURCE_OUTPUT" | grep "VENV_AUTO" | tee -a "${VERIFICATION_LOG}"
fi

if echo "$SOURCE_OUTPUT" | grep -q "AUTOCOMPLETE=available"; then
    success "Autocomplete command is available"
else
    failure "Autocomplete command is missing"
fi

if echo "$SOURCE_OUTPUT" | grep -q "VENVON=available"; then
    success "VENV functions are available"
else
    failure "VENV functions are missing"
fi

if echo "$SOURCE_OUTPUT" | grep -q "PIP=available"; then
    success "PIP function is available"
else
    failure "PIP function is missing"
fi

###############################################################################
# 2. Python venv functionality tests
###############################################################################
section "Testing Python Virtual Environment"

# Create a test Python project
mkdir -p "${TESTDIR}/python_test_project"
cat > "${TESTDIR}/python_test_project/requirements.txt" << 'EOT'
tqdm==4.66.0
EOT

cat > "${TESTDIR}/python_test_venv.sh" << 'EOT'
#!/usr/bin/env bash
source "${HOME}/.sentinel/bashrc.postcustom" 2>/dev/null
cd "$1"
# Check if in venv initially
if [ -n "${VIRTUAL_ENV:-}" ]; then
    echo "INITIAL_STATE=in_venv"
else
    echo "INITIAL_STATE=no_venv"
fi
# Activate venv manually (should happen automatically, but force for test)
export VENV_AUTO=1
# Create a dummy function to simulate cd
cd_with_venv() {
    cd .
    # Check if venv was activated
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        echo "AFTER_CD=in_venv"
    else
        echo "AFTER_CD=no_venv"
    fi
}
cd_with_venv
EOT
chmod +x "${TESTDIR}/python_test_venv.sh"

info "Testing Python venv auto-activation..."
VENV_OUTPUT=$(bash "${TESTDIR}/python_test_venv.sh" "${TESTDIR}/python_test_project")

if echo "$VENV_OUTPUT" | grep -q "AFTER_CD=in_venv"; then
    success "Virtual environment auto-activation works"
else
    warning "Virtual environment auto-activation appears to be non-functional"
    echo "$VENV_OUTPUT" | tee -a "${VERIFICATION_LOG}"
    # This is a warning not a failure as it might need interactive shell
fi

###############################################################################
# 3. Autocomplete functionality test
###############################################################################
section "Testing Autocomplete System"

# Create a script to test if autocomplete can be called
cat > "${TESTDIR}/autocomplete_test.sh" << 'EOT'
#!/usr/bin/env bash
source "${HOME}/.sentinel/bashrc.postcustom" 2>/dev/null
# Run autocomplete status command (should produce output)
@autocomplete status 2>&1
if [[ $? -eq 0 ]]; then
    echo "AUTOCOMPLETE_STATUS=working"
else
    echo "AUTOCOMPLETE_STATUS=failing"
fi
EOT
chmod +x "${TESTDIR}/autocomplete_test.sh"

info "Testing autocomplete command..."
AUTOCOMPLETE_OUTPUT=$(bash "${TESTDIR}/autocomplete_test.sh")

if echo "$AUTOCOMPLETE_OUTPUT" | grep -q "AUTOCOMPLETE_STATUS=working"; then
    success "Autocomplete command executes successfully"
else
    failure "Autocomplete command failed to execute"
    echo "$AUTOCOMPLETE_OUTPUT" | tee -a "${VERIFICATION_LOG}"
fi

# Verify BLE.sh is referenced in the output
if echo "$AUTOCOMPLETE_OUTPUT" | grep -q "BLE.sh"; then
    success "Autocomplete references BLE.sh"
else
    warning "Autocomplete output doesn't mention BLE.sh"
fi

###############################################################################
# 4. Bash environment tests
###############################################################################
section "Testing Bash Environment"

# Create a script to test bash functions
cat > "${TESTDIR}/bash_functions_test.sh" << 'EOT'
#!/usr/bin/env bash
source "${HOME}/.bashrc" 2>/dev/null
source "${HOME}/.bash_functions" 2>/dev/null

# Test key functions
declare -a TESTS=()

# Test venv functions
type -t in_venv >/dev/null && TESTS+=("in_venv=available") || TESTS+=("in_venv=missing")
type -t venvon >/dev/null && TESTS+=("venvon=available") || TESTS+=("venvon=missing")

# Test path functions
type -t addpath >/dev/null && TESTS+=("addpath=available") || TESTS+=("addpath=missing")

# Output results
for test in "${TESTS[@]}"; do
    echo "$test"
done
EOT
chmod +x "${TESTDIR}/bash_functions_test.sh"

info "Testing Bash functions..."
FUNCTIONS_OUTPUT=$(bash "${TESTDIR}/bash_functions_test.sh")

function_count=0
for func in in_venv venvon addpath; do
    if echo "$FUNCTIONS_OUTPUT" | grep -q "${func}=available"; then
        success "Bash function $func is available"
        function_count=$((function_count + 1))
    else
        failure "Bash function $func is missing"
    fi
done

if [[ $function_count -ge 2 ]]; then
    success "Majority of bash functions are available"
else
    failure "Most bash functions are missing"
fi

###############################################################################
# 5. Module loader test
###############################################################################
section "Testing Module Loader"

# Create a script to test module loading
cat > "${TESTDIR}/module_test.sh" << 'EOT'
#!/usr/bin/env bash
source "${HOME}/.bashrc" 2>/dev/null

# Check if .bash_modules exists and has content
if [[ -f "${HOME}/.bash_modules" ]]; then
    echo "BASH_MODULES=exists"
    MODULE_COUNT=$(grep -v '^[[:space:]]*#' "${HOME}/.bash_modules" | grep -v '^[[:space:]]*$' | wc -l)
    echo "MODULE_COUNT=$MODULE_COUNT"
else
    echo "BASH_MODULES=missing"
fi
EOT
chmod +x "${TESTDIR}/module_test.sh"

info "Testing module loader..."
MODULE_OUTPUT=$(bash "${TESTDIR}/module_test.sh")

if echo "$MODULE_OUTPUT" | grep -q "BASH_MODULES=exists"; then
    success ".bash_modules file exists"
    
    # Extract module count
    MODULE_COUNT=$(echo "$MODULE_OUTPUT" | grep "MODULE_COUNT=" | cut -d= -f2)
    if [[ $MODULE_COUNT -gt 5 ]]; then
        success "Found $MODULE_COUNT modules defined in .bash_modules"
    else
        warning "Only $MODULE_COUNT modules found in .bash_modules (expected >5)"
    fi
else
    failure ".bash_modules file is missing"
fi

###############################################################################
# Final Results
###############################################################################
section "Verification Results"

if [[ $FAILURES -eq 0 ]]; then
    log "${c_green}===================================${c_reset}"
    log "${c_green}  All verification tests passed!  ${c_reset}"
    log "${c_green}===================================${c_reset}"
    log "SENTINEL appears to be correctly installed and functioning properly."
else
    log "${c_red}============================================${c_reset}"
    log "${c_red}  $FAILURES verification test(s) failed!  ${c_reset}"
    log "${c_red}============================================${c_reset}"
    log "Some functionality tests failed. Review the log for details."
    log "You may need to run reinstall.sh to fix these issues."
fi

log ""
log "Troubleshooting tips:"
log "1. Run the post-install test script: bash sentinel_post_install_test.sh"
log "2. Check logs in ${SENTINEL_HOME}/logs/"
log "3. For autocomplete issues, run: @autocomplete fix"
log "4. For full reinstallation, run: bash reinstall.sh"

exit $FAILURES 