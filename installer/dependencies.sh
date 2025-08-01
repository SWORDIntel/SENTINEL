#!/usr/bin/env bash
# SENTINEL Installer - Dependency Functions

# Python version check using Python itself (more reliable)
check_python_version() {
    step "Checking Python version"
    if ! command -v python3 &>/dev/null; then
        fail "Python 3 is not installed"
    fi

    if ! python3 -c "import sys; sys.exit(0 if sys.version_info >= (3,6) else 1)"; then
        local py_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        fail "Python 3.6+ is required (found ${py_version})"
    fi

    local py_version=$(python3 --version 2>&1 | cut -d' ' -f2)
    ok "Python ${py_version} meets requirements"
}

# Find Python executable (prioritize datascience environment)
find_python() {
    # First check if we're already in the datascience environment
    if [[ -n "${VIRTUAL_ENV:-}" ]] && [[ "$VIRTUAL_ENV" == *"datascience"* ]]; then
        if command -v python &>/dev/null; then
            echo "python"
            return 0
        fi
    fi

    # Check for custom compiled Python in datascience directory
    local datascience_pythons=(
        "${HOME}/datascience/envs/dsenv/bin/python"
        "${HOME}/datascience/envs/dsenv/bin/python3"
        "${HOME}/datascience/bin/python"
        "${HOME}/datascience/bin/python3"
    )

    for python_cmd in "${datascience_pythons[@]}"; do
        if [[ -x "$python_cmd" ]] && "$python_cmd" -c "import sys; sys.exit(0 if sys.version_info >= (3,6) else 1)" 2>/dev/null; then
            echo "$python_cmd"
            return 0
        fi
    done

    # Then check for the latest system Python versions
    for python_cmd in python3.12 python3.11 python3.10 python3.9 python3.8 python3.7 python3.6 python3; do
        if command -v "$python_cmd" &>/dev/null; then
            if "$python_cmd" -c "import sys; sys.exit(0 if sys.version_info >= (3,6) else 1)"; then
                echo "$python_cmd"
                return 0
            fi
        fi
    done
    return 1
}

parse_version() {
    echo "$1" | sed -e 's/\./ /g'
}

check_version() {
    local cmd_version_str
    cmd_version_str=$($1 --version | head -n1 | grep -oE '[0-9]+(\.[0-9]+)+')
    local required_version_str
    required_version_str=$2

    local cmd_version
    cmd_version=$(parse_version "$cmd_version_str")
    local required_version
    required_version=$(parse_version "$required_version_str")

    local i=0
    for n in $cmd_version; do
        i=$((i+1))
        local req_n
        req_n=$(echo "$required_version" | cut -d' ' -f$i)
        if [[ "$n" -gt "$req_n" ]]; then
            return 0
        fi
        if [[ "$n" -lt "$req_n" ]]; then
            return 1
        fi
    done
    return 0

}

check_dependency() {
    local cmd=$1
    local version=$2
    local url=$3

    if ! command -v "${cmd}" &>/dev/null; then
        fail "Missing system package: ${cmd}. Please install it from ${url} and re-run."
    fi

    if [[ -n "$version" ]]; then
        if ! check_version "${cmd}" "${version}"; then
            local cmd_version
            cmd_version=$($cmd --version | head -n1)
            fail "Unsupported ${cmd} version: ${cmd_version}. Please upgrade to version ${version} or later. You can download it from ${url}"
        fi
    fi
}

check_dependencies() {
    check_dependency "git" "2.7" "https://git-scm.com/"
    check_dependency "make" "3.81" "https://www.gnu.org/software/make/"
    check_dependency "awk" "" ""
    check_dependency "sed" "" ""
    check_dependency "rsync" "3.1" "https://rsync.samba.org/"
    check_dependency "pip3" "9.0" "https://pip.pypa.io/en/stable/installing/"
    ok "All required CLI tools present"
}

# Debian-specific package dependency checking
check_debian_dependencies() {
    if command -v apt-get &>/dev/null; then
      step "Detected Debian-based system, checking for additional dependencies"

      # Check for python3-venv which is not installed by default on Debian
      if ! dpkg -l python3-venv &>/dev/null; then
        warn "python3-venv package not detected. It's required for Python virtual environment creation."
        echo "Please install it with: sudo apt-get install python3-venv"

        if [[ $INTERACTIVE -eq 1 ]]; then
          read -r -t 30 -p "Would you like to install python3-venv package now? (requires sudo) [y/N]: " confirm || confirm="n"
          if [[ "$confirm" =~ ^[Yy]([Ee][Ss])?$ ]]; then
            sudo apt-get update && sudo apt-get install -y python3-venv || fail "Failed to install python3-venv"
            ok "Successfully installed python3-venv"
          else
            fail "python3-venv is required. Please install it and re-run the installer."
          fi
        else
          fail "python3-venv is required. Please install it and re-run the installer."
        fi
      fi

      # Check for other helpful packages
      OPTIONAL_PKGS=()
      command -v openssl &>/dev/null || OPTIONAL_PKGS+=("openssl")
      command -v fzf &>/dev/null || OPTIONAL_PKGS+=("fzf")

      if ((${#OPTIONAL_PKGS[@]})); then
        warn "Optional packages not found: ${OPTIONAL_PKGS[*]}"
        echo "These packages improve functionality but aren't strictly required."
        echo "You can install them with: sudo apt-get install ${OPTIONAL_PKGS[*]}"
      fi
    fi
}
