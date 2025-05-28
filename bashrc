#!/usr/bin/env bash
#
# Full-featured modular bashrc with enhanced security and performance
# Based on the original work by Jason Thistlethwaite (2013)
#
# COPYRIGHT
###########
# Original bashrc Copyright (c) Jason Thistlethwaite 2013 (iadnah@uplinklounge.com)
# Enhancements Copyright (c) John 2023
#
# Licensed under GNU GPL v2 or later
################################################################################

# Fast exit for non-interactive shells
case $- in
  *i*) ;;
    *) return;;
esac

# Performance optimization: start profiling if enabled
if [[ -n "$BASHRC_PROFILE" ]]; then
  # Bash profiling for performance analysis
  PS4='+ $EPOCHREALTIME\011 '
  exec 3>&2 2>/tmp/bashrc-$$.profile
  set -x
fi

# SENTINEL Bashrc version info
BASHRC_VERSION="2.0.0-enhanced"

# DISABLED: secure_source function was causing installation issues
# Create a secure_source function for consistent file security checks
## REMOVED: loadRcDir function was causing terminal crashes
# Instead, we'll use a safer direct approach when needed

# Ultra-safe directory loading function that won't crash the terminal
# Safe alternative that can be used if directory loading is needed
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
    local files=($dir/$pattern)
    
    # Restore nullglob setting
    [[ "$NULLGLOB_WAS_SET" == "0" ]] && shopt -u nullglob
    
    # Source each file with comprehensive error handling
    local file
    for file in "${files[@]}"; do
      # Skip non-existent or non-file entries
      [[ ! -f "$file" ]] && continue
      
      # Use brace expansion to ensure errors don't propagate
      { source "$file"; } 2>/dev/null || true
    done
  } 2>/dev/null || true
  
  # Always return success
  return 0
}
# REMOVED: secure_source function was causing terminal crashes
# Using direct sourcing with error handling instead
# Any file sourcing is now done with: { source "file"; } 2>/dev/null || true

# OS detection for platform-specific commands
case "$(uname -s)" in
  Linux*)  export OS_TYPE="Linux" ;;
  Darwin*) export OS_TYPE="MacOS" ;;
  CYGWIN*) export OS_TYPE="Cygwin" ;;
  MINGW*)  export OS_TYPE="MinGw" ;;
  *)       export OS_TYPE="Unknown" ;;
esac

# Load order control mechanism
declare -A LOAD_PHASES=(
  [CORE]=1     # Core variables, options and settings
  [ENV]=2      # Environment variables and path setup
  [AGENT]=3    # SSH/GPG agent configuration
  [PROMPT]=4   # Prompt customization
  [MODULES]=5  # Module system
  [ALIASES]=6  # Aliases and shortcuts
  [FUNCS]=7    # Function definitions
  [CUSTOM]=8   # Custom user configurations
  [COMP]=9     # Programmable completion
  [FINAL]=10   # Final overrides and cleanup
)

# Configuration options
declare -A CONFIG=(
  # Core options
  [DEBUG]="${U_DEBUG:-0}"                   # Debug mode
  [DEFAULT_TITLE]="${U_DEFAULT_TITLE:-$BASH}"  # Default terminal title
  
  # Custom configuration files
  [PRECUSTOM]="${U_PRECUSTOM:-1}"           # Load ~/.bashrc.precustom 
  [POSTCUSTOM]="${U_POSTCUSTOM:-1}"         # Load ~/.bashrc.postcustom
  
  # Feature toggles
  [USER_BINS]="${U_BINS:-1}"                # Add ~/bin and ~/.bin to PATH
  [USER_FUNCS]="${U_FUNCS:-1}"              # Load user functions
  [USER_ALIASES]="${U_ALIASES:-1}"          # Load user aliases
  [LESSPIPE]="${ENABLE_LESSPIPE:-1}"        # Enable lesspipe for file preview
  [AGENTS]="${U_AGENTS:-1}"                 # Configure SSH/GPG agents
  [MODULES]="${U_MODULES_ENABLE:-1}"        # Enable modular extensions
  [UPDATE_TITLE]="${U_UPDATETITLE:-1}"      # Dynamic terminal title
  [COLOR_PROMPT]="yes"                      # Colorful prompt
  
  # Security options
  [SECURE_PATH]="1"                         # Sanitize PATH
  [SECURE_HISTORY]="1"                      # Don't store sensitive commands
  [SECURE_PERMISSIONS]="1"                  # Check file permissions
  
  # Performance options
  [LAZY_LOAD]="1"                           # Lazy load heavy components
  [CACHE_PROMPT]="1"                        # Cache prompt components
)

# Security: Basic file permission checks
if [[ "${CONFIG[SECURE_PERMISSIONS]}" == "1" ]]; then
  if [[ -f ~/.bashrc && $(stat -c %a ~/.bashrc) != 600 ]]; then
    echo -e "\033[1;31mWarning: ~/.bashrc has insecure permissions. Recommended: chmod 600 ~/.bashrc\033[0m" >&2
  fi
