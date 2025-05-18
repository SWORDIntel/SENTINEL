#!/usr/bin/env bash
###############################################################################
# SENTINEL – Comprehensive Test Suite
# -----------------------------------------------
# v1.0.0 • 2025-05-17
# Runs all available test and verification scripts
# and generates a comprehensive report
###############################################################################

set -euo pipefail

# Define color codes for output formatting
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; 
c_blue=$'\033[1;34m'; c_purple=$'\033[1;35m'; c_cyan=$'\033[1;36m'; c_reset=$'\033[0m'

# Define paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SENTINEL_HOME="${HOME}/.sentinel"
REPORT_DIR="${SENTINEL_HOME}/logs"
REPORT_FILE="${REPORT_DIR}/test_suite_report_$(date +%Y%m%d_%H%M%S).log"

# Ensure report directory exists
mkdir -p "${REPORT_DIR}"

# Helper functions
log() { printf '[%(%F %T)T] %b\n' -1 "$*" | tee -a "${REPORT_FILE}"; }
header() {
    echo
    log "${c_purple}=================================================================${c_reset}"
    log "${c_purple}=== ${c_reset}${c_cyan}$1${c_reset}${c_purple} ===${c_reset}"
    log "${c_purple}=================================================================${c_reset}"
    echo
}
subheader() {
    log "${c_yellow}---------------------------------------------------------------${c_reset}"
    log "${c_yellow}--- ${c_reset}$1${c_yellow} ---${c_reset}"
    log "${c_yellow}---------------------------------------------------------------${c_reset}"
}

# Print initial banner
echo "${c_green}"
echo " ██████ ███████ ███    ██ ████████ ██ ███    ██ ███████ ██      "
echo "██      ██      ████   ██    ██    ██ ████   ██ ██      ██      "
echo "███████ █████   ██ ██  ██    ██    ██ ██ ██  ██ █████   ██      "
echo "     ██ ██      ██  ██ ██    ██    ██ ██  ██ ██ ██      ██      "
echo "███████ ███████ ██   ████    ██    ██ ██   ████ ███████ ███████ "
echo "                                                                "
echo "████████ ███████ ███████ ████████    ███████ ██    ██ ██ ████████ ███████ "
echo "   ██    ██      ██         ██       ██      ██    ██ ██    ██    ██      "
echo "   ██    █████   ███████    ██       ███████ ██    ██ ██    ██    █████   "
echo "   ██    ██           ██    ██            ██ ██    ██ ██    ██    ██      "
echo "   ██    ███████ ███████    ██       ███████  ██████  ██    ██    ███████ "
echo "${c_reset}"

# Start recording
log "Starting SENTINEL comprehensive test suite"
log "Report will be saved to: ${REPORT_FILE}"
log "Date/time: $(date)"
log "User: $(whoami)"
log "Host: $(hostname)"
log "SENTINEL directory: ${SENTINEL_HOME}"

# Array to track test scripts and their results
declare -a TEST_SCRIPTS=("sentinel_post_install_test.sh" "sentinel_verify_installation.sh")
declare -a TEST_RESULTS=()
declare -a TEST_EXIT_CODES=()

# Verify test scripts exist
MISSING_SCRIPTS=0
for script in "${TEST_SCRIPTS[@]}"; do
    if [[ ! -f "${SCRIPT_DIR}/${script}" ]]; then
        log "${c_red}ERROR:${c_reset} Test script not found: ${script}"
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
    fi
done

if [[ $MISSING_SCRIPTS -gt 0 ]]; then
    log "${c_red}ERROR:${c_reset} $MISSING_SCRIPTS test scripts are missing. Cannot proceed."
    exit 1
fi

# Make sure all test scripts are executable
for script in "${TEST_SCRIPTS[@]}"; do
    chmod +x "${SCRIPT_DIR}/${script}"
done

# Run each test script and record results
for i in "${!TEST_SCRIPTS[@]}"; do
    script="${TEST_SCRIPTS[$i]}"
    script_path="${SCRIPT_DIR}/${script}"
    
    header "Running test script: ${script}"
    log "Executing: ${script_path}"
    
    # Create a temporary file to capture output
    TEMP_OUTPUT=$(mktemp)
    
    # Run the test script
    ${script_path} | tee "${TEMP_OUTPUT}" || true
    exit_code=${PIPESTATUS[0]}
    TEST_EXIT_CODES[$i]=$exit_code
    
    # Extract the last 10 lines for summary
    summary=$(tail -n 10 "${TEMP_OUTPUT}")
    
    # Record the result
    if [[ $exit_code -eq 0 ]]; then
        TEST_RESULTS[$i]="${c_green}PASSED${c_reset}"
    else
        TEST_RESULTS[$i]="${c_red}FAILED${c_reset} (exit code: $exit_code)"
    fi
    
    subheader "Summary for ${script}"
    log "$(echo "$summary" | grep -v '^\s*$')"
    log "Result: ${TEST_RESULTS[$i]}"
    
    # Remove temporary file
    rm -f "${TEMP_OUTPUT}"
done

# Generate final report
header "Test Suite Summary"

# Calculate overall status
FAILED_TESTS=0
for exit_code in "${TEST_EXIT_CODES[@]}"; do
    if [[ $exit_code -ne 0 ]]; then
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
done

# Display individual test results
log "Individual Test Results:"
for i in "${!TEST_SCRIPTS[@]}"; do
    log "  ${TEST_SCRIPTS[$i]}: ${TEST_RESULTS[$i]}"
done

# Display overall status
log ""
if [[ $FAILED_TESTS -eq 0 ]]; then
    log "${c_green}╔═════════════════════════════════════════════╗${c_reset}"
    log "${c_green}║ ALL TESTS PASSED - SENTINEL IS READY TO USE ║${c_reset}"
    log "${c_green}╚═════════════════════════════════════════════╝${c_reset}"
else
    log "${c_red}╔═══════════════════════════════════════════════════════╗${c_reset}"
    log "${c_red}║ $FAILED_TESTS TEST(S) FAILED - SENTINEL NEEDS ATTENTION ║${c_reset}"
    log "${c_red}╚═══════════════════════════════════════════════════════╝${c_reset}"
fi

# Display next steps
log ""
log "Next steps:"
if [[ $FAILED_TESTS -eq 0 ]]; then
    log "1. Start using SENTINEL by opening a new terminal"
    log "2. Use '@autocomplete' to access intelligent command completion"
    log "3. Python virtual environments will auto-activate when needed"
else
    log "1. Review the detailed logs in ${REPORT_DIR}"
    log "2. Run 'bash reinstall.sh' to perform a clean reinstallation"
    log "3. If issues persist, check for filesystem permissions or conflicts"
fi

log ""
log "Test suite completed at: $(date)"

# Exit with status based on the number of failed tests
exit $FAILED_TESTS 