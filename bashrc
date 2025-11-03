#!/bin/bash
# MINIMAL BASHRC with proper organization and no duplicates
# Version: 2.1 - With AI/NPU Stack Integration

# SENTINEL_ROOT is expected to be set by the installer.
# If it's not set, we'll fall back to a reasonable default.
export SENTINEL_ROOT="${SENTINEL_ROOT:-$HOME/.sentinel}"

# ============================================================================
# SECTION 1: EARLY EXITS AND CORE SETUP
# ============================================================================

# Fast exit for non-interactive shells
case $- in
  *i*) ;;
    *) return;;
esac

# Configuration options
declare -A CONFIG=(
  [DEBUG]="${U_DEBUG:-0}"
  [LAZY_LOAD]="${U_LAZY_LOAD:-1}"
)

# Quiet mode environment variables (set early)
export SENTINEL_QUIET_OUTPUT=1
export SENTINEL_QUIET_STATUS=1
export SENTINEL_DISABLE_FANCY_OUTPUT=1
export SENTINEL_DEBUG=0

# ============================================================================
# SECTION 2: OS DETECTION AND CORE EXPORTS
# ============================================================================

# OS detection for platform-specific commands
case "$(uname -s)" in
  Linux*)  export OS_TYPE="Linux" ;;
  Darwin*) export OS_TYPE="MacOS" ;;
  CYGWIN*) export OS_TYPE="Cygwin" ;;
  MINGW*)  export OS_TYPE="MinGw" ;;
  *)       export OS_TYPE="Unknown" ;;
esac

# Editor and pager settings
export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"
export LESS="-R"

# ============================================================================
# SECTION 3: PATH MANAGEMENT
# ============================================================================

