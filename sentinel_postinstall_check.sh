#!/usr/bin/env bash
# SENTINEL Post-Install Module & Dependency Audit
# Audits enablement and dependency status of all SENTINEL modules after install
# Outputs a color-coded summary for user review
# (c) 2024 SWORDIntel

set -euo pipefail

# Color codes
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_blue=$'\033[1;34m'; c_reset=$'\033[0m'

SENTINEL_HOME="${HOME}/.sentinel"
POSTCUSTOM="${SENTINEL_HOME}/bashrc.postcustom"
MODULE_DIRS=("${HOME}/bash.modules.d")
LOG_FILE="${SENTINEL_HOME}/logs/postinstall_check.log"
: > "$LOG_FILE"

summary() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

summary "${c_blue}SENTINEL Post-Install Module & Dependency Audit${c_reset}"
summary "Checking all modules, enablement, and dependencies...\n"

# Helper: check if enabled in bashrc.postcustom
enabled_in_postcustom() {
    local var="$1"
    grep -q "^export $var=1" "$POSTCUSTOM" 2>/dev/null
}

# Helper: check python package in venv
venv_python_check() {
    local pkg="$1"
    "${SENTINEL_HOME}/venv/bin/python3" -c "import $pkg" 2>/dev/null
}

# Helper: check CLI tool
cli_check() {
    command -v "$1" &>/dev/null
}

# Scan all modules
for MODDIR in "${MODULE_DIRS[@]}"; do
    [[ -d "$MODDIR" ]] || continue
    find "$MODDIR" -type f \( -name '*.module' -o -name '*.sh' \) | while read -r modfile; do
        modname=$(basename "$modfile")
        enable_var=$(grep -Eo '\${SENTINEL_[A-Z0-9_]+_ENABLED' "$modfile" | head -n1 | sed 's/[${}]//g')
        requires=$(grep -E '^# Requires:' "$modfile" | cut -d: -f2- | xargs)
        enabled=0
        if [[ -n "$enable_var" ]]; then
            if enabled_in_postcustom "$enable_var"; then
                enabled=1
            fi
        fi
        if [[ $enabled -eq 1 ]]; then
            summary "${c_green}✔ $modname ENABLED ($enable_var)${c_reset}"
        else
            summary "${c_yellow}⚠ $modname DISABLED ($enable_var)${c_reset}"
        fi
        # Check dependencies
        if [[ -n "$requires" ]]; then
            for dep in $requires; do
                if [[ "$dep" =~ ^python ]]; then
                    pkg=${dep#python}
                    pkg=${pkg#,}
                    if venv_python_check "$pkg"; then
                        summary "    ${c_green}✔ Python: $pkg${c_reset}"
                    else
                        summary "    ${c_red}✖ Missing Python: $pkg${c_reset}"
                    fi
                else
                    if cli_check "$dep"; then
                        summary "    ${c_green}✔ CLI: $dep${c_reset}"
                    else
                        summary "    ${c_red}✖ Missing CLI: $dep${c_reset}"
                    fi
                fi
            done
        fi
        # Permissions
        perms=$(stat -c '%a' "$modfile")
        if [[ "$perms" != "600" ]]; then
            summary "    ${c_yellow}⚠ Permissions: $perms (should be 600)${c_reset}"
        fi
        summary ""
    done
    summary ""
done

summary "${c_blue}Audit complete. Review above for any ✖ or ⚠ warnings.${c_reset}\n"

# Count issues
errors=$(grep -c '✖' "$LOG_FILE" || true)
warnings=$(grep -c '⚠' "$LOG_FILE" || true)

# Print summary to terminal
printf "\n${c_blue}SENTINEL Post-Install Audit Summary${c_reset}\n"
printf "  ${c_red}✖ Errors:   %s${c_reset}\n" "$errors"
printf "  ${c_yellow}⚠ Warnings: %s${c_reset}\n" "$warnings"
printf "  Log file: %s\n" "$LOG_FILE"

# Print actionable next steps if issues found
if [[ $errors -gt 0 || $warnings -gt 0 ]]; then
    printf "\n${c_yellow}Review the above output for details. To fix most issues:${c_reset}\n"
    printf "  - Enable modules in ~/.sentinel/bashrc.postcustom\n"
    printf "  - Install missing Python packages in ~/.sentinel/venv\n"
    printf "  - Set file permissions to 600 for modules\n\n"
else
    printf "\n${c_green}No errors or warnings detected. SENTINEL is fully enabled!${c_reset}\n\n"
fi 