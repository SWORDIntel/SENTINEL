#!/usr/bin/env bash
###############################################################################
# SENTINEL – Framework post-installation test suite
# -----------------------------------------------
# v1.0.0 • 2025-05-17
# Performs comprehensive testing of all SENTINEL components
# to verify successful installation and proper functioning
###############################################################################

set -euo pipefail

# Define color codes for output formatting
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; 
c_blue=$'\033[1;34m'; c_purple=$'\033[1;35m'; c_cyan=$'\033[1;36m'; c_reset=$'\033[0m'

# Define paths
VENV_DIR="${HOME}/venv"
MODULES_DIR="${HOME}/bash_modules.d"
TEST_LOG="${HOME}/logs/post_install_test.log"

# Ensure log directory exists
mkdir -p "${HOME}/logs"

# Test functions
log() { printf '[%(%F %T)T] %b\n' -1 "$*" | tee -a "${TEST_LOG}"; }
header() { 
    echo
    log "${c_purple}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${c_reset}"
    log "${c_purple}▓▓▓             ${c_reset} ${c_cyan}$1${c_reset} ${c_purple}             ▓▓▓${c_reset}"
    log "${c_purple}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${c_reset}"
    echo
}
pass() { log "${c_green}[PASS]${c_reset} $*"; }
fail() { log "${c_red}[FAIL]${c_reset} $*"; FAILED_TESTS=$((FAILED_TESTS + 1)); }
warn() { log "${c_yellow}[WARN]${c_reset} $*"; }
info() { log "${c_blue}[INFO]${c_reset} $*"; }

# Initialize counter for failed tests
FAILED_TESTS=0
TOTAL_TESTS=0

# Run a test and record results
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local expected_status="${3:-0}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    info "Running test: $test_name"
    
    # Execute the test command
    if eval "$test_cmd" > /dev/null 2>&1; then
        local actual_status=0
    else
        local actual_status=1
    fi
    
    # Check if the test passed
    if [[ $actual_status -eq $expected_status ]]; then
        pass "$test_name"
        return 0
    else
        fail "$test_name"
        return 1
    fi
}

# Begin test suite
header "SENTINEL Post-Installation Test Suite"
log "Running comprehensive tests to verify SENTINEL installation"
log "Test results will be logged to: ${TEST_LOG}"
: > "${TEST_LOG}"  # Clear log file

###############################################################################
# 1. File system checks
###############################################################################
header "File System Structure Tests"

# Check critical directories
for dir in "${HOME}/autocomplete" "${MODULES_DIR}" "${VENV_DIR}"; do
    run_test "Directory exists: $dir" "[[ -d \"$dir\" ]]"
done

# Check critical files
run_test "BLE.sh loader exists" "[[ -f \"${HOME}/blesh_loader.sh\" ]]"
run_test "bashrc.postcustom exists" "[[ -f \"${HOME}/bashrc.postcustom\" ]]"
run_test "Autocomplete script exists" "[[ -f \"${HOME}/bash_aliases.d/autocomplete\" ]]"
run_test ".bash_modules exists" "[[ -f \"${HOME}/.bash_modules\" ]]"

# Check permissions
run_test "Logs directory has secure permissions" "stat -c %a \"${HOME}/logs\" | grep -E '^700$'"
run_test "Autocomplete script is executable" "stat -c %a \"${HOME}/bash_aliases.d/autocomplete\" | grep -E '^700$'"

###############################################################################
# 2. Python environment checks
###############################################################################
header "Python Virtual Environment Tests"

run_test "Python venv exists" "[[ -f \"${VENV_DIR}/bin/python3\" ]]"
run_test "pip is installed in venv" "[[ -f \"${VENV_DIR}/bin/pip\" ]]"

# Test imports for key Python packages
for pkg in numpy markovify tqdm unidecode rich; do
    run_test "Python package $pkg is installed" "\"${VENV_DIR}/bin/python3\" -c \"import $pkg\" 2>/dev/null"
done

###############################################################################
# 3. Bash integration checks
###############################################################################
header "Bash Integration Tests"

run_test "SENTINEL inclusion in .bashrc" "grep -q 'SENTINEL Framework Integration' \"${HOME}/.bashrc\""
run_test "VENV_AUTO is enabled" "grep -q 'export VENV_AUTO=1' \"${HOME}/bashrc.postcustom\""

###############################################################################
# 4. Module checks
###############################################################################
header "Module Installation Tests"

# Check for essential modules
for module in autocomplete.module fuzzy_correction.module snippets.module; do
    run_test "Module exists: $module" "[[ -f \"${MODULES_DIR}/$module\" ]]"
done

###############################################################################
# 5. BLE.sh checks
###############################################################################
header "BLE.sh Installation Tests"

run_test "BLE.sh is installed" "[[ -d \"${HOME}/.local/share/blesh\" ]]"
run_test "BLE.sh main script exists" "[[ -f \"${HOME}/.local/share/blesh/ble.sh\" ]]"
run_test "BLE.sh cache directory exists" "[[ -d \"${HOME}/.cache/blesh\" ]]"

###############################################################################
# 6. Functionality checks (basic)
###############################################################################
header "Basic Functionality Tests"

# Create a simple test script for sourcing
TEST_SCRIPT=$(mktemp)
cat > "$TEST_SCRIPT" << 'EOT'
#!/usr/bin/env bash
source "${HOME}/bashrc.postcustom" 2>/dev/null
command -v @autocomplete >/dev/null 2>&1
EOT
chmod +x "$TEST_SCRIPT"

run_test "Can source bashrc.postcustom" "bash \"$TEST_SCRIPT\""
rm -f "$TEST_SCRIPT"

###############################################################################
# 7. Security checks
###############################################################################
header "Security Checks"

run_test "No world-writable files in bash_modules.d" "! find \"${HOME}/bash_modules.d\" -type f -perm -o=w -print | grep -q ."
run_test "No world-writable directories in bash_modules.d" "! find \"${HOME}/bash_modules.d\" -type d -perm -o=w -print | grep -q ."

###############################################################################
# Final summary
###############################################################################
header "Test Results Summary"

if [[ $FAILED_TESTS -eq 0 ]]; then
    log "${c_green}All tests passed successfully!${c_reset} ($TOTAL_TESTS/$TOTAL_TESTS)"
    log "SENTINEL appears to be correctly installed and configured."
else
    log "${c_red}Some tests failed.${c_reset} ($((TOTAL_TESTS - FAILED_TESTS))/$TOTAL_TESTS passed, $FAILED_TESTS failed)"
    log "Please review the failed tests above and check the log file at: ${TEST_LOG}"
    log "You may need to run reinstall.sh to fix these issues."
fi

log ""
log "Next steps:"
log "1. Restart your terminal or run: source ${HOME}/bashrc.postcustom"
log "2. Verify autocomplete with: @autocomplete status"
log "3. If you encounter issues, run: @autocomplete fix"

exit $FAILED_TESTS 