# Simple path sanitization function
sanitize_path() {
  # Safety check - ensure PATH is not empty
  if [[ -z "$PATH" ]]; then
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
    return 0
  fi

  # Simple deduplication without complex validation
  local path_parts=$(echo $PATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')

  # Use fallback if result is empty
  if [[ -z "$path_parts" ]]; then
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
  else
    export PATH="$path_parts"
  fi

  return 0
}

# Initialize with essential paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# Add user bin directories
[[ -d "$HOME/bin" ]] && PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/go/go/bin" ]] && PATH="$HOME/go/go/bin:$PATH"

# Add custom AI/ML build paths
[[ -d "$HOME/datascience/mtl/bin" ]] && PATH="$HOME/datascience/mtl/bin:$PATH"
[[ -d "$HOME/datascience" ]] && PATH="$HOME/datascience:$PATH"

# Add common Python locations
for python_dir in "/usr/local/bin" "${PYTHON_INSTALL_DIR:-/opt/python}/bin" "${HOME}/.local/bin"; do
    if [[ -d "$python_dir" ]] && [[ ":$PATH:" != *":$python_dir:"* ]]; then
        export PATH="$python_dir:$PATH"
    fi
done

# Clean up any duplicate entries
sanitize_path

# ============================================================================
# SECTION 4: PYTHON CONFIGURATION
# ============================================================================

# Ensure Python paths are available
if [[ -d "/usr/bin" ]] && [[ -x "/usr/bin/python3" ]]; then
    # Create python alias to python3 if python command doesn't exist
    if ! command -v python &>/dev/null; then
        alias python=python3
    fi
fi

# ============================================================================
# SECTION 5: SHELL OPTIONS AND HISTORY
# ============================================================================

# Basic prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# History configuration with security features
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
HISTIGNORE="ls:bg:fg:history:clear:exit:logout"
HISTTIMEFORMAT="%F %T "
shopt -s histappend

# Better shell behavior
shopt -s checkwinsize     # Update LINES/COLUMNS after each command
shopt -s extglob          # Extended pattern matching
shopt -s globstar 2>/dev/null  # ** for recursive matches
shopt -s no_empty_cmd_completion  # Don't complete when prompt is empty
shopt -s checkhash        # Check hash table before checking PATH
shopt -s autocd 2>/dev/null  # Change to named directory
shopt -s dirspell 2>/dev/null  # Correct directory spelling
shopt -s cdspell          # Correct minor spelling errors in cd
shopt -s direxpand 2>/dev/null  # Expand variables in directory completion

# Default file creation mask - slightly more restrictive
umask 027

# ============================================================================
# SECTION 6: COLOR SUPPORT AND ALIASES
# ============================================================================

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Core aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Grep aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# System info aliases
alias df='df -h'
alias du='du -h'
alias free='free -m'

# Special aliases

alias @aliases='alias'

# AI/ML Stack aliases
alias ai-env='source ~/datascience/activate_ai_env.sh'
alias npu-test='python ~/datascience/test_custom_openvino_npu.py'
alias ai-bench='python ~/datascience/benchmark_ai_stack.py'
alias numpy-p='~/datascience/numpy_select.py p'
alias numpy-e='~/datascience/numpy_select.py e'
alias numpy-auto='~/datascience/numpy_select.py auto'

# Benchmark shortcuts
alias bench-p='~/datascience/numpy_select.py p ~/datascience/benchmark_ai_stack.py'
alias bench-e='~/datascience/numpy_select.py e ~/datascience/benchmark_ai_stack.py'
alias bench-both='echo "[P-Core Benchmark]" && bench-p && echo -e "\n[E-Core Benchmark]" && bench-e'

# NPU monitoring
alias npu-status='ls -la /dev/accel/accel0 2>/dev/null && lsmod | grep intel_vpu'
alias npu-log='sudo dmesg | tail -50 | grep -E "(vpu|npu|accel)" | grep -v Bluetooth'

# ============================================================================
# SECTION 7: CORE FUNCTIONS
# ============================================================================

# Enhanced cd with listing
cd() {
  { builtin cd "$@" && ls; } 2>/dev/null || {
    echo "Error: Could not change to directory $@" >&2
    return 1
  }
}

# Extract various archive types
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.tar.gz)    tar xzf "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.bz2)       bunzip2 "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.rar)       unrar x "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.gz)        gunzip "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.tar)       tar xf "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.tbz2)      tar xjf "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.tgz)       tar xzf "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.zip)       unzip "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.Z)         uncompress "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *.7z)        7z x "$1" 2>/dev/null || echo "Error extracting $1" ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Create Python virtual environment with error handling
mkvenv() {
  local venv_name="${1:-venv}"
  local python_cmd="python3"

  # Check if Python is available
  if ! command -v $python_cmd &>/dev/null; then
    python_cmd="python"
    if ! command -v $python_cmd &>/dev/null; then
      echo "Error: Neither python3 nor python is available" >&2
      return 1
    fi
  fi

  # Check if virtualenv command exists, otherwise use venv module
  if command -v virtualenv &>/dev/null; then
    { virtualenv "$venv_name" 2>/dev/null || echo "Error creating virtualenv $venv_name" >&2; } &&
    echo "Created virtualenv: $venv_name (using virtualenv)"
  else
    # Try to create using the venv module with error handling
    { $python_cmd -m venv "$venv_name" 2>/dev/null || echo "Error creating venv $venv_name" >&2; } &&
    echo "Created virtualenv: $venv_name (using python -m venv)"
  fi

  # Provide activation instructions
  if [ -d "$venv_name" ]; then
    echo "Activate it with: source $venv_name/bin/activate"
  fi

  return 0
}

# Safe source function that won't crash the terminal
safe_source() {
  [[ -f "$1" ]] && { source "$1"; } 2>/dev/null || true
}

