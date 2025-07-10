# Enable quiet output mode for less verbosity
export SENTINEL_QUIET_OUTPUT=1
# Silence SENTINEL module status messages
export SENTINEL_QUIET_STATUS=1
# Disable any terminal control sequences to improve stability
export SENTINEL_DISABLE_FANCY_OUTPUT=1
# Disable debug messages completely
export SENTINEL_DEBUG=0
alias gradle='/usr/local/bin/gradle'
# MINIMAL BASHRC with Step 1: Environment Variables and Path Handling
# This is a minimal .bashrc file with basic functionality

# Configuration options - Required for bashrc.postcustom
declare -A CONFIG=(
  # Core options
  [DEBUG]="${U_DEBUG:-0}"                   # Debug mode
  [LAZY_LOAD]="${U_LAZY_LOAD:-1}"          # Enable lazy loading
)

# Fast exit for non-interactive shells
case $- in
  *i*) ;;
    *) return;;
esac

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
if [[ -d "$HOME/bin" ]]; then
  PATH="$HOME/bin:$PATH"
fi

if [[ -d "$HOME/.local/bin" ]]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Add Go binary path
if [[ -d "$HOME/go/go/bin" ]]; then
  PATH="$HOME/go/go/bin:$PATH"
fi

# Clean up any duplicate entries
sanitize_path

# Ensure Python paths are available
if [[ -d "/usr/bin" ]] && [[ -x "/usr/bin/python3" ]]; then
    # Create python alias to python3 if python command doesn't exist
    if ! command -v python &>/dev/null; then
        alias python=python3
        echo "Aliased python to python3." >&1
    fi
fi

# Add common Python locations to PATH if they exist and are not already included
for python_dir_to_check in \
    "/usr/local/bin" \
    "/opt/python/bin" \
    "${HOME}/.local/bin"; do
    if [[ -d "$python_dir_to_check" ]] && [[ ":$PATH:" != *":$python_dir_to_check:"* ]]; then
        export PATH="$python_dir_to_check:$PATH"
        echo "Added $python_dir_to_check to PATH." >&1
    fi
done
# Re-sanitize PATH after potential additions
sanitize_path

# Basic prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Enhanced Bash settings and history handling
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

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Enhanced aliases with safety measures
# File operations
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# System info
alias df='df -h'
alias du='du -h'
alias free='free -m'

# Basic functions with error handling
# Enhanced cd with listing
cd() {
  # Use error handling to prevent crashes
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
  
  return 0  # Always return success to prevent terminal crashes
}

# Safe source function that won't crash the terminal
safe_source() {
  [[ -f "$1" ]] && { source "$1"; } 2>/dev/null || true
}

# Bash completion with error handling
if ! shopt -oq posix; then
  # Use error redirection to prevent terminal crashes
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

# Ultra-safe directory loading function that won't crash the terminal
safe_load_directory() {
  # Wrap everything in error handling
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
  
  # Always return success
  return 0
}

# Safe loading of custom configuration files
# Load pre-customization if it exists
if [[ -f ~/.bashrc.precustom ]]; then
  # Use safe_source with error handling to prevent terminal crashes
  echo "Loading precustom configuration..."
  safe_source ~/.bashrc.precustom
fi

# Safe module loading system
# Create directories for module cache if they don't exist
export SENTINEL_CACHE_DIR="${HOME}/cache"
mkdir -p "${SENTINEL_CACHE_DIR}/config" "${SENTINEL_CACHE_DIR}/modules" 2>/dev/null || true

# Simple module loading with robust error handling
_module_loaded=() # Track loaded modules to prevent duplicates