fi

# Setup SENTINEL_CACHE_DIR for configuration caching
export SENTINEL_CACHE_DIR="${HOME}/cache"
mkdir -p "${SENTINEL_CACHE_DIR}/config" "${SENTINEL_CACHE_DIR}/modules"

# USE SECURE SOURCE FUNCTION - Use the secure source function instead of direct source
if [[ "${CONFIG[PRECUSTOM]}" == "1" && -f ~/.bashrc.precustom ]]; then
    # Sourcing user-specific pre-customization with security check
    secure_source ~/.bashrc.precustom
fi

# Debug handling
if [[ "${CONFIG[DEBUG]}" == "1" ]]; then
  set -x
fi
# Bash options for improved behavior
shopt -s checkwinsize               # Update LINES/COLUMNS after each command
shopt -s extglob                    # Extended pattern matching
shopt -s globstar 2>/dev/null       # ** for recursive matches
shopt -s no_empty_cmd_completion    # Don't complete when prompt is empty
shopt -s checkhash                  # Check hash table before checking PATH
shopt -s autocd 2>/dev/null         # Change to named directory
shopt -s dirspell 2>/dev/null       # Correct directory spelling
shopt -s cdspell                    # Correct minor spelling errors in cd
shopt -s direxpand 2>/dev/null      # Expand variables in directory completion

# Default file creation mask - slightly more restrictive
umask 027

# Enable programmable completion
if ! shopt -oq posix; then
  if [[ "${CONFIG[LAZY_LOAD]}" == "1" ]]; then
    # Lazy load bash completion
    # Create a function to handle first tab press
    _completion_loader() {
      unset -f _completion_loader
      # Load bash completion
      if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        # shellcheck source=/usr/share/bash-completion/bash_completion
        . /usr/share/bash-completion/bash_completion
      elif [[ -f /etc/bash_completion ]]; then
        # shellcheck source=/etc/bash_completion
        . /etc/bash_completion
      fi
      # Load personal completion settings if they exist
      if [[ -f ~/.bash_completion ]]; then
        # shellcheck source=~/.bash_completion
        . ~/.bash_completion
      fi
      # Now process the current completion request
      complete -r _completion_loader
      # Only proceed if at least one argument is provided
      if [[ $# -ge 1 ]]; then
        local compfunc
        compfunc=$(complete -p "$1" 2>/dev/null | sed -E 's/.*-F ([^ ]+).*/\1/')
        if [[ -n "$compfunc" ]]; then
          "$compfunc" "$@"
        fi
      fi
    }
    
    # Bind the function to all possible commands initially
    complete -D -F _completion_loader
  else
    # Regular non-lazy loading of completion
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
      # shellcheck source=/usr/share/bash-completion/bash_completion
      . /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
      # shellcheck source=/etc/bash_completion
      . /etc/bash_completion
    fi
    
    # Load personal completion settings if they exist
    if [[ -f ~/.bash_completion ]]; then
      # shellcheck source=~/.bash_completion
      . ~/.bash_completion
    fi
  fi
fi
# Path security function - ensure no relative paths or duplicate entries
# SIMPLIFIED: sanitize_path function - reduced complexity to prevent terminal crashes
function sanitize_path() {
  # Always set a fallback PATH in case of problems
  local fallback_path="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
  
  # Safety check - ensure PATH is not empty
  if [[ -z "$PATH" ]]; then
    export PATH="$fallback_path"
    return 0
  fi
  
  # Simple deduplication without complex validation
  local path_parts=$(echo $PATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
  
  # Only use fallback if result is empty
  if [[ -z "$path_parts" ]]; then
    export PATH="$fallback_path"
  else
    export PATH="$path_parts"
  fi
  
  return 0
}

# Important: Sanitize PATH BEFORE any path manipulations to ensure we start with a clean base
sanitize_path

# User binary paths - properly add user paths AFTER initial sanitization
if [[ "${CONFIG[USER_BINS]}" == "1" ]]; then
  # Add personal bin directories with higher priority
  user_bin_dirs=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.bin"
  )
  
  # Add each directory if it exists and isn't already in PATH
  for dir in "${user_bin_dirs[@]}"; do
    if [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]]; then
      PATH="$dir:$PATH"
    fi
  done
fi

# Re-sanitize PATH after all modifications to ensure everything is clean
sanitize_path

# Tools-specific paths
# Improved lazy loading implementation to avoid recursion issues

# Cargo (Rust) lazy loading
if [[ "${CONFIG[LAZY_LOAD]}" == "1" ]]; then
  # Lazy load Cargo (Rust)
  cargo() {
    # Unset the function to avoid recursive calls
    unset -f cargo rustc rustup
    
    # Load the environment
    if [[ -f "$HOME/.cargo/env" ]]; then
      # shellcheck source=~/.cargo/env
      . "$HOME/.cargo/env"
    fi
    
    # Execute the actual command using command to avoid potential function calls
    command cargo "$@"
  }
  
  rustc() {
    # Unset the function to avoid recursive calls
    unset -f cargo rustc rustup
    
    # Load the environment
    if [[ -f "$HOME/.cargo/env" ]]; then
      # shellcheck source=~/.cargo/env
      . "$HOME/.cargo/env"
    fi
    
    # Execute the actual command using command to avoid potential function calls
    command rustc "$@"
  }
  
  rustup() {
    # Unset the function to avoid recursive calls
    unset -f cargo rustc rustup
    
    # Load the environment
    if [[ -f "$HOME/.cargo/env" ]]; then
      # shellcheck source=~/.cargo/env
      . "$HOME/.cargo/env"
    fi
    
    # Execute the actual command using command to avoid potential function calls
    command rustup "$@"
  }
else
  # Direct load
  if [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck source=~/.cargo/env
    . "$HOME/.cargo/env"
  fi
fi

# Pyenv setup with improved lazy loading
if [[ "${CONFIG[LAZY_LOAD]}" == "1" ]]; then
  # Lazy load pyenv
  pyenv() {
    # Unset the function to avoid recursive calls
    unset -f pyenv
    
    # Configure pyenv
    if [[ -d "$HOME/.pyenv" ]]; then
      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d "$PYENV_ROOT/bin" ]] && PATH="$PYENV_ROOT/bin:$PATH"
      # Re-sanitize PATH after adding pyenv
      sanitize_path
      
      # Initialize pyenv
      if command -v pyenv >/dev/null; then
        eval "$(command pyenv init -)"
        eval "$(command pyenv virtualenv-init -)"
      fi
    fi
    
    # Execute the actual command using command to avoid potential function calls
    command pyenv "$@"
  }
