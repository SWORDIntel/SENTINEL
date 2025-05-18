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

# Create a secure_source function for consistent file security checks
function secure_source() {
  local file="$1"
  local required_perms="${2:-600}"
  
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file" >&2
    return 1
  fi
  
  # Check if permissions are sufficiently restrictive
  local perms=$(stat -c %a "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)
  if [[ "$perms" -gt "$required_perms" ]]; then
    echo "Warning: $file has insecure permissions ($perms). Recommended: chmod $required_perms $file" >&2
  fi
  
  # Source the file
  source "$file" || {
    echo "Error: Failed to source $file" >&2
    return 2
  }
  
  return 0
}

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
function sanitize_path() {
  if [[ "${CONFIG[SECURE_PATH]}" != "1" ]]; then
    return
  fi
  
  local old_path="$PATH"
  local new_path=""
  local dir=""
  
  # Create array from PATH, splitting on ':'
  IFS=':' read -ra path_array <<< "$old_path"
  
  # Process each directory
  for dir in "${path_array[@]}"; do
    # Skip empty, relative paths, or paths with '.' or '..'
    if [[ -z "$dir" || "$dir" =~ ^\. || "$dir" =~ /\.\.?/ ]]; then
      echo "Warning: Skipping potentially insecure path component: $dir" >&2
      continue
    fi
    
    # Add only if directory exists and isn't already in new_path
    if [[ -d "$dir" && ":$new_path:" != *":$dir:"* ]]; then
      if [[ -z "$new_path" ]]; then
        new_path="$dir"
      else
        new_path="$new_path:$dir"
      fi
    fi
  done
  
  export PATH="$new_path"
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
  # Optimization: only run git commands if we're in a git directory
  if [[ "${CONFIG[CACHE_PROMPT]}" == "1" ]]; then
    if [[ -n "$__git_repo_cached" && "$__git_repo_cached" != "$PWD" && "$PWD" != "$__git_repo_cached"* ]]; then
      # We've moved outside the previously cached git repo
      unset __git_repo_cached
      unset __git_branch_cached
      unset __git_dirty_cached
    fi
    
    if [[ -z "$__git_repo_cached" ]]; then
      # Fast check if we're in a git repo
      if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        return 1
      fi
      
      # Cache the repo root
      __git_repo_cached=$(git rev-parse --show-toplevel)
    fi
    
    # Get the branch name (cached for performance)
    if [[ -z "$__git_branch_cached" || "$SECONDS" -gt "$__git_branch_cache_time" ]]; then
      __git_branch_cached=$(git symbolic-ref --short HEAD 2>/dev/null || 
                          git describe --tags --exact-match 2>/dev/null || 
                          git rev-parse --short HEAD 2>/dev/null || 
                          echo "(unknown)")
      __git_branch_cache_time=$((SECONDS+5))  # Cache for 5 seconds
    fi
    
    # Check for dirty state (cached, but checked more frequently)
    # Use more efficient diff-index instead of git status
    if [[ -z "$__git_dirty_cached" || "$SECONDS" -gt "$__git_dirty_cache_time" ]]; then
      if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        __git_dirty_cached="*"
      else
        __git_dirty_cached=""
      fi
      __git_dirty_cache_time=$((SECONDS+2))  # Cache for 2 seconds
    fi
    
    echo -n "${eLIGHTPURPLE}(${__git_branch_cached}${__git_dirty_cached})${eNC}"
  else
    # Non-cached version with performance improvements
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
      return 1
    fi
    
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || 
                   git describe --tags --exact-match 2>/dev/null || 
                   git rev-parse --short HEAD 2>/dev/null || 
                   echo "(unknown)")
    
    local dirty=""
    # Use more efficient diff-index instead of git status
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
      dirty="*"
    fi
    
    echo -n "${eLIGHTPURPLE}(${branch}${dirty})${eNC}"
  fi
}