# Safe module loading function
load_module() {
  local module_name="$1"
  local module_path=""
  local max_depth=5 # Prevent infinite recursion
  local current_depth=0
  
  # Check if the module is already loaded
  for loaded in "${_module_loaded[@]}"; do
    if [[ "$loaded" == "$module_name" ]]; then
      return 0 # Already loaded, nothing to do
    fi
  done
  
  # Function to find and load a module
  _find_and_load_module() {
    local module="$1"
    local depth="$2"
    
    # Check recursion depth
    if ((depth > max_depth)); then
      echo "Warning: Maximum recursion depth reached when loading $module" >&2
      return 0 # Return success anyway to avoid crashing
    fi
    
    # Find the module file in standard locations
    local module_file=""
    local locations=(
      "/opt/github/SENTINEL/bash_modules.d/${module}.module"
      "$HOME/bash_modules.d/${module}.module"
      "$HOME/.bash_modules.d/${module}.module"
      "$HOME/Documents/GitHub/SENTINEL/bash_modules.d/${module}.module"
    )
    
    for location in "${locations[@]}"; do
      if [[ -f "$location" ]]; then
        module_file="$location"
        break
      fi
    done
    
    # If module not found, return success anyway to avoid crashes
    if [[ -z "$module_file" ]]; then
      echo "Warning: Module '$module' not found" >&2
      return 0
    fi
    
    # Source the module with error handling
    { source "$module_file"; } 2>/dev/null || {
      echo "Warning: Error loading module '$module'" >&2
      return 0 # Return success anyway to avoid crashing
    }
    
    # Mark as loaded to prevent duplicates
    _module_loaded+=("$module")
    
    return 0
  }
  
  # Load the module
  _find_and_load_module "$module_name" 0
  
  return 0 # Always return success to prevent crashes
}