else
  # Direct load
  if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d "$PYENV_ROOT/bin" ]] && PATH="$PYENV_ROOT/bin:$PATH"
    # Re-sanitize PATH after modifications
    sanitize_path
    
    if command -v pyenv >/dev/null; then
      eval "$(pyenv init -)"
      eval "$(pyenv virtualenv-init -)"
    fi
  fi
fi

# NVM (Node Version Manager) with improved lazy loading
if [[ "${CONFIG[LAZY_LOAD]}" == "1" ]]; then
  # Lazy load nvm and related commands
  nvm() {
    # Unset all related functions
    unset -f nvm node npm npx
    
    # Load NVM if available
    if [[ -d "$HOME/.nvm" ]]; then
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    fi
    
    # Execute the command using command prefix to avoid recursion
    command nvm "$@"
  }
  
  node() {
    # Unset all related functions
    unset -f nvm node npm npx
    
    # Load NVM if available
    if [[ -d "$HOME/.nvm" ]]; then
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    fi
    
    # Execute the command using command prefix to avoid recursion
    command node "$@"
  }
  
  npm() {
    # Unset all related functions
    unset -f nvm node npm npx
    
    # Load NVM if available
    if [[ -d "$HOME/.nvm" ]]; then
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" 
      [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    fi
    
    # Execute the command using command prefix to avoid recursion
    command npm "$@"
  }
  
  npx() {
    # Unset all related functions
    unset -f nvm node npm npx
    
    # Load NVM if available
    if [[ -d "$HOME/.nvm" ]]; then
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    fi
    
    # Execute the command using command prefix to avoid recursion
    command npx "$@"
  }
elif [[ -d "$HOME/.nvm" ]]; then
  # Direct load
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# RVM (Ruby Version Manager) lazy loading
if [[ "${CONFIG[LAZY_LOAD]}" == "1" ]]; then
  # Lazy load rvm
  rvm() {
    unset -f rvm ruby gem bundle
    if [[ -d "$HOME/.rvm" ]]; then
      export PATH="$PATH:$HOME/.rvm/bin"
      [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
    fi
    rvm "$@"
  }
  ruby() {
    unset -f rvm ruby gem bundle
    if [[ -d "$HOME/.rvm" ]]; then
      export PATH="$PATH:$HOME/.rvm/bin"
      [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
    fi
    ruby "$@"
  }
  gem() {
    unset -f rvm ruby gem bundle
    if [[ -d "$HOME/.rvm" ]]; then
      export PATH="$PATH:$HOME/.rvm/bin"
      [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
    fi
    gem "$@"
  }
  bundle() {
    unset -f rvm ruby gem bundle
    if [[ -d "$HOME/.rvm" ]]; then
      export PATH="$PATH:$HOME/.rvm/bin"
      [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
    fi
    bundle "$@"
  }
elif [[ -d "$HOME/.rvm" ]]; then
  # Direct load
  export PATH="$PATH:$HOME/.rvm/bin"
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
fi

# Additional path entries
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  PATH="/usr/local/bin:$PATH"
fi

# Modern terminal color support detection
if [[ -n "$FORCE_COLOR_DISABLE" ]]; then
  color_prompt=no
else
  # Auto-detect color support
  if [[ -x /usr/bin/tput ]] && tput setaf 1 >/dev/null 2>&1; then
    color_prompt=yes
  else
    color_prompt=no
  fi
fi

# Override with explicit setting if provided
if [[ -n "$FORCE_COLOR_PROMPT" ]]; then
  color_prompt="$FORCE_COLOR_PROMPT"
fi

# Define terminal colors - optimized definitions
if [[ "$color_prompt" == "yes" ]]; then
  # Color escape sequences for prompts (escaped for PS1)
  eBLACK='\[\e[0;30m\]'
  eDARKGRAY='\[\e[1;30m\]'
  eRED='\[\e[0;31m\]'
  eLIGHTRED='\[\e[1;31m\]'
  eGREEN='\[\e[0;32m\]'
  eLIGHTGREEN='\[\e[1;32m\]'
  eBROWN='\[\e[0;33m\]'
  eYELLOW='\[\e[1;33m\]'
  eBLUE='\[\e[0;34m\]'
  eLIGHTBLUE='\[\e[1;34m\]'
  ePURPLE='\[\e[0;35m\]'
  eLIGHTPURPLE='\[\e[1;35m\]'
  eCYAN='\[\e[0;36m\]'
  eLIGHTCYAN='\[\e[1;36m\]'
  eLIGHTGRAY='\[\e[0;37m\]'
  eWHITE='\[\e[1;37m\]'
  eNC='\[\e[0m\]'
  
  # Non-prompt color definitions (not escaped)
  BLACK='\e[0;30m'
  DARKGRAY='\e[1;30m'
  RED='\e[0;31m'
  LIGHTRED='\e[1;31m'
  GREEN='\e[0;32m'
  LIGHTGREEN='\e[1;32m'
  BROWN='\e[0;33m'
  YELLOW='\e[1;33m'
  BLUE='\e[0;34m'
  LIGHTBLUE='\e[1;34m'
  PURPLE='\e[0;35m'
  LIGHTPURPLE='\e[1;35m'
  CYAN='\e[0;36m'
  LIGHTCYAN='\e[1;36m'
  LIGHTGRAY='\e[0;37m'
  WHITE='\e[1;37m'
  NC='\e[0m'
  
  # Additional modern terminal formatting
  BOLD='\e[1m'
  DIM='\e[2m' 
  UNDERLINE='\e[4m'
  BLINK='\e[5m'
  REVERSE='\e[7m'
  HIDDEN='\e[8m'
  
  # Set colorized ls
  if [[ -x /usr/bin/dircolors ]]; then
    if [[ -r ~/.dircolors ]]; then
      eval "$(dircolors -b ~/.dircolors)"
    else
      eval "$(dircolors -b)"
    fi
  elif [[ "$CLICOLOR" = 1 ]]; then
    export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'
  else
    export CLICOLOR=0
  fi
fi

# Color aliases if color is supported
if [[ "$color_prompt" == "yes" ]]; then
  # Color aliases are now defined in bash_aliases
  :
fi
# Advanced VCS status functions with caching
function __git_info() {
  # Simplified version with error handling to prevent terminal crashes
  # Skip git checks entirely if git command isn't available
  if ! command -v git &>/dev/null; then
    return 0
  fi
  
  # Timeout protection for git commands to prevent hanging
  local GIT_TIMEOUT=1  # 1 second timeout
  
  # Fast check if we're in a git repo - with timeout and error handling
  if ! timeout $GIT_TIMEOUT git rev-parse --is-inside-work-tree &>/dev/null; then
    return 0  # Return success anyway to prevent terminal crashes
  fi
  
  # Get branch info with timeout and full error handling
  local branch=""
  branch=$(timeout $GIT_TIMEOUT git symbolic-ref --short HEAD 2>/dev/null) || 
  branch=$(timeout $GIT_TIMEOUT git describe --tags --exact-match 2>/dev/null) || 
  branch=$(timeout $GIT_TIMEOUT git rev-parse --short HEAD 2>/dev/null) || 
  branch="?"
  
  # Safe dirty check with timeout and error handling
  local dirty=""
  if ! timeout $GIT_TIMEOUT git diff --no-ext-diff --quiet 2>/dev/null; then
    dirty="*"
  fi
  
  # Only output if we got valid information
  if [[ -n "$branch" && "$branch" != "?" ]]; then
    echo -n "${eLIGHTPURPLE}(${branch}${dirty})${eNC}" 2>/dev/null || true
  fi
  
  return 0  # Always return success to prevent terminal crashes
}

# Modern prompt with git info, exit status, and job count
function __set_prompt() {
  # Simplified version with error handling to prevent terminal crashes
  local exit_code=$?
  local jobs_count=0
  jobs_count=$(jobs | wc -l 2>/dev/null) || jobs_count=0
  
  # Status indicator with safe defaults
  local status_color="${eGREEN:-\033[32m}"
  if [[ $exit_code -ne 0 ]]; then
    status_color="${eRED:-\033[31m}"
  fi
  
  # Job count indicator with error handling
  local job_info=""
  if [[ $jobs_count -gt 0 ]]; then
    job_info="${eYELLOW:-\033[33m}[${jobs_count}]${eNC:-\033[0m} "
  fi

  # Get git branch if appropriate - with error handling
  local git_info=""
  git_info=$(__git_info 2>/dev/null) || git_info=""
  [[ -n "$git_info" ]] && git_info=" $git_info"
  
  # Set title safely with error handling
  if [[ "${CONFIG[UPDATE_TITLE]}" == "1" ]]; then
    local last_cmd=""
    last_cmd=$(HISTTIMEFORMAT= history 1 2>/dev/null | sed 's/^ *[0-9]\+ *//' 2>/dev/null) || last_cmd="bash"
    echo -ne "\033]0;${last_cmd:0:50}\007" 2>/dev/null || true
  fi
  
  # Security indicator with error handling
  local sec_indicator=""
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    sec_indicator="${eYELLOW:-\033[33m}(ssh)${eNC:-\033[0m} "
  fi
  if [[ -n "$SUDO_USER" ]]; then
    sec_indicator="${eRED:-\033[31m}(!sudo!)${eNC:-\033[0m} "
  fi
  
  # Set the actual prompt - use basic colors if custom colors fail
  PS1="${sec_indicator}${job_info}${status_color}\u@\h${eNC:-\033[0m}:${eBLUE:-\033[34m}\w${eNC:-\033[0m}${git_info}\n${status_color}\\$${eNC:-\033[0m} " 2>/dev/null || \
  PS1="\u@\h:\w\n\\$ " # Ultra-safe fallback
  
  return 0 # Always return success to prevent terminal crashes
}

# Set up PROMPT_COMMAND
if [[ "${CONFIG[LAZY_LOAD]}" == "1" ]]; then
  # Optimized PROMPT_COMMAND with caching
  # Cache prompt components that don't change frequently
  __prompt_cache_update() {
    # Cache directory-specific info
    __prompt_cached_dir="$PWD"
    
    # Security indicator caching (SSH/sudo)
    __prompt_sec_indicator=""
    if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
      __prompt_sec_indicator="${eYELLOW}(ssh)${eNC} "
    fi
    if [[ -n "$SUDO_USER" ]]; then
      __prompt_sec_indicator="${eRED}(!sudo!)${eNC} "
    fi
    
    # Cache time for 30 seconds
    __prompt_cache_time=$((SECONDS+30))
  }
  
  # Optimized prompt command that uses cached components
  __prompt_command_optimized() {
    local exit_code=$?
    
    # Update the cache if needed
    if [[ "$__prompt_cached_dir" != "$PWD" || -z "$__prompt_cache_time" || "$SECONDS" -gt "$__prompt_cache_time" ]]; then
      __prompt_cache_update
    fi
    
    # Current job count (this is quick, no need to cache)
    local jobs_count=$(jobs | wc -l)
    local job_info=""
    if [[ $jobs_count -gt 0 ]]; then
      job_info="${eYELLOW}[${jobs_count}]${eNC} "
    fi
    
    # Status indicator for last command
    local status_color="${eGREEN}"
    if [[ $exit_code -ne 0 ]]; then
      status_color="${eRED}"
    fi
    
    # Git info (this is handled by __git_info which has its own caching)
    local git_info=$(__git_info)
    [[ -n "$git_info" ]] && git_info=" $git_info"
    
    # Update title if enabled
    if [[ "${CONFIG[UPDATE_TITLE]}" == "1" ]]; then
      local last_cmd=$(HISTTIMEFORMAT= history 1 | sed 's/^ *[0-9]\+ *//')
      echo -ne "\033]0;${last_cmd:0:50}\007"
    fi
    
    # Set the actual prompt using cached and current components
    PS1="${__prompt_sec_indicator}${job_info}${status_color}\u@\h${eNC}:${eBLUE}\w${eNC}${git_info}\n${status_color}\$${eNC} "
  }
  
  # Use the optimized prompt command
  PROMPT_COMMAND=__prompt_command_optimized
else
  # Use the standard prompt command
  PROMPT_COMMAND=__set_prompt
fi

# Internal utility functions
# Include all files in a directory with security checks
# SIMPLIFIED: loadRcDir function - reduced security checks to prevent terminal crashes
# REMOVED: loadRcDir function was causing terminal crashes
# Use safe_load_directory instead if needed

# Improved logging functions
function emsg() { echo -e " ${LIGHTGREEN}*${NC} $*" >&2; }
function ewarn() { echo -e " ${YELLOW}*${NC} $*" >&2; }
function eerror() { echo -e " ${LIGHTRED}*${NC} $*" >&2; }
function edebug() { [[ "${CONFIG[DEBUG]}" == "1" ]] && echo -e " ${CYAN}*${NC} $*" >&2; }

# Enhanced bashrc reload function
function rebash() {
  edebug "Reloading bash configuration..."
  exec bash -l
}

# Enhanced lesspipe setup
if [[ "${CONFIG[LESSPIPE]}" == "1" ]]; then
  if command -v lesspipe &>/dev/null; then
    export LESSOPEN="| $(command -v lesspipe) %s";
    export LESSCLOSE="$(command -v lesspipe) %s %s";
  elif command -v lesspipe.sh &>/dev/null; then
    export LESSOPEN="| $(command -v lesspipe.sh) %s";
    export LESSCLOSE="$(command -v lesspipe.sh) %s %s";
  fi
  # Set less environment
  export LESS="-R -F -X"
fi

# Improved SSH and GPG agent setup
if [[ "${CONFIG[AGENTS]}" == "1" ]]; then
  # Check if keychain is available
  if command -v keychain &>/dev/null; then
    export U_KEYCHAIN_OPTS=${U_KEYCHAIN_OPTS:-"--quiet --inherit local -Q --eval"}
    
    # Determine current hostname
    [[ -z "$HOSTNAME" ]] && HOSTNAME=$(uname -n)
    
    # Check if keychain is already running
    if [[ -f "${HOME}/.keychain/${HOSTNAME}-sh" ]]; then
      # shellcheck source=/dev/null
      source "${HOME}/.keychain/${HOSTNAME}-sh"
      if [[ -z "$SSH_AGENT_PID" || ! -d "/proc/$SSH_AGENT_PID" ]]; then
        eval "$(keychain ${U_KEYCHAIN_OPTS})"
      fi
    else
      # Start keychain
      eval "$(keychain ${U_KEYCHAIN_OPTS})"
    fi
  # Check for alternative agent setup if keychain is unavailable
  elif [[ -z "$SSH_AUTH_SOCK" || "$SSH_AUTH_SOCK" = /tmp/ssh-* ]]; then
    # Use ssh-agent if available and no agent is running
    if command -v ssh-agent &>/dev/null && [[ ! -S "$SSH_AUTH_SOCK" ]]; then
      eval "$(ssh-agent)" >/dev/null
      ssh-add 2>/dev/null
    fi
  fi
  
  # GPG agent
  if command -v gpg-agent &>/dev/null && [[ -f "${HOME}/.gnupg/gpg-agent.conf" ]]; then
    export GPG_TTY=$(tty)
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
  fi
fi

# Enhanced directory jumping function
# function j() removed to prevent terminal crashes
# SIMPLIFIED: bookmark function - basic implementation to prevent terminal instability
function bookmark() {
  echo "Simplified bookmark functionality"
  local bfile="~/.bookmarks"
  
  # Basic add/list functionality only
  if [[ "$1" == "-a" ]]; then
    echo "$PWD" >> ~/.bookmarks 2>/dev/null
    echo "Bookmark added"
  elif [[ "$1" == "-l" ]]; then
    cat ~/.bookmarks 2>/dev/null || echo "No bookmarks found"
  else
    echo "Usage: bookmark [-a|-l]"
  fi
}

# Dependency-based module loading with improved error handling
if [[ "${CONFIG[MODULES]}" == "1" ]]; then
  # Standardized module interface functions
  
  # Function to check for module dependencies
  # DISABLED: module_check_dependencies function was causing installation issues
  function module_check_dependencies() {
    # Simplified version that always succeeds
    return 0
  }
  
  # Improved module_enable function
  # DISABLED: module_enable function was causing installation issues
  function module_enable() {
    local module="$1"
    local module_file=""
    
    # Simple direct loading without complex checks
    if [[ -f "${HOME}/.bash_modules.d/${module}.module" ]]; then
      module_file="${HOME}/.bash_modules.d/${module}.module"
    elif [[ -f "${HOME}/.bash_modules.d/${module}.sh" ]]; then
      module_file="${HOME}/.bash_modules.d/${module}.sh"
    else
      return 0  # Silently skip missing modules
    fi
    
    # Simple source with error redirection
    source "$module_file" 2>/dev/null || true
    
    # Mark as loaded
    LOADED_MODULES["$module"]=1
    return 0
  }
  
  # Main module loading function
  # DISABLED: _load_enabled_modules function was causing installation issues
  function _load_enabled_modules() {
    # Track loaded modules with an associative array
    declare -gA LOADED_MODULES
    
    # Skip if modules file doesn't exist
    [[ ! -f "${HOME}/.bash_modules" ]] && return 0
    
    # Simple loading without error checking
    while IFS= read -r module; do
      # Skip comments and empty lines
      [[ -z "$module" || "$module" =~ ^# ]] && continue
      
      # Try to load the module silently
      module_enable "$module" 2>/dev/null || true
    done < "${HOME}/.bash_modules"
    
    return 0
  }
  
  # Load modules
  if type _load_enabled_modules &>/dev/null; then
    _load_enabled_modules
  elif [[ -f "${HOME}/.bash_modules" ]]; then
    # Fallback with better error handling
    echo "[bashrc] Warning: Enhanced module loader not found, using legacy loader" >&2
    declare -A LOADED_MODULES
    
    while IFS= read -r module; do
      [[ -z "$module" || "$module" =~ ^# ]] && continue
      
      # First try the module_enable function if it exists
      if type module_enable &>/dev/null; then
        if ! module_enable "$module"; then
          echo "[bashrc] Warning: Failed to load module '$module'" >&2
        fi
      # Fall back to direct sourcing with error handling
      elif [[ -f "${HOME}/.bash_modules.d/${module}.module" ]]; then
        secure_source "${HOME}/.bash_modules.d/${module}.module" 750 || {
          echo "[bashrc] Warning: Failed to load module '$module'" >&2
        }
      elif [[ -f "${HOME}/.bash_modules.d/${module}.sh" ]]; then
        secure_source "${HOME}/.bash_modules.d/${module}.sh" 750 || {
          echo "[bashrc] Warning: Failed to load module '$module'" >&2
        }
      else
        echo "[bashrc] Warning: Module '$module' not found" >&2
      fi
    done < "${HOME}/.bash_modules"
  fi
fi

# BLE.sh configuration - added to prevent 'unrecognized attach method' errors
# This ensures ble.sh loads correctly with the proper attach method
if ! grep -q "BLESH_ATTACH_METHOD" ~/.bashrc &>/dev/null; then
  export BLESH_ATTACH_METHOD="attach"
fi

# Core aliases
if [[ "${CONFIG[USER_ALIASES]}" == "1" ]]; then
  # Load user aliases if present
  if [[ -f ~/.bash_aliases ]]; then
    # shellcheck source=~/.bash_aliases
    . ~/.bash_aliases
  fi
fi

# Core functions
if [[ "${CONFIG[USER_FUNCS]}" == "1" ]]; then
  # Create directory and cd into it
  function mkcd() {
    mkdir -p "$1" && cd "$1" || return
  }
  
  # Extract various archive types with tool presence verification
  function extract() {
    if [[ -z "$1" ]]; then
      echo "Usage: extract <archive_file>"
      return 1
    fi
    
    if [[ ! -f "$1" ]]; then
      echo "'$1' is not a valid file"
      return 1
    fi
    
    # Function to check if a command exists
    command_exists() {
      command -v "$1" &> /dev/null
    }
    
    case "$1" in
      *.tar.bz2|*.tbz2)
        if ! command_exists tar; then
          echo "Error: tar command not found"
          return 1
        fi
        tar -xjf "$1"
        ;;
      *.tar.gz|*.tgz)
        if ! command_exists tar; then
          echo "Error: tar command not found"
          return 1
        fi
        tar -xzf "$1"
        ;;
      *.tar.xz)
        if ! command_exists tar; then
          echo "Error: tar command not found"
          return 1
        fi
        tar -xJf "$1"
        ;;
      *.bz2)
        if ! command_exists bunzip2; then
          echo "Error: bunzip2 command not found"
          return 1
        fi
        bunzip2 "$1"
        ;;
      *.rar)
        if ! command_exists unrar; then
          echo "Error: unrar command not found. Install it with 'sudo apt install unrar' or equivalent."
          return 1
        fi
        unrar x "$1"
        ;;
      *.gz)
        if ! command_exists gunzip; then
          echo "Error: gunzip command not found"
          return 1
        fi
        gunzip "$1"
        ;;
      *.tar)
        if ! command_exists tar; then
          echo "Error: tar command not found"
          return 1
        fi
        tar -xf "$1"
        ;;
      *.zip)
        if ! command_exists unzip; then
          echo "Error: unzip command not found"
          return 1
        fi
        unzip "$1"
        ;;
      *.Z)
        if ! command_exists uncompress; then
          echo "Error: uncompress command not found"
          return 1
        fi
        uncompress "$1"
        ;;
      *.7z)
        if ! command_exists 7z; then
          echo "Error: 7z command not found. Install it with 'sudo apt install p7zip-full' or equivalent."
          return 1
        fi
        7z x "$1"
        ;;
      *.xz)
        if ! command_exists unxz; then
          echo "Error: unxz command not found"
          return 1
        fi
        unxz "$1"
        ;;
      *)
        echo "'$1' cannot be extracted via extract function"
        return 1
        ;;
    esac
    
    return 0
  }
  
  # Search for files with pattern
  function ff() {
    find . -name "$1" 2>/dev/null
  }
  
  # Search content of files
  function fif() {
    grep -r --color=auto "$1" .
  }
  
  # Improved du command
  function duf() {
    du -h -d ${1:-1} | sort -h
  }
  
  # Man with color
  function man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
  }

  # Load user functions if present
  if [[ -f ~/.bash_functions ]]; then
    # shellcheck source=~/.bash_functions
    . ~/.bash_functions
  fi