# Ultra-safe directory loading function
safe_load_directory() {
  {
    local dir="$1"
    local pattern="$2"

    # Skip if directory doesn't exist
    [[ ! -d "$dir" ]] && return 0

    # Use nullglob to prevent errors when no files match
    shopt -q nullglob && local NULLGLOB_WAS_SET=1 || local NULLGLOB_WAS_SET=0
    shopt -s nullglob

    # Simple, direct file listing - less error prone
    local files=("$dir"/$pattern)

    # Restore nullglob setting
    [[ "$NULLGLOB_WAS_SET" == "0" ]] && shopt -u nullglob

    # Source each file with comprehensive error handling
    local file
    for file in "${files[@]}"; do
      # Skip non-existent or non-file entries
      [[ ! -f "$file" ]] && continue

      # Use safe_source function
      safe_source "$file"
    done
  } 2>/dev/null || true

  return 0
}

# Data Science Environment Shortcut (Enhanced with AI Stack)
datascience() {
    echo "Activating optimized data science environment..."

    # Activate virtual environment
    if [ -f ~/datascience/envs/dsenv/bin/activate ]; then
        source ~/datascience/envs/dsenv/bin/activate
    else
        echo "Warning: Data science virtual environment not found at ~/datascience/envs/dsenv/bin/activate"
        return 1
    fi

    # Set optimization flags for Meteor Lake
    export CC=gcc
    export CXX=g++
    export FC=gfortran
    export CFLAGS="-march=alderlake -O3 -pipe -fomit-frame-pointer -flto"
    export CXXFLAGS="$CFLAGS"
    export FCFLAGS="$CFLAGS"
    export LDFLAGS="-Wl,-O3 -Wl,--as-needed -flto -fuse-ld=mold"

    # Set build jobs
    if command -v nproc &> /dev/null; then
        export NPY_NUM_BUILD_JOBS=$(nproc)
    else
        export NPY_NUM_BUILD_JOBS=1
    fi
    export RUSTFLAGS="-C target-cpu=native -C opt-level=3 -C lto=fat"

    # Custom AI/ML library paths
    export LD_LIBRARY_PATH="$HOME/datascience/mtl/lib:/usr/local/lib:$LD_LIBRARY_PATH"
    export PYTHONPATH="$HOME/datascience/mtl/lib/python3.13/site-packages:$PYTHONPATH"

    # NPU environment
    export ZE_ENABLE_NPU_DRIVER=1
    export NEO_CACHE_PERSISTENT=1
    export OV_NPU_COMPILER_TYPE=DRIVER
    export OV_NPU_PLATFORM=3800  # Meteor Lake

    # Change to code directory
    if [ -d "${CODE_DIR:-/opt/code}" ]; then
        cd "${CODE_DIR:-/opt/code}"
    else
        echo "Warning: Code directory ${CODE_DIR:-/opt/code} not found."
    fi

    # Get Python version safely
    local python_version_info="Not found"
    if command -v python3 &> /dev/null; then
        python_version_info=$(python3 --version 2>&1 | cut -d' ' -f2 || echo "Error getting version")
    elif command -v python &> /dev/null; then
        python_version_info=$(python --version 2>&1 | cut -d' ' -f2 || echo "Error getting version")
    fi

    # Get NumPy version safely
    local numpy_version_info="Not found"
    if command -v python3 &> /dev/null && python3 -c 'import numpy' &> /dev/null; then
        numpy_version_info=$(python3 -c 'import numpy; print(numpy.__version__)' 2>/dev/null || echo "Error getting version")
    fi

    # Get OpenVINO version safely
    local openvino_version_info="Not found"
    if command -v python3 &> /dev/null && python3 -c 'import openvino' &> /dev/null; then
        openvino_version_info=$(python3 -c 'import openvino; print(openvino.__version__)' 2>/dev/null || echo "Not installed")
    fi

    echo "Environment activated!"
    echo "Python: $python_version_info"
    echo "NumPy: $numpy_version_info"
    echo "OpenVINO: $openvino_version_info"
    echo "NPU: $([ -e /dev/accel/accel0 ] && echo 'Device present' || echo 'Not found')"
    echo "Working directory: $(pwd)"
}

