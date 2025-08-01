#!/usr/bin/env bash
# SENTINEL Installer - Helper Functions

# Colour helpers
c_red=$'\033[1;31m'
c_green=$'\033[1;32m'
c_yellow=$'\033[1;33m'
c_blue=$'\033[1;34m'
c_reset=$'\033[0m'

# Safe operation wrappers
safe_rsync() {
    if ! rsync "$@"; then
        fail "rsync operation failed: $*"
    fi
}

safe_cp() {
    if ! cp "$@"; then
        fail "cp operation failed: $*"
    fi
}

safe_mkdir() {
    local dir="$1"
    local perm="${2:-700}"  # Default permission 700 (user rwx only)

    if ! mkdir -p "$dir"; then
        fail "Failed to create directory: $dir"
        return 1
    fi

    # Set proper permissions
    chmod "$perm" "$dir" 2>/dev/null || {
        warn "Failed to set permissions $perm on directory: $dir"
    }

    ok "Created directory: $dir with permissions: $perm"
    return 0
}

# Robust error handler for fatal errors (security: prevents silent failures)
fail() {
    echo "${c_red}✖${c_reset}  $*" | tee -a "${LOG_DIR}/install.log" >&2
    echo "Run '${ROLLBACK_SCRIPT}' to restore previous configuration" >&2
    exit 1
}

# Success logger for status lines (security: ensures auditability)
ok() {
    echo "${c_green}✔${c_reset}  $*" | tee -a "${LOG_DIR}/install.log"
}

# Progress step logger for status lines (security: ensures auditability)
step() {
    echo "${c_blue}→${c_reset}  $*" | tee -a "${LOG_DIR}/install.log"
}

# Warning logger for non-fatal issues (security: ensures visibility of issues)
warn() {
    echo "${c_yellow}!${c_reset}  $*" | tee -a "${LOG_DIR}/install.log" >&2
}

# Enhanced logging with timestamp
log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="${LOG_DIR}/install.log"
    echo "[$timestamp] $*" | tee -a "$log_file"
}

# Secure git clone function with integrity checking
safe_git_clone() {
    local depth_arg=""
    local url=""
    local target_dir=""
    local expected_commit=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --depth=*)
                depth_arg="--depth=${1#*=}"
                shift
                ;;
            --depth)
                depth_arg="--depth=$2"
                shift 2
                ;;
            --verify-commit=*)
                expected_commit="${1#*=}"
                shift
                ;;
            *)
                if [[ -z "$url" ]]; then
                    url="$1"
                elif [[ -z "$target_dir" ]]; then
                    target_dir="$1"
                fi
                shift
                ;;
        esac
    done

    # Validate inputs
    if [[ -z "$url" || -z "$target_dir" ]]; then
        fail "safe_git_clone: URL and target directory are required"
    fi

    # Validate URL (basic security check)
    if ! [[ "$url" =~ ^https:// ]]; then
        fail "safe_git_clone: Only HTTPS URLs are allowed for security"
    fi

    # Validate target directory
    if [[ "$target_dir" =~ [[:space:]] ]]; then
        fail "safe_git_clone: Target directory cannot contain spaces"
    fi

    # If target exists and is a git repo, try to update it
    if [[ -d "$target_dir/.git" ]]; then
        step "Updating existing repository in $target_dir"
        git -C "$target_dir" fetch origin || fail "Failed to fetch updates"
        git -C "$target_dir" reset --hard origin/HEAD || fail "Failed to reset to origin"

        # Verify commit if specified
        if [[ -n "$expected_commit" ]]; then
            local actual_commit=$(git -C "$target_dir" rev-parse HEAD)
            if [[ "$actual_commit" != "$expected_commit"* ]]; then
                warn "Repository commit mismatch. Expected: $expected_commit, Got: $actual_commit"
                warn "This may indicate the repository has been updated. Proceeding with caution."
            else
                ok "Repository integrity verified"
            fi
        fi

        return 0
    fi

    # Clone the repository
    step "Cloning $url to $target_dir"
    if [[ -n "$depth_arg" ]]; then
        git clone "$depth_arg" "$url" "$target_dir" || fail "Clone failed"
    else
        git clone "$url" "$target_dir" || fail "Clone failed"
    fi

    # Verify the clone
    if [[ ! -d "$target_dir/.git" ]]; then
        fail "Repository was not cloned correctly"
    fi

    # Verify commit if specified
    if [[ -n "$expected_commit" ]]; then
        local actual_commit=$(git -C "$target_dir" rev-parse HEAD)
        if [[ "$actual_commit" != "$expected_commit"* ]]; then
            warn "Repository commit mismatch. Expected: $expected_commit, Got: $actual_commit"
            warn "This may indicate the repository has been updated. Proceeding with caution."
        else
            ok "Repository integrity verified"
        fi
    fi

    ok "Repository cloned successfully"
}