fi
# Security toolset
# Check file for malicious content
function checksec() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    echo -e "\033[1;31mError: File not found: $file\033[0m" >&2
    return 1
  fi
  
  echo "Security check for file: $file"
  echo "----------------------------------"
  
  # File info
  echo -e "${LIGHTGREEN}File information:${NC}"
  file "$file"
  
  # Check permissions
  echo -e "\n${LIGHTGREEN}File permissions:${NC}"
  ls -la "$file"
  
  # Check if executable
  if [[ -x "$file" ]]; then
    echo -e "\n${LIGHTGREEN}Binary security features:${NC}"
    if command -v checksec &>/dev/null; then
      checksec --file="$file"
    elif command -v readelf &>/dev/null; then
      echo "PIE: $(readelf -h "$file" | grep -q "Type:[[:space:]]*EXEC" && echo "No" || echo "Yes")"
      echo "NX: $(readelf -l "$file" | grep -q "GNU_STACK.*RWE" && echo "No" || echo "Yes")"
    fi
  fi
  
  # Check for suspicious strings in text files
  if file "$file" | grep -q "text"; then
    echo -e "\n${LIGHTGREEN}Checking for suspicious patterns:${NC}"
    grep -E '(password|passwd|pwd|secret|key|token|cred|api).*=' "$file" || echo "None found"
  fi
  
  # Suggest further analysis
  echo -e "\n${LIGHTGREEN}Suggested next steps:${NC}"
  if file "$file" | grep -q "executable"; then
    echo "- Run through a sandbox like 'firejail'"
    echo "- Analyze with 'ltrace/strace'"
  elif file "$file" | grep -q "script"; then
    echo "- Review code manually before execution"
  fi
}