# Function to load a list of enabled modules from a file
load_enabled_modules() {
  local modules_file="$1"
  
  # Check if the file exists
  if [[ ! -f "$modules_file" ]]; then
    echo "Warning: Modules list file '$modules_file' not found" >&2
    return 0 # Return success anyway to avoid crashes
  fi
  
  # Read the file line by line with error handling
  while IFS= read -r module || [[ -n "$module" ]]; do
    # Skip empty lines and comments
    [[ -z "$module" || "$module" == \#* ]] && continue
    
    # Load the module
    load_module "$module"
  done < "$modules_file" 2>/dev/null || {
    echo "Warning: Error reading modules file '$modules_file'" >&2
    return 0 # Return success anyway to avoid crashes
  }
  
  return 0 # Always return success to prevent crashes
}

# BLESH_ATTACH_METHOD="attach" # Removed as BLE.sh is no longer used

# Enable FZF module
export SENTINEL_FZF_ENABLED=1

# Guard variable to prevent duplicate module loading
export _SENTINEL_MODULES_LOADED=0

# Source the main bash_modules file to make module_list and other commands available
# Check multiple possible locations for bash_modules
for bash_modules_path in \
    "/opt/github/SENTINEL/bash_modules" \
    "$HOME/Documents/GitHub/SENTINEL/bash_modules" \
    "$HOME/bash_modules"; do
  if [[ -f "$bash_modules_path" ]]; then
    # Loading SENTINEL module management system silently
    # Set flag to prevent bash_modules from loading modules itself
    export SENTINEL_SKIP_AUTO_LOAD=1
    { source "$bash_modules_path"; } 2>/dev/null || {
      echo "Warning: Error loading bash_modules from $bash_modules_path" >&2
    }
    break
  fi
done

# Load critical modules with robust error handling - ONLY if not already loaded
if [[ "$_SENTINEL_MODULES_LOADED" == "0" ]]; then
  # Check if a modules list exists and load enabled modules
  if [[ -f "$HOME/.enabled_modules" ]]; then
    echo "Loading enabled modules from $HOME/.enabled_modules..."
    
    # Define module directory paths with fallbacks
    export SENTINEL_MODULES_PATH=${SENTINEL_MODULES_PATH:-"$HOME/bash_modules.d"}
    
    # Create an array of module directories to search in order
    module_dirs=(
      "/opt/github/SENTINEL/bash_modules.d"
      "$HOME/bash_modules.d"
      "$HOME/.bash_modules.d"
      "$HOME/Documents/GitHub/SENTINEL/bash_modules.d"
    )
    
    # Load enabled modules with proper dependency resolution
    load_enabled_modules "$HOME/.enabled_modules" 2>/dev/null || {
      echo "Error loading modules from .enabled_modules, trying critical modules only" >&2
      
      # Fallback: load critical modules directly if the enabled_modules loading fails
      for critical_module in "logging" "config_cache" "module_manager"; do
        echo "Loading critical module: $critical_module"
        load_module "$critical_module" 2>/dev/null || true
      done
    }
    
    # Mark modules as loaded
    export _SENTINEL_MODULES_LOADED=1
  fi
fi

# Alternatively, load these specific critical modules
# Only uncomment these if you need specific modules and they're not in your enabled_modules list

# Essential modules with known issues that have been fixed
# load_module "config_cache"    # Safe caching of configuration
# load_module "logging"        # Safe logging functionality
# load_module "fzf"           # Fuzzy finder integration

# Safe alternative to the problematic autocomplete module
# Disable completion system temporarily to stabilize terminal
# echo "Loading simple completion system..."
# if [[ -f "$HOME/simple_completion.sh" ]]; then
#   # Use direct full path and error handling
#   { source "$HOME/simple_completion.sh"; } 2>/dev/null || {
#     echo "Warning: Error loading simple completion, continuing anyway" >&2
#   }
# fi

# Enhanced direct module loading system with error handling
safe_load_direct_module() {
  local module="$1"
  local paths=(
    "/opt/github/SENTINEL/bash_modules.d/${module}.module"
    "$HOME/bash_modules.d/${module}.module"
    "$HOME/.bash_modules.d/${module}.module"
    "$HOME/Documents/GitHub/SENTINEL/bash_modules.d/${module}.module"
  )
  
    # Debug messages disabled for stability
  # echo "Looking for module: $module"
  
  for path in "${paths[@]}"; do
    if [[ -f "$path" ]]; then
      # Silent loading to reduce output
      # echo "Found module at: $path"
      # echo "Loading module: $module"
      { 
        # We'll use the . command instead of source for better compatibility
        . "$path" || true
      } 2>/dev/null || true
      return 0
    fi
  done
  
  echo "Module not found: $module" >&2
  return 0  # Return success anyway to prevent crashes
}

# Focus on core modules that are known to work well
# Loading basic bash completion silently
{ [[ -f /etc/bash_completion ]] && . /etc/bash_completion; } 2>/dev/null || true

# SENTINEL Module Loading Fix - prevents duplicate loading
# This associative array tracks which modules have been loaded
declare -A _SENTINEL_LOADED_MODULES

# Function to safely load a module only once
safe_load_module_once() {
  local module="$1"
  
  # Skip if already loaded
  if [[ "${_SENTINEL_LOADED_MODULES[$module]:-0}" == "1" ]]; then
    return 0
  fi
  
  # Find and load the module
  for dir in "/opt/github/SENTINEL/bash_modules.d" "$HOME/bash_modules.d" "$HOME/.bash_modules.d" "$HOME/Documents/GitHub/SENTINEL/bash_modules.d"; do
    if [[ -f "$dir/${module}.module" ]]; then
      echo "Loading module: $module (first time)"
      
      # Special case for FZF module
      [[ "$module" == "fzf" ]] && export SENTINEL_FZF_ENABLED=1
      
      # Special case for obfuscate module - set guard variable before loading
      [[ "$module" == "obfuscate" ]] && export _SENTINEL_OBFUSCATE_LOADED=1
      
      # Source with error handling
      { source "$dir/${module}.module"; } 2>/dev/null || true
      
      # Mark as loaded
      _SENTINEL_LOADED_MODULES[$module]=1
      return 0
    fi
  done
  
  echo "Module not found: $module" >&2
  return 0
}

# Load essential modules directly, avoiding the potentially problematic module manager
# Only load essential modules, avoiding those with terminal issues
safe_load_module_once "config_cache" 2>/dev/null
safe_load_module_once "logging" 2>/dev/null
safe_load_module_once "auto_install" 2>/dev/null # Added auto_install module

# Temporarily disable problematic modules
# safe_load_module_once "module_manager"
# safe_load_module_once "fzf"

# Note: This is a step-by-step rebuild of the .bashrc
# To reinstall SENTINEL properly after all issues are fixed, run:
#   cd ~/Documents/GitHub/SENTINEL && ./install.sh

# Source custom venv helpers
if [[ -f "$HOME/bash_functions.d/venv_helpers" ]]; then
    safe_source "$HOME/bash_functions.d/venv_helpers" 2>/dev/null || true
fi

# Safely evaluate brew shellenv only if brew exists
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "Warning: Homebrew not found at /home/linuxbrew/.linuxbrew/bin/brew. Skipping brew shellenv."
fi

# Data Science Environment Shortcut
datascience() {
    echo "Activating optimized data science environment..."

    # Activate virtual environment
    # Ensure the path to activate script is correct and accessible
    if [ -f ~/datascience/envs/dsenv/bin/activate ]; then
        source ~/datascience/envs/dsenv/bin/activate
    else
        echo "Warning: Data science virtual environment not found at ~/datascience/envs/dsenv/bin/activate"
    fi

    # Set optimization flags for AVX-512
    export CC=gcc
    export CXX=g++
    export FC=gfortran
    export CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer -flto"
    export CXXFLAGS="$CFLAGS"
    export FCFLAGS="$CFLAGS"
    export LDFLAGS="-Wl,-O3 -Wl,--as-needed -flto"
    # Ensure nproc is available, otherwise default to 1
    if command -v nproc &> /dev/null; then
        export NPY_NUM_BUILD_JOBS=$(nproc)
    else
        export NPY_NUM_BUILD_JOBS=1
    fi
    export RUSTFLAGS="-C target-cpu=native -C opt-level=3 -C lto=fat"

    # Set Arrow library path
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

    # Change to code directory
    if [ -d /opt/code ]; then
        cd /opt/code
    else
        echo "Warning: Code directory /opt/code not found."
    fi

    # Attempt to get Python version safely
    local python_version_info="Not found"
    if command -v python3 &> /dev/null; then # Check for python3 first
        python_version_info=$(python3 --version 2>&1 | cut -d' ' -f2 || echo "Error getting version")
    elif command -v python &> /dev/null; then # Fallback to python if python3 not found (e.g. if alias is not set yet or in a different env)
        python_version_info=$(python --version 2>&1 | cut -d' ' -f2 || echo "Error getting version")
    fi

    # Attempt to get NumPy version safely using python3
    local numpy_version_info="Not found"
    if command -v python3 &> /dev/null && python3 -c 'import numpy' &> /dev/null; then
        numpy_version_info=$(python3 -c 'import numpy; print(numpy.__version__)' 2>/dev/null || echo "Error getting version")
    fi

    echo "Environment activated! Python $python_version_info"
    echo "NumPy: $numpy_version_info"
    echo "Working directory: $(pwd)"
}

# OpenVINO 2025.2.0 Environment
# Ensure setupvars.sh exists before sourcing
if [ -f /usr/local/setupvars.sh ]; then
    source /usr/local/setupvars.sh
else
    echo "Warning: OpenVINO setup script not found at /usr/local/setupvars.sh"
fi

# Also set NPU environment variable for Meteor Lake
export ZE_ENABLE_NPU_DRIVER=1

# Add Level Zero library path
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
zfssnapshot() {
  # Check if a snapshot name prefix is provided
  if [ -z "$1" ]; then
    echo "Usage: zfssnapshot <snapshot_name_prefix>"
    return 1
  fi

  PREFIX="$1"
  # IMPORTANT: Determine the correct POOL_NAME and DATASET_PATH for your system.
  # These are common defaults but might need adjustment.
  POOL_NAME="rpool"
  DATASET_PATH="${POOL_NAME}/ROOT/LONENOMAD"
  DATETIME=$(date +"%m-%d-%Y-%H%M")
  SNAPSHOT_NAME="${DATASET_PATH}@${PREFIX}${DATETIME}"

  echo "Creating snapshot: ${SNAPSHOT_NAME}"
  # Ensure you have sudo privileges for these commands, or run as root.
  # You might need to configure passwordless sudo for these specific commands
  # if you intend to run this as a non-root user without password prompts.
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

source ~/datascience/envs/dsenv/bin/activate
alias @aliases='alias'

# Load postcustom configuration if it exists
# Check multiple locations for flexibility
# Ensure this is one of the last things done in bashrc
echo "Checking for bashrc.postcustom..." >&1
for postcustom_file in \
    "$(dirname "${BASH_SOURCE[0]}")/bashrc.postcustom" \
    "${HOME}/bashrc.postcustom" \
    "${HOME}/.bashrc.postcustom"; do
    if [[ -f "$postcustom_file" ]]; then
        echo "Loading postcustom configuration from: $postcustom_file" >&1
        # Use safe_source if available, otherwise regular source
        if command -v safe_source &> /dev/null; then
            safe_source "$postcustom_file"
        else
            source "$postcustom_file"
        fi
        # Create a signal file for testing
        touch /tmp/postcustom_loaded.signal 2>/dev/null || true
        echo "bashrc.postcustom loaded. Signal file /tmp/postcustom_loaded.signal created." >&1
        break
    fi
done
echo "Finished checking for bashrc.postcustom." >&1