# Modern prompt with git info, exit status, and job count
function __set_prompt() {
  local exit_code=$?
  local jobs_count=$(jobs | wc -l)
  
  # Status indicator
  local status_color="${eGREEN}"
  if [[ $exit_code -ne 0 ]]; then
    status_color="${eRED}"
  fi
  
  # Job count indicator
  local job_info=""
  if [[ $jobs_count -gt 0 ]]; then
    job_info="${eYELLOW}[${jobs_count}]${eNC} "
  fi

  # Get git branch if appropriate
  local git_info=$(__git_info)
  [[ -n "$git_info" ]] && git_info=" $git_info"
  
  # Set title to last command if enabled
  if [[ "${CONFIG[UPDATE_TITLE]}" == "1" ]]; then
    local last_cmd=$(HISTTIMEFORMAT= history 1 | sed 's/^ *[0-9]\+ *//')
    echo -ne "\033]0;${last_cmd:0:50}\007"
  fi
  
  # Security indicator (if any SSH connection or sudo)
  local sec_indicator=""
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    sec_indicator="${eYELLOW}(ssh)${eNC} "
  fi
  if [[ -n "$SUDO_USER" ]]; then
    sec_indicator="${eRED}(!sudo!)${eNC} "
  fi
  
  # Set the actual prompt
  PS1="${sec_indicator}${job_info}${status_color}\u@\h${eNC}:${eBLUE}\w${eNC}${git_info}\n${status_color}\$${eNC} "
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
function loadRcDir() {
  if [[ ! -d "$1" ]]; then
    echo "Error: Directory not found: $1" >&2
    return 1
  fi
  
  local rcFile
  local load_count=0
  local error_count=0
  
  for rcFile in "$1"/*; do
    # Skip non-files and files we can't read
    if [[ ! -f "$rcFile" || ! -r "$rcFile" ]]; then
      continue
    fi
    
    # Check file ownership and permissions
    local file_owner=$(stat -c %U "$rcFile" 2>/dev/null || stat -f "%Su" "$rcFile" 2>/dev/null)
    local file_perms=$(stat -c %a "$rcFile" 2>/dev/null || stat -f "%Lp" "$rcFile" 2>/dev/null)
    
    # Skip files not owned by the user or with insecure permissions
    if [[ "$file_owner" != "$USER" && "$file_owner" != "$(id -un)" ]]; then
      echo "Warning: Skipping $rcFile - not owned by current user" >&2
      error_count=$((error_count+1))
      continue
    fi
    
    # Use secure_source instead of direct source
    if secure_source "$rcFile" 750; then
      load_count=$((load_count+1))
    else
      echo "Error loading $rcFile" >&2
      error_count=$((error_count+1))
    fi
  done
  
  if [[ "${CONFIG[DEBUG]}" == "1" ]]; then
    echo "Loaded $load_count files from $1 (errors: $error_count)" >&2
  fi
  
  return $error_count
}

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
function j() {
  local dir
  if [[ -f ~/.bookmarks ]]; then
    if [[ "$1" == "-a" ]]; then
      echo "$PWD" >> ~/.bookmarks
      sort -u ~/.bookmarks -o ~/.bookmarks
      echo "Bookmark added: $PWD"
    elif [[ "$1" == "-l" ]]; then
      nl -w2 ~/.bookmarks | sed 's/^ *//'
    elif [[ "$1" == "-r" ]]; then
      if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
        sed -i "${2}d" ~/.bookmarks
        echo "Removed bookmark #$2"
      else
        eerror "Usage: j -r <number>"
      fi
    else
      if [[ "$1" =~ ^[0-9]+$ && "$1" -le $(wc -l <~/.bookmarks) ]]; then
        dir=$(sed -n "${1}p" ~/.bookmarks)
        cd "$dir" || eerror "Directory no longer exists: $dir"
      elif [[ -n "$1" ]]; then
        # Fuzzy find with grep
        dir=$(grep -i "$1" ~/.bookmarks | head -n1)
        if [[ -n "$dir" ]]; then
          cd "$dir" || eerror "Directory no longer exists: $dir"
        else
          eerror "No bookmark matching '$1'"
        fi
      else
        j -l
      fi
    fi
  else
    touch ~/.bookmarks
    echo "Created empty bookmarks file at ~/.bookmarks"
    echo "Usage: j [-a|-l|-r <num>|<name>|<num>]"
  fi
}

# Dependency-based module loading with improved error handling
if [[ "${CONFIG[MODULES]}" == "1" ]]; then
  # Standardized module interface functions
  
  # Function to check for module dependencies
  function module_check_dependencies() {
    local module="$1"
    local deps_file="${HOME}/.bash_modules.d/${module}.deps"
    
    # If no deps file exists, assume no dependencies
    if [[ ! -f "$deps_file" ]]; then
      return 0
    fi
    
    local missing_deps=()
    while IFS= read -r dep; do
      # Skip comments and empty lines
      [[ -z "$dep" || "$dep" =~ ^# ]] && continue
      
      # Check if dependency module exists
      if [[ ! -f "${HOME}/.bash_modules.d/${dep}.module" && ! -f "${HOME}/.bash_modules.d/${dep}.sh" ]]; then
        missing_deps+=("$dep")
        continue
      fi
      
      # Check if dependency is already loaded
      if [[ -z "${LOADED_MODULES[$dep]}" ]]; then
        # Recursively load dependency if needed
        module_enable "$dep" || {
          missing_deps+=("$dep")
        }
      fi
    done < "$deps_file"
    
    # Return error if any dependencies couldn't be loaded
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
      echo "Module $module is missing dependencies: ${missing_deps[*]}" >&2
      return 1
    fi
    
    return 0
  }
  
  # Improved module_enable function
  function module_enable() {
    local module="$1"
    local force="${2:-0}"
    
    # Skip if already loaded and not forced
    if [[ -n "${LOADED_MODULES[$module]}" && "$force" != "1" ]]; then
      return 0
    fi
    
    # Determine module file path
    local module_file=""
    if [[ -f "${HOME}/.bash_modules.d/${module}.module" ]]; then
      module_file="${HOME}/.bash_modules.d/${module}.module"
    elif [[ -f "${HOME}/.bash_modules.d/${module}.sh" ]]; then
      module_file="${HOME}/.bash_modules.d/${module}.sh"
    else
      echo "Error: Module '$module' not found" >&2
      return 1
    fi
    
    # Check module file security
    if [[ "${CONFIG[SECURE_PERMISSIONS]}" == "1" ]]; then
      local perms=$(stat -c %a "$module_file" 2>/dev/null || stat -f "%Lp" "$module_file" 2>/dev/null)
      if [[ "$perms" -gt "750" ]]; then
        echo "Warning: Module file $module_file has insecure permissions: $perms" >&2
      fi
    fi
    
    # Check dependencies
    module_check_dependencies "$module" || {
      echo "Error: Failed to load dependencies for module $module" >&2
      return 1
    }
    
    # Source the module file using secure_source
    secure_source "$module_file" 750 || {
      echo "Error: Failed to load module $module" >&2
      return 1
    }
    
    # Mark as loaded
    LOADED_MODULES["$module"]=1
    return 0
  }
  
  # Main module loading function
  function _load_enabled_modules() {
    # Track loaded modules with an associative array
    declare -gA LOADED_MODULES
    
    if [[ ! -f "${HOME}/.bash_modules" ]]; then
      echo "No modules file found at ${HOME}/.bash_modules" >&2
      return 1
    fi
    
    local load_errors=0
    while IFS= read -r module; do
      # Skip comments and empty lines
      [[ -z "$module" || "$module" =~ ^# ]] && continue
      
      # Try to load the module
      module_enable "$module" || {
        echo "Failed to load module: $module" >&2
        load_errors=$((load_errors+1))
      }
    done < "${HOME}/.bash_modules"
    
    if [[ $load_errors -gt 0 ]]; then
      echo "Warning: $load_errors module(s) failed to load" >&2
    fi
    
    return $load_errors
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
    eerror "File not found: $file"
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
        shred -uz "$file"
      else
        # Fallback if shred not available
        dd if=/dev/urandom of="$file" bs=1k count=$(($(stat -c %s "$file")/1024+1)) conv=notrunc >/dev/null 2>&1
        rm -f "$file"
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
# Load postcustom configuration if enabled
if [[ "${CONFIG[POSTCUSTOM]}" == "1" && -f ~/.bashrc.postcustom ]]; then
  # Use centralized config caching with verification if available
  if type load_cached_config &>/dev/null; then
    if ! load_cached_config ~/.bashrc.postcustom --verify; then
      echo "[bashrc] Failed to load ~/.bashrc.postcustom via cache" >&2
      # Fallback to secure_source if cache fails
      if ! secure_source ~/.bashrc.postcustom; then
        echo "[bashrc] Critical error: Failed to load ~/.bashrc.postcustom directly" >&2
      fi
    fi
  else
    # Direct loading if caching function not available
    if ! secure_source ~/.bashrc.postcustom; then
      echo "[bashrc] Critical error: Failed to load ~/.bashrc.postcustom" >&2
    fi
  fi
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