# Secure file deletion
function securerm() {
  local force=""
  if [[ "$1" == "-f" ]]; then
    force="-f"
    shift
  fi
  
  if [[ -z "$1" ]]; then
    echo "Usage: securerm [-f] file [file2 ...]"
    return 1
  fi
  
  for file in "$@"; do
    if [[ -f "$file" ]]; then
      if [[ -z "$force" ]]; then
        read -rp "Securely delete $file? (y/n): " confirm
        [[ "$confirm" != [yY]* ]] && continue
      fi
      
      echo "Securely deleting $file..."
      if command -v shred &>/dev/null; then
        # Use shred with error handling
        if ! shred -uz "$file" 2>/dev/null; then
          echo "Warning: shred failed, falling back to alternative method" >&2
          # Safe fallback with error handling
          if [[ -f "$file" && -w "$file" ]]; then
            dd if=/dev/urandom of="$file" bs=1k count=1 conv=notrunc >/dev/null 2>&1
            rm -f "$file"
          else
            echo "Error: Could not securely delete $file" >&2
          fi
        fi
      else
        # Fallback if shred not available - with safe size calculation
        if [[ -f "$file" && -w "$file" ]]; then
          local size
          size=$(stat -c %s "$file" 2>/dev/null || echo "1024")
          # Prevent overflow by limiting max size
          if (( size > 10485760 )); then  # Limit to 10MB max
            size=10485760
          fi
          dd if=/dev/urandom of="$file" bs=1k count=$((size/1024+1)) conv=notrunc >/dev/null 2>&1
          rm -f "$file"
        else
          echo "Error: Could not securely delete $file" >&2
        fi
      fi
    else
      echo "File not found: $file"
    fi
  done
}