# AI Stack Test Function
aitest() {
    echo "=== AI Stack Test ==="
    echo "[1] NPU Status Check"
    ls -la /dev/accel/accel0 2>/dev/null || echo "NPU device not found"
    lsmod | grep intel_vpu || echo "Intel VPU module not loaded"
    
    echo -e "\n[2] Library Check"
    echo -n "Custom Level Zero: "
    [ -f "$HOME/datascience/mtl/lib/libze_loader.so" ] && echo "Found" || echo "Not found"
    echo -n "NPU Plugin: "
    [ -f "$HOME/datascience/mtl/lib/libze_intel_npu.so" ] && echo "Found" || echo "Not found"
    
    echo -e "\n[3] Python Environment"
    python --version
    python -c "import numpy; print(f'NumPy: {numpy.__version__}')" 2>/dev/null || echo "NumPy not found"
    python -c "import openvino; print(f'OpenVINO: {openvino.__version__}')" 2>/dev/null || echo "OpenVINO not found"
    
    echo -e "\n[4] NPU Detection"
    python -c "import openvino as ov; print(f'Devices: {ov.Core().available_devices}')" 2>/dev/null || echo "Failed to detect devices"
}

# Benchmark helper function
aibench() {
    local mode="${1:-both}"
    
    case "$mode" in
        p|P|pcores)
            echo "[Running P-Core Benchmark (AVX-512)]"
            ~/datascience/numpy_select.py p ~/datascience/benchmark_ai_stack.py
            ;;
        e|E|ecores)
            echo "[Running E-Core Benchmark (AVX2)]"
            ~/datascience/numpy_select.py e ~/datascience/benchmark_ai_stack.py
            ;;
        both|all)
            echo "[Running Both P-Core and E-Core Benchmarks]"
            echo "=== P-Core (AVX-512) ==="
            ~/datascience/numpy_select.py p ~/datascience/benchmark_ai_stack.py
            echo -e "\n=== E-Core (AVX2) ==="
            ~/datascience/numpy_select.py e ~/datascience/benchmark_ai_stack.py
            ;;
        *)
            echo "Usage: aibench [p|e|both]"
            echo "  p/P/pcores - Run on P-cores only"
            echo "  e/E/ecores - Run on E-cores only"
            echo "  both/all   - Run on both (default)"
            ;;
    esac
}

# ZFS snapshot function
zfssnapshot() {
  # Check if zfs command is available
  if ! command -v zfs &> /dev/null; then
    echo "Error: zfs command not found. ZFS tools are not installed or not in PATH." >&2
    return 1
  fi

  # Check if a snapshot name prefix is provided
  if [ -z "$1" ]; then
    echo "Usage: zfssnapshot <snapshot_name_prefix>"
    return 1
  fi

  PREFIX="$1"
  POOL_NAME="rpool"
  DATASET_PATH="${POOL_NAME}/ROOT/LONENOMAD"
  DATETIME=$(date +"%m-%d-%Y-%H%M")
  SNAPSHOT_NAME="${DATASET_PATH}@${PREFIX}${DATETIME}"

  echo "Creating snapshot: ${SNAPSHOT_NAME}"

  sudo zfs snapshot "${SNAPSHOT_NAME}"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create snapshot ${SNAPSHOT_NAME}"
    return 1
  fi

  echo ""
  echo "Successfully created snapshot: ${SNAPSHOT_NAME}"
  echo ""
  echo "Listing available snapshots for ${DATASET_PATH} (newest first):"
  sudo zfs list -t snapshot -o name -S creation "${DATASET_PATH}"

  return 0
}

# ============================================================================
# SECTION 8: BASH COMPLETION
# ============================================================================