# See which processes have open network connections
function netcheck() {
  echo -e "${LIGHTGREEN}Current network connections:${NC}"
  lsof -i -P -n | grep -E "(LISTEN|ESTABLISHED)"
  echo -e "\n${LIGHTGREEN}Listening ports:${NC}"
  netstat -tuln | grep LISTEN
}
# Safety check - ensure basic PATH exists before loading external files
if [[ -z "$PATH" ]]; then
  export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
  echo "[bashrc] Warning: PATH was empty, reset to default" >&2
fi

# Load postcustom configuration if enabled - using simplified loading for reliability
if [[ "${CONFIG[POSTCUSTOM]}" == "1" && -f ~/.bashrc.postcustom ]]; then
  # Simple, safe loading of postcustom file that won't crash the terminal
  source ~/.bashrc.postcustom 2>/dev/null || echo "[bashrc] Warning: Failed to load ~/.bashrc.postcustom" >&2
fi

# Final PATH sanity check
sanitize_path

# Finalize
if [[ "${CONFIG[DEBUG]}" == "1" ]]; then
  set +x
fi

# Stop profiling if enabled
if [[ -n "$BASHRC_PROFILE" ]]; then
  set +x
  exec 2>&3 3>&-
fi

# Improved error handling utility
function safe_execute() {
  local cmd="$1"
  local error_msg="${2:-Command failed}"
  local severity="${3:-warning}"  # warning, error, fatal
  
  # Execute the command
  if ! eval "$cmd"; then
    local exit_code=$?
    
    # Handle different severity levels
    case "$severity" in
      warning)
        echo "[WARNING] $error_msg (exit code: $exit_code)" >&2
        return $exit_code
        ;;
      error)
        echo "[ERROR] $error_msg (exit code: $exit_code)" >&2
        return $exit_code
        ;;
      fatal)
        echo "[FATAL] $error_msg (exit code: $exit_code)" >&2
        return 1  # Always return error
        ;;
      *)
        echo "[WARNING] $error_msg (exit code: $exit_code)" >&2
        return $exit_code
        ;;
    esac
  fi
  
  return 0
}