# Bash completion with error handling
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    { source /usr/share/bash-completion/bash_completion; } 2>/dev/null || true
  elif [[ -f /etc/bash_completion ]]; then
    { source /etc/bash_completion; } 2>/dev/null || true
  fi

  # Load personal completion settings if they exist
  if [[ -f ~/.bash_completion ]]; then
    { source ~/.bash_completion; } 2>/dev/null || true
  fi
fi

# ============================================================================
# SECTION 9: SENTINEL MODULE SYSTEM
# ============================================================================

# SENTINEL environment setup
export SENTINEL_CACHE_DIR="${HOME}/cache"
export SENTINEL_FZF_ENABLED=1
export SENTINEL_SKIP_AUTO_LOAD=1
export _SENTINEL_MODULES_LOADED=0

# Set MODULES_DIR for module installer scripts
export MODULES_DIR="${SENTINEL_ROOT}/bash_modules.d"

# Create cache directories
mkdir -p "${SENTINEL_CACHE_DIR}/config" "${SENTINEL_CACHE_DIR}/modules" 2>/dev/null || true

# Module tracking
_module_loaded=()
declare -A _SENTINEL_LOADED_MODULES

# Safe module loading function
safe_load_module_once() {
  local module="$1"

  # Skip if already loaded
  if [[ "${_SENTINEL_LOADED_MODULES[$module]:-0}" == "1" ]]; then
    return 0
  fi

  # Find and load the module
  for dir in "${SENTINEL_ROOT}/bash_modules.d" "$HOME/bash_modules.d" "$HOME/.bash_modules.d" "$HOME/Documents/GitHub/SENTINEL/bash_modules.d"; do
    if [[ -f "$dir/${module}.module" ]]; then
      # Special cases
      [[ "$module" == "fzf" ]] && export SENTINEL_FZF_ENABLED=1
      [[ "$module" == "obfuscate" ]] && export _SENTINEL_OBFUSCATE_LOADED=1

      # Source with error handling
      { source "$dir/${module}.module"; } 2>/dev/null || true

      # Mark as loaded
      _SENTINEL_LOADED_MODULES[$module]=1
      return 0
    fi
  done

  return 0
}

# Load module function
load_module() {
  local module_name="$1"

  # Check if already loaded
  for loaded in "${_module_loaded[@]}"; do
    if [[ "$loaded" == "$module_name" ]]; then
      return 0
    fi
  done

  # Find and load module
  local locations=(
    "${SENTINEL_ROOT}/bash_modules.d/${module_name}.module"
    "$HOME/bash_modules.d/${module_name}.module"
    "$HOME/.bash_modules.d/${module_name}.module"
    "$HOME/Documents/GitHub/SENTINEL/bash_modules.d/${module_name}.module"
  )

  for location in "${locations[@]}"; do
    if [[ -f "$location" ]]; then
      { source "$location"; } 2>/dev/null || return 0
      _module_loaded+=("$module_name")
      return 0
    fi
  done

  return 0
}

# Load enabled modules function
load_enabled_modules() {
  local modules_file="$1"

  if [[ ! -f "$modules_file" ]]; then
    return 0
  fi

  while IFS= read -r module || [[ -n "$module" ]]; do
    # Skip empty lines and comments
    [[ -z "$module" || "$module" == \#* ]] && continue

    # Load the module
    load_module "$module"
  done < "$modules_file" 2>/dev/null || return 0

  return 0
}

# ============================================================================
# SECTION 10: EXTERNAL TOOL INITIALIZATION
# ============================================================================

# Load precustom configuration if it exists
if [[ -f ~/.bashrc.precustom ]]; then
  safe_source ~/.bashrc.precustom
fi

# Source the main bash_modules file
for bash_modules_path in \
    "${SENTINEL_ROOT}/bash_modules" \
    "$HOME/Documents/GitHub/SENTINEL/bash_modules" \
    "$HOME/bash_modules"; do
  if [[ -f "$bash_modules_path" ]]; then
    { source "$bash_modules_path"; } 2>/dev/null || true
    break
  fi
done

# Load enabled modules
if [[ "$_SENTINEL_MODULES_LOADED" == "0" ]] && [[ -f "$HOME/.enabled_modules" ]]; then
  load_enabled_modules "$HOME/.enabled_modules" 2>/dev/null || {
    # Fallback: load critical modules directly in dependency order
    for critical_module in "logging" "config_cache" "module_manager"; do
      load_module "$critical_module" 2>/dev/null || true
    done
  }
  export _SENTINEL_MODULES_LOADED=1
fi

# Load essential modules directly
safe_load_module_once "logging" 2>/dev/null
safe_load_module_once "config_cache" 2>/dev/null
safe_load_module_once "auto_install" 2>/dev/null

# Source custom venv helpers
if [[ -f "$HOME/bash_functions.d/venv_helpers" ]]; then
    safe_source "$HOME/bash_functions.d/venv_helpers"
fi

# Initialize Homebrew if available
if [ -x "${HOMEBREW_PATH:-/home/linuxbrew/.linuxbrew/bin/brew}" ]; then
  eval "$("${HOMEBREW_PATH:-/home/linuxbrew/.linuxbrew/bin/brew}" shellenv)"
fi

# OpenVINO 2025.2.0 Environment
if [ -f "${OPENVINO_SETUPVARS:-/usr/local/setupvars.sh}" ]; then
    source "${OPENVINO_SETUPVARS:-/usr/local/setupvars.sh}"
fi

# Custom AI Stack Environment Setup
if [ -f ~/datascience/mtl/setup_npu_env.sh ]; then
    source ~/datascience/mtl/setup_npu_env.sh 2>/dev/null || true
fi

if [ -f ~/datascience/mtl/setup_openvino.sh ]; then
    source ~/datascience/mtl/setup_openvino.sh 2>/dev/null || true
fi

# Set NPU environment variable for Meteor Lake
export ZE_ENABLE_NPU_DRIVER=1
export NEO_CACHE_PERSISTENT=1
export OV_NPU_COMPILER_TYPE=DRIVER

# Add Level Zero library path
export LD_LIBRARY_PATH="$HOME/datascience/mtl/lib:/usr/local/lib:$LD_LIBRARY_PATH"

# Activate data science environment by default (as in original)
source ~/datascience/envs/dsenv/bin/activate 2>/dev/null || true

# ============================================================
# Meteor Lake C Toolchain - GCC 13.2.0
# ============================================================
if [ -f "${C_TOOLCHAIN_PATH:-/home/john/c-toolchain}/activate-enhanced.sh" ]; then
    source "${C_TOOLCHAIN_PATH:-/home/john/c-toolchain}/activate-enhanced.sh"
elif [ -f "${C_TOOLCHAIN_PATH:-/home/john/c-toolchain}/activate.sh" ]; then
    source "${C_TOOLCHAIN_PATH:-/home/john/c-toolchain}/activate.sh"
fi

# Quick aliases
alias mgcc='meteor-gcc 2>/dev/null || gcc'
alias mprofile='meteor_profile 2>/dev/null || echo "Enhanced features not installed"'

# Show toolchain info on login (optional)
if command -v gcc &> /dev/null; then
    echo "Toolchain: $(gcc --version | head -1)"
fi

# ============================================================================
# SECTION 11: POSTCUSTOM LOADING (LAST)
# ============================================================================

# Load postcustom configuration if it exists
for postcustom_file in \
    "$(dirname "${BASH_SOURCE[0]}")/bashrc.postcustom" \
    "${HOME}/bashrc.postcustom" \
    "${HOME}/.bashrc.postcustom"; do
    if [[ -f "$postcustom_file" ]]; then
        safe_source "$postcustom_file"
        # Create a signal file for testing
        touch /tmp/postcustom_loaded.signal 2>/dev/null || true
        break
    fi
done

# End of .bashrc
