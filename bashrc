#!/usr/bin/env bash
# Enhanced Bashrc 3.0.0 - SENTINEL ADVANCED - $(date +%Y-%m-%d)
#
# Full-featured modular bashrc with enhanced security, performance, and productivity features
# Based on the original work by Jason Thistlethwaite (2013) with significant enhancements
#
# COPYRIGHT
###########
# Original bashrc Copyright (c) Jason Thistlethwaite 2013 (iadnah@uplinklounge.com)
# Enhancements Copyright (c) John 2023-2025
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
  
  # Record start time for performance measurement
  BASHRC_START_TIME=$SECONDS
fi

# Version information
declare -A SENTINEL_VERSION=(
  [MAJOR]=3
  [MINOR]=0
  [PATCH]=0
  [TYPE]="advanced"
  [BUILD_DATE]="$(date +%Y-%m-%d)"
)
export SENTINEL_VERSION
BASHRC_VERSION="${SENTINEL_VERSION[MAJOR]}.${SENTINEL_VERSION[MINOR]}.${SENTINEL_VERSION[PATCH]} (${SENTINEL_VERSION[TYPE]})"
export BASHRC_VERSION

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

# Configuration options with improved documentation
declare -A CONFIG=(
  # Core options
  [DEBUG]="${U_DEBUG:-0}"                   # Debug mode (0=off, 1=on)
  [DEFAULT_TITLE]="${U_DEFAULT_TITLE:-$BASH}"  # Default terminal title
  
  # Custom configuration files
  [PRECUSTOM]="${U_PRECUSTOM:-1}"           # Load ~/.bashrc.precustom (0=off, 1=on)
  [POSTCUSTOM]="${U_POSTCUSTOM:-1}"         # Load ~/.bashrc.postcustom (0=off, 1=on)
  
  # Feature toggles
  [USER_BINS]="${U_BINS:-1}"                # Add ~/bin and ~/.bin to PATH (0=off, 1=on)
  [USER_FUNCS]="${U_FUNCS:-1}"              # Load user functions (0=off, 1=on)
  [USER_ALIASES]="${U_ALIASES:-1}"          # Load user aliases (0=off, 1=on)
  [LESSPIPE]="${ENABLE_LESSPIPE:-1}"        # Enable lesspipe for file preview (0=off, 1=on)
  [AGENTS]="${U_AGENTS:-1}"                 # Configure SSH/GPG agents (0=off, 1=on)
  [MODULES]="${U_MODULES_ENABLE:-1}"        # Enable modular extensions (0=off, 1=on)
  [UPDATE_TITLE]="${U_UPDATETITLE:-1}"      # Dynamic terminal title (0=off, 1=on)
  [COLOR_PROMPT]="yes"                      # Colorful prompt (yes/no)
  
  # Security options
  [SECURE_PATH]="1"                         # Sanitize PATH (0=off, 1=on)
  [SECURE_HISTORY]="1"                      # Don't store sensitive commands (0=off, 1=on)
  [SECURE_PERMISSIONS]="1"                  # Check file permissions (0=off, 1=on)
  [SECURE_SSH]="1"                          # Enhanced SSH security (0=off, 1=on)
  [SECURE_UPDATES]="1"                      # Check for security updates (0=off, 1=on)
  
  # Performance options
  [LAZY_LOAD]="1"                           # Lazy load heavy components (0=off, 1=on)
  [CACHE_PROMPT]="1"                        # Cache prompt components (0=off, 1=on)
  [CACHE_COMMANDS]="1"                      # Cache command lookups (0=off, 1=on)
  
  # History options
  [HIST_SYNC]="1"                           # Synchronize history between sessions (0=off, 1=on)
  [HIST_TIMESTAMPS]="1"                     # Add timestamps to history (0=off, 1=on)
  [HIST_CONTEXT]="1"                        # Store directory context with history (0=off, 1=on)
  
  # User experience
  [COMMAND_TIMING]="1"                      # Show execution time for commands (0=off, 1=on)
  [SMART_PROMPT]="1"                        # Adjust prompt based on terminal width (0=off, 1=on)
  [ENHANCED_CD]="1"                         # Enhanced directory navigation (0=off, 1=on)
)

# ============================================================================
# SECTION: SECURITY CHECKS AND INITIALIZATION
# ============================================================================

# Security: Basic file permission checks
if [[ "${CONFIG[SECURE_PERMISSIONS]}" == "1" ]]; then
  # Check bashrc permissions
  if [[ -f ~/.bashrc && $(stat -c %a ~/.bashrc 2>/dev/null || stat -f %Lp ~/.bashrc 2>/dev/null) != 600 ]]; then
    echo -e "\033[1;31mWarning: ~/.bashrc has insecure permissions. Recommended: chmod 600 ~/.bashrc\033[0m" >&2
  fi
  
  # Check SSH directory permissions
  if [[ -d ~/.ssh ]]; then
    ssh_dir_perms=$(stat -c %a ~/.ssh 2>/dev/null || stat -f %Lp ~/.ssh 2>/dev/null)
    if [[ "$ssh_dir_perms" != 700 ]]; then
      echo -e "\033[1;31mWarning: ~/.ssh directory has insecure permissions. Recommended: chmod 700 ~/.ssh\033[0m" >&2
    fi
    
    # Check SSH key permissions
    if [[ -f ~/.ssh/id_rsa ]]; then
      key_perms=$(stat -c %a ~/.ssh/id_rsa 2>/dev/null || stat -f %Lp ~/.ssh/id_rsa 2>/dev/null)
      if [[ "$key_perms" != 600 ]]; then
        echo -e "\033[1;31mWarning: SSH private key has insecure permissions. Recommended: chmod 600 ~/.ssh/id_rsa\033[0m" >&2
      fi
    fi
  fi
  
  # Check for world-writable directories in PATH
  IFS=':' read -ra path_dirs <<< "$PATH"
  for dir in "${path_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
      dir_perms=$(stat -c %a "$dir" 2>/dev/null || stat -f %Lp "$dir" 2>/dev/null)
      if [[ "${dir_perms: -1}" == "2" || "${dir_perms: -1}" == "3" || "${dir_perms: -1}" == "6" || "${dir_perms: -1}" == "7" ]]; then
        echo -e "\033[1;31mWarning: Directory in PATH is world-writable: $dir\033[0m" >&2
      fi
    fi
  done
fi

# Load precustom configuration if enabled
if [[ "${CONFIG[PRECUSTOM]}" == "1" && -f ~/.bashrc.precustom ]]; then
  # shellcheck source=~/.bashrc.precustom
  . ~/.bashrc.precustom
fi

# Debug handling
if [[ "${CONFIG[DEBUG]}" == "1" ]]; then
  set -x
fi

# ============================================================================
# SECTION: BASH OPTIONS AND ENVIRONMENT
# ============================================================================

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
shopt -s histappend                 # Append to history file, don't overwrite
shopt -s cmdhist                    # Save multi-line commands as single line
shopt -s lithist                    # Save multi-line commands with newlines
shopt -s checkjobs                  # Check for running jobs before exiting

# Default file creation mask - slightly more restrictive
umask 027

# History configuration
HISTCONTROL=ignoreboth:erasedups    # Ignore duplicates and commands starting with space
HISTSIZE=10000                      # Number of commands to remember in memory
HISTFILESIZE=20000                  # Number of commands to save in history file
HISTTIMEFORMAT="%F %T "             # Add timestamps to history

# If enabled, store directory context with history
if [[ "${CONFIG[HIST_CONTEXT]}" == "1" ]]; then
  PROMPT_COMMAND="history -a; ${PROMPT_COMMAND:-:}"
  
  # Function to add directory context to history
  __add_history_context() {
    local hist_line=$(HISTTIMEFORMAT= history 1)
    local cmd=$(sed 's/^ *[0-9]\+ *//' <<< "$hist_line")
    
    # Skip certain commands
    if [[ "$cmd" =~ ^(cd|ls|pwd|history|clear)( .*)?$ ]]; then
      return
    fi
    
    # Add directory context
    history -s "#DIR:$PWD"
    history -s "$cmd"
    history -d -2
  }
  
  # Add to PROMPT_COMMAND
  PROMPT_COMMAND="__add_history_context; ${PROMPT_COMMAND:-:}"
fi

# Security: Filter sensitive commands from history
if [[ "${CONFIG[SECURE_HISTORY]}" == "1" ]]; then
  HISTIGNORE="&:ls:cd:pwd:exit:clear:history:sudo su*:*PASSWORD*:*password*:*PASSPHRASE*:*passphrase*:*SECRET*:*secret*:*TOKEN*:*token*:*KEY*:*key*:*CREDENTIAL*:*credential*"
fi

# ============================================================================
# SECTION: PATH MANAGEMENT AND SECURITY
# ============================================================================

# Path security function - ensure no relative paths or duplicate entries
sanitize_path() {
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

# User binary paths
if [[ "${CONFIG[USER_BINS]}" == "1" ]]; then
  # Add personal bin directories with higher priority

  # Modern ~/.local/bin (XDG compatibility)
  if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    PATH="$HOME/.local/bin:$PATH"
  fi
  
  # Traditional ~/bin
  if [[ -d "$HOME/bin" && ":$PATH:" != *":$HOME/bin:"* ]]; then
    PATH="$HOME/bin:$PATH"
  fi
  
  # Hidden ~/.bin
  if [[ -d "$HOME/.bin" && ":$PATH:" != *":$HOME/.bin:"* ]]; then
    PATH="$HOME/.bin:$PATH"
  fi
fi

# Tools-specific paths with lazy loading
if [[ "${CONFIG[LAZY_LOAD]}" == "1" ]]; then
  # Lazy load function for development environments
  __lazy_load_dev_env() {
    local env_name="$1"
    local env_init_file="$2"
    local env_init_command="$3"
    
    # Create wrapper function
    eval "
    $env_name() {
      # Unset this function to prevent recursion
      unset -f $env_name
      
      # Load the environment
      if [[ -f \"$env_init_file\" ]]; then
        source \"$env_init_file\"
      elif [[ -n \"$env_init_command\" ]]; then
        eval \"\$($env_init_command)\"
      fi
      
      # Call the command with the original arguments
      $env_name \"\$@\"
    }
    "
  }
  
  # Lazy load Cargo (Rust)
  if [[ -f "$HOME/.cargo/env" ]]; then
    __lazy_load_dev_env "cargo" "$HOME/.cargo/env"
  fi
  
  # Lazy load Pyenv
  if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d "$PYENV_ROOT/bin" ]] && PATH="$PYENV_ROOT/bin:$PATH"
    __lazy_load_dev_env "pyenv" "" "pyenv init -; pyenv virtualenv-init -"
  fi
  
  # Lazy load NVM (Node Version Manager)
  if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    __lazy_load_dev_env "nvm" "$NVM_DIR/nvm.sh"
    __lazy_load_dev_env "node" "$NVM_DIR/nvm.sh"
    __lazy_load_dev_env "npm" "$NVM_DIR/nvm.sh"
  fi
  
  # Lazy load RVM (Ruby Version Manager)
  if [[ -d "$HOME/.rvm" ]]; then
    export rvm_path="$HOME/.rvm"
    __lazy_load_dev_env "rvm" "$rvm_path/scripts/rvm"
    __lazy_load_dev_env "ruby" "$rvm_path/scripts/rvm"
    __lazy_load_dev_env "gem" "$rvm_path/scripts/rvm"
  fi
else
  # Eager loading of development environments
  
  # Cargo (Rust)
  if [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck source=~/.cargo/env
    . "$HOME/.cargo/env"
  fi
  
  # Pyenv setup
  if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d "$PYENV_ROOT/bin" ]] && PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv >/dev/null; then
      eval "$(pyenv init -)"
      eval "$(pyenv virtualenv-init -)"
    fi
  fi
  
  # NVM (Node Version Manager)
  if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi
  
  # RVM (Ruby Version Manager)
  if [[ -d "$HOME/.rvm" ]]; then
    export rvm_path="$HOME/.rvm"
    [[ -s "$rvm_path/scripts/rvm" ]] && source "$rvm_path/scripts/rvm"
  fi
fi

# Additional path entries
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  PATH="/usr/local/bin:$PATH"
fi

if [[ ":$PATH:" != *":/usr/local/sbin:"* ]]; then
  PATH="/usr/local/sbin:$PATH"
fi

# Run path sanitization
sanitize_path

# ============================================================================
# SECTION: TERMINAL COLORS AND APPEARANCE
# ============================================================================

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
  readonly eBLACK='\[\e[0;30m\]'
  readonly eDARKGRAY='\[\e[1;30m\]'
  readonly eRED='\[\e[0;31m\]'
  readonly eLIGHTRED='\[\e[1;31m\]'
  readonly eGREEN='\[\e[0;32m\]'
  readonly eLIGHTGREEN='\[\e[1;32m\]'
  readonly eBROWN='\[\e[0;33m\]'
  readonly eYELLOW='\[\e[1;33m\]'
  readonly eBLUE='\[\e[0;34m\]'
  readonly eLIGHTBLUE='\[\e[1;34m\]'
  readonly ePURPLE='\[\e[0;35m\]'
  readonly eLIGHTPURPLE='\[\e[1;35m\]'
  readonly eCYAN='\[\e[0;36m\]'
  readonly eLIGHTCYAN='\[\e[1;36m\]'
  readonly eLIGHTGRAY='\[\e[0;37m\]'
  readonly eWHITE='\[\e[1;37m\]'
  readonly eNC='\[\e[0m\]'
  
  # Non-prompt color definitions (not escaped)
  readonly BLACK='\e[0;30m'
  readonly DARKGRAY='\e[1;30m'
  readonly RED='\e[0;31m'
  readonly LIGHTRED='\e[1;31m'
  readonly GREEN='\e[0;32m'
  readonly LIGHTGREEN='\e[1;32m'
  readonly BROWN='\e[0;33m'
  readonly YELLOW='\e[1;33m'
  readonly BLUE='\e[0;34m'
  readonly LIGHTBLUE='\e[1;34m'
  readonly PURPLE='\e[0;35m'
  readonly LIGHTPURPLE='\e[1;35m'
  readonly CYAN='\e[0;36m'
  readonly LIGHTCYAN='\e[1;36m'
  readonly LIGHTGRAY='\e[0;37m'
  readonly WHITE='\e[1;37m'
  readonly NC='\e[0m'
  
  # Additional modern terminal formatting
  readonly BOLD='\e[1m'
  readonly DIM='\e[2m' 
  readonly UNDERLINE='\e[4m'
  readonly BLINK='\e[5m'
  readonly REVERSE='\e[7m'
  readonly HIDDEN='\e[8m'
  
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
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
  alias diff='diff --color=auto'
  alias ip='ip -color=auto'
  
  # Modern tools with color support
  if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
  fi
  
  if command -v fd &>/dev/null; then
    alias find='fd'
  fi
  
  if command -v rg &>/dev/null; then
    alias grep='rg'
  fi
fi

# ============================================================================
# SECTION: PROMPT CUSTOMIZATION
# ============================================================================

# Advanced VCS status functions with caching
__git_info() {
  # Optimization: only run git commands if we're in a git directory
  if [[ "${CONFIG[CACHE_PROMPT]}" == "1" ]]; then
    if [[ -n "$__git_repo_cached" && "$__git_repo_cached" != "$PWD" && "$PWD" != "$__git_repo_cached"* ]]; then
      # We've moved outside the previously cached git repo
      unset __git_repo_cached
      unset __git_branch_cached
      unset __git_dirty_cached
      unset __git_stash_cached
      unset __git_ahead_behind_cached
    fi
    
    if [[ -z "$__git_repo_cached" ]]; then
      # Check if we're in a git repo (optimized with -C and --is-inside-work-tree)
      if ! git -C "$PWD" rev-parse --is-inside-work-tree &>/dev/null; then
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
    if [[ -z "$__git_dirty_cached" || "$SECONDS" -gt "$__git_dirty_cache_time" ]]; then
      if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
        __git_dirty_cached="*"
      else
        __git_dirty_cached=""
      fi
      __git_dirty_cache_time=$((SECONDS+2))  # Cache for 2 seconds
    fi
    
    # Check for stashes (cached)
    if [[ -z "$__git_stash_cached" || "$SECONDS" -gt "$__git_stash_cache_time" ]]; then
      local stash_count=$(git stash list 2>/dev/null | wc -l)
      if [[ $stash_count -gt 0 ]]; then
        __git_stash_cached="{$stash_count}"
      else
        __git_stash_cached=""
      fi
      __git_stash_cache_time=$((SECONDS+30))  # Cache for 30 seconds
    fi
    
    # Check ahead/behind status (cached)
    if [[ -z "$__git_ahead_behind_cached" || "$SECONDS" -gt "$__git_ahead_behind_cache_time" ]]; then
      local ahead_behind=""
      local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
      local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
      
      if [[ $ahead -gt 0 && $behind -gt 0 ]]; then
        ahead_behind="↑$ahead↓$behind"
      elif [[ $ahead -gt 0 ]]; then
        ahead_behind="↑$ahead"
      elif [[ $behind -gt 0 ]]; then
        ahead_behind="↓$behind"
      fi
      
      __git_ahead_behind_cached="$ahead_behind"
      __git_ahead_behind_cache_time=$((SECONDS+10))  # Cache for 10 seconds
    fi
    
    echo -n "${eLIGHTPURPLE}(${__git_branch_cached}${__git_dirty_cached}${__git_stash_cached}${__git_ahead_behind_cached:+ }${__git_ahead_behind_cached})${eNC}"
  else
    # Non-cached version
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
      return 1
    fi
    
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || 
                   git describe --tags --exact-match 2>/dev/null || 
                   git rev-parse --short HEAD 2>/dev/null || 
                   echo "(unknown)")
    
    local dirty=""
    [[ -n "$(git status --porcelain 2>/dev/null)" ]] && dirty="*"
    
    local stash_count=$(git stash list 2>/dev/null | wc -l)
    local stash=""
    [[ $stash_count -gt 0 ]] && stash="{$stash_count}"
    
    local ahead_behind=""
    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    
    if [[ $ahead -gt 0 && $behind -gt 0 ]]; then
      ahead_behind="↑$ahead↓$behind"
    elif [[ $ahead -gt 0 ]]; then
      ahead_behind="↑$ahead"
    elif [[ $behind -gt 0 ]]; then
      ahead_behind="↓$behind"
    fi
    
    echo -n "${eLIGHTPURPLE}(${branch}${dirty}${stash}${ahead_behind:+ }${ahead_behind})${eNC}"
  fi
}

# Command execution timer
__command_timer_start() {
  if [[ "${CONFIG[COMMAND_TIMING]}" == "1" ]]; then
    __timer_start=${__timer_start:-$SECONDS}
  fi
}

__command_timer_stop() {
  if [[ "${CONFIG[COMMAND_TIMING]}" == "1" && -n "$__timer_start" ]]; then
    local elapsed=$((SECONDS - __timer_start))
    unset __timer_start
    
    # Format time nicely
    local time_str=""
    if [[ $elapsed -ge 3600 ]]; then
      time_str=$(printf "%dh:%02dm:%02ds" $((elapsed/3600)) $((elapsed%3600/60)) $((elapsed%60)))
    elif [[ $elapsed -ge 60 ]]; then
      time_str=$(printf "%dm:%02ds" $((elapsed/60)) $((elapsed%60)))
    else
      time_str="${elapsed}s"
    fi
    
    # Store for prompt display
    __last_command_time="$time_str"
  fi
}

# Add timer functions to PROMPT_COMMAND
trap '__command_timer_start' DEBUG
PROMPT_COMMAND="__command_timer_stop; ${PROMPT_COMMAND:-:}"

# Modern prompt with git info, exit status, job count, and command timing
__set_prompt() {
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
  
  # Command execution time
  local time_info=""
  if [[ "${CONFIG[COMMAND_TIMING]}" == "1" && -n "$__last_command_time" ]]; then
    time_info=" ${eCYAN}[${__last_command_time}]${eNC}"
    unset __last_command_time
  fi
  
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
  
  # Smart prompt sizing based on terminal width
  if [[ "${CONFIG[SMART_PROMPT]}" == "1" ]]; then
    local term_width=$(tput cols)
    
    if [[ $term_width -lt 80 ]]; then
      # Compact prompt for narrow terminals
      PS1="\n${sec_indicator}${status_color}\u${eWHITE}@${eLIGHTGREEN}\h${eNC}:${eLIGHTBLUE}\W${eNC}${git_info}${time_info} $(if [[ $exit_code -ne 0 ]]; then echo "${eRED}[$exit_code]${eNC}"; fi)\n${job_info}${eWHITE}>${eNC} "
    else
      # Full prompt for wide terminals
      PS1="\n${sec_indicator}[${eLIGHTGREEN}\t${eNC}] :: [${eLIGHTBLUE}\w${eNC}]${git_info}${time_info} $(if [[ $exit_code -ne 0 ]]; then echo "${eRED}[$exit_code]${eNC}"; fi)\n${job_info}${status_color}\u${eWHITE}@${eLIGHTGREEN}\h${eWHITE} >${eNC} "
    fi
  else
    # Standard prompt
    PS1="\n${sec_indicator}[${eLIGHTGREEN}\t${eNC}] :: [${eLIGHTBLUE}\w${eNC}]${git_info}${time_info} $(if [[ $exit_code -ne 0 ]]; then echo "${eRED}[$exit_code]${eNC}"; fi)\n${job_info}${status_color}\u${eWHITE}@${eLIGHTGREEN}\h${eWHITE} >${eNC} "
  fi
}

PROMPT_COMMAND="__set_prompt; ${PROMPT_COMMAND:-:}"

# ============================================================================
# SECTION: UTILITY FUNCTIONS
# ============================================================================

# Internal utility functions
# Include all files in a directory
loadRcDir() {
  if [[ -d "$1" ]]; then
    local rcFile
    for rcFile in "$1"/*; do
      if [[ -f "$rcFile" && -r "$rcFile" ]]; then
        # shellcheck source=/dev/null
        source "$rcFile" || echo "Error loading $rcFile" >&2
      fi
    done
  fi
}

# Improved logging functions
emsg() { echo -e " ${LIGHTGREEN}*${NC} $*" >&2; }
ewarn() { echo -e " ${YELLOW}*${NC} $*" >&2; }
eerror() { echo -e " ${LIGHTRED}*${NC} $*" >&2; }
edebug() { [[ "${CONFIG[DEBUG]}" == "1" ]] && echo -e " ${CYAN}*${NC} $*" >&2; }

# Enhanced bashrc reload function
rebash() {
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

# Enhanced directory jumping function with fuzzy matching
j() {
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
        if command -v fzf &>/dev/null; then
          # Use fzf for fuzzy matching if available
          dir=$(cat ~/.bookmarks | fzf -q "$1" -1)
          if [[ -n "$dir" ]]; then
            cd "$dir" || eerror "Directory no longer exists: $dir"
          else
            eerror "No bookmark matching '$1'"
          fi
        else
          # Fallback to grep
          dir=$(grep -i "$1" ~/.bookmarks | head -n1)
          if [[ -n "$dir" ]]; then
            cd "$dir" || eerror "Directory no longer exists: $dir"
          else
            eerror "No bookmark matching '$1'"
          fi
        fi
      else
        j -l
      fi
    fi
  else
    touch ~/.bookmarks
    echo "Created empty bookmarks file at ~/.bookmarks"
    echo "Usage: j [-a|-l|-r <num>|<n>|<pattern>]"
  fi
}

# Quick alias setup
qalias() {
  if [[ -z "$1" || -z "$2" ]]; then
    eerror "Usage: qalias <alias_name> <command>"
    return 1
  fi
  
  local alias_name="$1"
  shift
  local alias_cmd="$*"
  
  # Add to aliases file
  echo "alias $alias_name='$alias_cmd'" >> ~/.bash_aliases
  
  # Load it immediately
  alias "$alias_name"="$alias_cmd"
  
  emsg "Alias '$alias_name' created and activated"
}

# Enhanced cd with directory stack manipulation
cd() {
  if [[ "${CONFIG[ENHANCED_CD]}" != "1" ]]; then
    builtin cd "$@"
    return $?
  fi
  
  # No arguments: go home
  if [[ $# -eq 0 ]]; then
    builtin cd "$HOME"
    return $?
  fi
  
  # Handle special targets
  case "$1" in
    -) # Go to previous directory
      builtin cd -
      return $?
      ;;
    --) # Show directory stack
      dirs -v
      return 0
      ;;
    -[0-9]) # Go to directory in stack
      local num=${1:1}
      builtin cd "$(dirs -l +$num)" 2>/dev/null
      if [[ $? -ne 0 ]]; then
        eerror "No such directory in stack: $num"
        return 1
      fi
      return 0
      ;;
    +*) # Push directory to stack
      local target="${1:1}"
      if [[ -z "$target" ]]; then
        target="$PWD"
      fi
      pushd "$target" >/dev/null
      return $?
      ;;
    -*) # Pop directory from stack
      popd >/dev/null
      return $?
      ;;
    *) # Normal cd
      builtin cd "$@"
      local result=$?
      
      # Auto-list directory contents if successful
      if [[ $result -eq 0 && -n "$(ls -A)" ]]; then
        ls
      fi
      
      return $result
      ;;
  esac
}

# ============================================================================
# SECTION: MODULAR BASHRC EXTENSIONS
# ============================================================================

# Modular bashrc extensions
if [[ "${CONFIG[MODULES]}" == "1" ]]; then
  # Module registry
  declare -A SENTINEL_MODULES
  
  # Path for modules
  MODULES_PATH="${HOME}/.bash_modules.d"
  
  # Create modules directory if it doesn't exist
  [[ ! -d "$MODULES_PATH" ]] && mkdir -p "$MODULES_PATH"
  
  # Module management functions
  module_enable() {
    local module="$1"
    local module_file="${MODULES_PATH}/${module}.sh"
    
    # Check if module exists
    if [[ ! -f "$module_file" ]]; then
      eerror "Module '$module' not found"
      return 1
    fi
    
    # Load the module
    # shellcheck source=/dev/null
    source "$module_file" && SENTINEL_MODULES["$module"]=1
    
    # Update modules inventory file
    touch "${HOME}/.bash_modules"
    if ! grep -q "^${module}\$" "${HOME}/.bash_modules"; then
      echo "$module" >> "${HOME}/.bash_modules"
    fi
    
    emsg "Module '$module' enabled"
  }
  
  module_disable() {
    local module="$1"
    
    # Remove from inventory
    if [[ -f "${HOME}/.bash_modules" ]]; then
      sed -i "/^${module}\$/d" "${HOME}/.bash_modules"
      unset "SENTINEL_MODULES[$module]"
      emsg "Module '$module' disabled"
    fi
  }
  
  module_list() {
    echo "Available modules:"
    echo "----------------"
    for module in "$MODULES_PATH"/*.sh; do
      [[ -f "$module" ]] || continue
      module_name=$(basename "$module" .sh)
      if [[ "${SENTINEL_MODULES[$module_name]}" == "1" ]]; then
        echo -e "${GREEN}*${NC} $module_name (enabled)"
      else
        echo "  $module_name"
      fi
    done
  }
  
  # Load enabled modules
  if [[ -f "${HOME}/.bash_modules" ]]; then
    while IFS= read -r module; do
      [[ -z "$module" || "$module" =~ ^# ]] && continue
      module_enable "$module" >/dev/null
    done < "${HOME}/.bash_modules"
  fi
fi

# ============================================================================
# SECTION: CORE ALIASES
# ============================================================================

# Core aliases
if [[ "${CONFIG[USER_ALIASES]}" == "1" ]]; then
  # File operations
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
  alias ls-readdir='ls --color=none --format commas'
  alias l1='ls -1'
  alias la1='ls -a -1'
  
  # Navigation
  alias ..='cd ..'
  alias ...='cd ../..'
  alias ....='cd ../../..'
  alias .....='cd ../../../..'
  alias -- -='cd -'
  
  # System info
  alias sysinfo='echo "CPU:"; lscpu | grep "Model name"; echo -e "\nMemory:"; free -h; echo -e "\nDisk:"; df -h'
  alias meminfo='free -h'
  alias cpuinfo='lscpu'
  alias diskinfo='df -h'
  alias netinfo='ip -br addr show'
  
  # Network
  alias myip='curl -s https://ipinfo.io/ip'
  alias localip='hostname -I | cut -d" " -f1'
  alias ports='netstat -tulanp'
  alias iptables-list='sudo iptables -L -n -v --line-numbers'
  alias netstat-open='netstat -tulpn'
  alias ping='ping -c 5'
  
  # Process management
  alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
  alias psmem='ps auxf | sort -nr -k 4 | head -10'
  alias pscpu='ps auxf | sort -nr -k 3 | head -10'
  
  # Security
  alias check-listening='netstat -plunt'
  alias open-ports='ss -tulpn'
  alias check-login='last -a | head -20'
  alias check-auth='grep "Failed password" /var/log/auth.log | tail -20'
  
  # Git shortcuts
  alias gs='git status'
  alias gd='git diff'
  alias gl='git log --oneline --graph --decorate --all'
  alias ga='git add'
  alias gc='git commit'
  alias gp='git push'
  alias gpl='git pull'
  
  # System update shortcuts (for various distros)
  alias update-system='if command -v apt &>/dev/null; then 
                         sudo apt update && sudo apt upgrade -y; 
                       elif command -v dnf &>/dev/null; then 
                         sudo dnf upgrade -y;
                       elif command -v yum &>/dev/null; then
                         sudo yum update -y;
                       elif command -v pacman &>/dev/null; then
                         sudo pacman -Syu;
                       fi'
  
  # Disk usage
  alias du1='du -h --max-depth=1'
  alias du2='du -h --max-depth=2'
  alias dusort='du -h | sort -hr | head -20'
  
  # File searching
  alias ff='find . -type f -name'
  alias fd='find . -type d -name'
  alias ftext='grep -r --color=auto'
  
  # Clipboard operations (if available)
  if command -v xclip &>/dev/null; then
    alias setclip='xclip -selection c'
    alias getclip='xclip -selection c -o'
  elif command -v pbcopy &>/dev/null; then
    alias setclip='pbcopy'
    alias getclip='pbpaste'
  fi
  
  # Load user aliases if present
  if [[ -f ~/.bash_aliases ]]; then
    # shellcheck source=~/.bash_aliases
    . ~/.bash_aliases
  fi
  
  # Load aliases from directory if present
  if [[ -d ~/.bash_aliases.d ]]; then
    loadRcDir ~/.bash_aliases.d
  fi
fi

# ============================================================================
# SECTION: CORE FUNCTIONS
# ============================================================================

# Core functions
if [[ "${CONFIG[USER_FUNCS]}" == "1" ]]; then
  # Create directory and cd into it
  mkcd() {
    mkdir -p "$1" && cd "$1" || return
  }
  
  # Extract various archive types
  extract() {
    if [[ -z "$1" ]]; then
      echo "Usage: extract <archive_file>"
      return 1
    fi
    
    if [[ ! -f "$1" ]]; then
      echo "'$1' is not a valid file"
      return 1
    fi
    
    case "$1" in
      *.tar.bz2)   tar -xjf "$1"     ;;
      *.tar.gz)    tar -xzf "$1"     ;;
      *.tar.xz)    tar -xJf "$1"     ;;
      *.bz2)       bunzip2 "$1"      ;;
      *.rar)       unrar x "$1"      ;;
      *.gz)        gunzip "$1"       ;;
      *.tar)       tar -xf "$1"      ;;
      *.tbz2)      tar -xjf "$1"     ;;
      *.tgz)       tar -xzf "$1"     ;;
      *.zip)       unzip "$1"        ;;
      *.Z)         uncompress "$1"   ;;
      *.7z)        7z x "$1"         ;;
      *.xz)        unxz "$1"         ;;
      *)           echo "'$1' cannot be extracted via extract function" ;;
    esac
  }
  
  # Search for files with pattern
  ff() {
    find . -name "$1" 2>/dev/null
  }
  
  # Search content of files
  fif() {
    if command -v rg &>/dev/null; then
      rg --color=auto "$1" .
    else
      grep -r --color=auto "$1" .
    fi
  }
  
  # Improved du command
  duf() {
    du -h -d ${1:-1} | sort -h
  }
  
  # Man with color
  man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
  }
  
  # History search with pattern
  hgrep() {
    history | grep -i "$@" | grep -v "hgrep $@"
  }
  
  # Show directory tree
  tree() {
    if command -v tree &>/dev/null; then
      command tree -C "$@"
    else
      find . -type d -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
    fi
  }
  
  # Weather information
  weather() {
    local city="${1:-}"
    curl -s "wttr.in/$city?format=v2"
  }
  
  # Simple HTTP server
  serve() {
    local port="${1:-8000}"
    local ip=$(hostname -I | cut -d' ' -f1)
    echo "Starting HTTP server at http://$ip:$port/"
    python3 -m http.server "$port"
  }
  
  # Generate a random password
  genpass() {
    local length="${1:-16}"
    tr -dc 'A-Za-z0-9!@#$%^&*()_+?><~' < /dev/urandom | head -c "$length"
    echo
  }
  
  # Show system resource usage
  sysmon() {
    local delay="${1:-2}"
    local count="${2:-10}"
    
    for ((i=1; i<=count; i++)); do
      clear
      echo "System Monitor (${i}/${count})"
      echo "======================="
      echo "CPU Usage:"
      top -bn1 | head -n 12
      echo
      echo "Memory Usage:"
      free -h
      echo
      echo "Disk Usage:"
      df -h | grep -v tmpfs
      
      if [[ $i -lt $count ]]; then
        sleep "$delay"
      fi
    done
  }
  
  # Find large files
  findlarge() {
    local size="${1:-+100M}"
    local count="${2:-10}"
    find . -type f -size "$size" -exec ls -lh {} \; | sort -k5hr | head -n "$count"
  }
  
  # Find empty directories
  findempty() {
    find . -type d -empty -print
  }
  
  # Load user functions if present
  if [[ -f ~/.bash_functions ]]; then
    # shellcheck source=~/.bash_functions
    . ~/.bash_functions
  fi
  
  # Load functions from directory if present
  if [[ -d ~/.bash_functions.d ]]; then
    loadRcDir ~/.bash_functions.d
  fi
fi

# ============================================================================
# SECTION: SECURITY TOOLSET
# ============================================================================

# Security toolset
# Check file for malicious content
checksec() {
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
securerm() {
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

# Check for security updates
check_security_updates() {
  if [[ "${CONFIG[SECURE_UPDATES]}" != "1" ]]; then
    return
  fi
  
  # Detect distribution
  local distro=""
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    distro="$ID"
  elif command -v lsb_release &>/dev/null; then
    distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
  else
    distro="unknown"
  fi
  
  echo "Checking for security updates on $distro..."
  
  case "$distro" in
    ubuntu|debian|pop|mint|elementary)
      if ! command -v apt &>/dev/null; then
        echo "apt not found, skipping update check."
        return
      fi
      
      # Update package lists
      sudo apt update -qq
      
      # Check for security updates
      local security_updates=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l)
      
      if [[ $security_updates -gt 0 ]]; then
        echo -e "${LIGHTRED}$security_updates security updates available!${NC}"
        echo "Run 'sudo apt upgrade' to install them."
      else
        echo "No security updates available."
      fi
      ;;
    fedora|centos|rhel)
      if command -v dnf &>/dev/null; then
        local security_updates=$(sudo dnf check-update --security 2>/dev/null | grep -v "^$" | grep -v "^Last metadata" | wc -l)
        
        if [[ $security_updates -gt 0 ]]; then
          echo -e "${LIGHTRED}$security_updates security updates available!${NC}"
          echo "Run 'sudo dnf update --security' to install them."
        else
          echo "No security updates available."
        fi
      elif command -v yum &>/dev/null; then
        local security_updates=$(sudo yum check-update --security 2>/dev/null | grep -v "^$" | grep -v "^Last metadata" | wc -l)
        
        if [[ $security_updates -gt 0 ]]; then
          echo -e "${LIGHTRED}$security_updates security updates available!${NC}"
          echo "Run 'sudo yum update --security' to install them."
        else
          echo "No security updates available."
        fi
      else
        echo "Neither dnf nor yum found, skipping update check."
      fi
      ;;
    arch|manjaro)
      if command -v pacman &>/dev/null; then
        sudo pacman -Sy >/dev/null
        local updates=$(pacman -Qu | wc -l)
        
        if [[ $updates -gt 0 ]]; then
          echo -e "${LIGHTRED}$updates updates available!${NC}"
          echo "Run 'sudo pacman -Syu' to install them."
        else
          echo "No updates available."
        fi
      else
        echo "pacman not found, skipping update check."
      fi
      ;;
    *)
      echo "Unsupported distribution: $distro"
      echo "Security update check not implemented for this distribution."
      ;;
  esac
}

# File integrity monitoring
check_file_integrity() {
  local file="$1"
  local hash_file="${2:-$HOME/.file_hashes}"
  
  if [[ ! -f "$file" ]]; then
    eerror "File not found: $file"
    return 1
  fi
  
  # Create hash file if it doesn't exist
  if [[ ! -f "$hash_file" ]]; then
    touch "$hash_file"
  fi
  
  # Calculate current hash
  local current_hash=$(sha256sum "$file" | cut -d' ' -f1)
  
  # Check if file is in hash database
  local stored_hash=$(grep "^$file:" "$hash_file" | cut -d: -f2)
  
  if [[ -z "$stored_hash" ]]; then
    # File not in database, add it
    echo "$file:$current_hash" >> "$hash_file"
    echo "File added to integrity database: $file"
  else
    # Compare hashes
    if [[ "$current_hash" == "$stored_hash" ]]; then
      echo "File integrity verified: $file"
    else
      echo -e "${LIGHTRED}WARNING: File integrity check failed for $file${NC}"
      echo "Current hash: $current_hash"
      echo "Stored hash:  $stored_hash"
      
      # Ask to update hash
      read -rp "Update stored hash? (y/n): " update
      if [[ "$update" == [yY]* ]]; then
        sed -i "s|^$file:.*|$file:$current_hash|" "$hash_file"
        echo "Hash updated for $file"
      fi
    fi
  fi
}

# Update file integrity database
update_file_integrity() {
  local dir="${1:-.}"
  local hash_file="${2:-$HOME/.file_hashes}"
  
  # Create hash file if it doesn't exist
  if [[ ! -f "$hash_file" ]]; then
    touch "$hash_file"
  fi
  
  # Find all files in directory
  find "$dir" -type f -not -path "*/\.*" | while read -r file; do
    local current_hash=$(sha256sum "$file" | cut -d' ' -f1)
    
    # Check if file is in hash database
    if grep -q "^$file:" "$hash_file"; then
      # Update hash
      sed -i "s|^$file:.*|$file:$current_hash|" "$hash_file"
    else
      # Add file to database
      echo "$file:$current_hash" >> "$hash_file"
    fi
  done
  
  echo "File integrity database updated for $dir"
}

# ============================================================================
# SECTION: PROGRAMMABLE COMPLETION
# ============================================================================

# Enable programmable completion
if ! shopt -oq posix; then
  # Load completion system with lazy loading if enabled
  if [[ "${CONFIG[LAZY_LOAD]}" == "1" ]]; then
    # Lazy load completion
    __load_completion() {
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
      
      # Load completions from directory if present
      if [[ -d ~/.bash_completion.d ]]; then
        loadRcDir ~/.bash_completion.d
      fi
      
      # Now run the original command
      $COMP_LINE
    }
    
    # Create a function that will trigger completion loading
    __trigger_completion_loading() {
      # Only load once
      if [[ -z "$COMPLETION_LOADED" ]]; then
        export COMPLETION_LOADED=1
        __load_completion
      fi
    }
    
    # Bind Tab key to trigger completion loading
    bind -x '"\t": __trigger_completion_loading'
  else
    # Eager loading of completion
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
    
    # Load completions from directory if present
    if [[ -d ~/.bash_completion.d ]]; then
      loadRcDir ~/.bash_completion.d
    fi
  fi
fi

# ============================================================================
# SECTION: FINAL SETUP AND CLEANUP
# ============================================================================

# Load postcustom configuration if enabled
if [[ "${CONFIG[POSTCUSTOM]}" == "1" && -f ~/.bashrc.postcustom ]]; then
  # shellcheck source=~/.bashrc.postcustom
  . ~/.bashrc.postcustom
fi

# Check for security updates (weekly)
if [[ "${CONFIG[SECURE_UPDATES]}" == "1" ]]; then
  # Check if we've run the update check in the last week
  if [[ ! -f ~/.last_security_check || $(($(date +%s) - $(stat -c %Y ~/.last_security_check 2>/dev/null || echo 0))) -gt 604800 ]]; then
    check_security_updates
    touch ~/.last_security_check
  fi
fi

# Performance optimization: end profiling if enabled
if [[ -n "$BASHRC_PROFILE" ]]; then
  set +x
  exec 2>&3 3>&-
  
  # Calculate load time
  BASHRC_LOAD_TIME=$((SECONDS - BASHRC_START_TIME))
  echo "Bashrc loaded in $BASHRC_LOAD_TIME seconds"
fi

# Print welcome message with version info (only for interactive login shells)
if [[ $- == *i* && -z "$SENTINEL_WELCOME_SHOWN" ]]; then
  export SENTINEL_WELCOME_SHOWN=1
  echo -e "${LIGHTGREEN}SENTINEL Advanced Bashrc ${BASHRC_VERSION}${NC} loaded."
  echo -e "Type ${YELLOW}help-sentinel${NC} for available commands."
fi

# Help function for SENTINEL commands
help-sentinel() {
  echo -e "${LIGHTGREEN}SENTINEL Advanced Bashrc ${BASHRC_VERSION}${NC}"
  echo -e "${LIGHTGREEN}Available commands:${NC}"
  echo -e "  ${YELLOW}rebash${NC} - Reload bash configuration"
  echo -e "  ${YELLOW}j${NC} - Jump to bookmarked directories"
  echo -e "  ${YELLOW}extract${NC} - Extract various archive formats"
  echo -e "  ${YELLOW}mkcd${NC} - Create directory and cd into it"
  echo -e "  ${YELLOW}ff${NC} - Find files by name"
  echo -e "  ${YELLOW}fif${NC} - Find text in files"
  echo -e "  ${YELLOW}duf${NC} - Show directory sizes"
  echo -e "  ${YELLOW}hgrep${NC} - Search command history"
  echo -e "  ${YELLOW}weather${NC} - Show weather information"
  echo -e "  ${YELLOW}serve${NC} - Start a simple HTTP server"
  echo -e "  ${YELLOW}genpass${NC} - Generate a random password"
  echo -e "  ${YELLOW}sysmon${NC} - Monitor system resources"
  echo -e "  ${YELLOW}findlarge${NC} - Find large files"
  echo -e "  ${YELLOW}findempty${NC} - Find empty directories"
  echo -e "  ${YELLOW}checksec${NC} - Check file security"
  echo -e "  ${YELLOW}securerm${NC} - Securely delete files"
  echo -e "  ${YELLOW}check_security_updates${NC} - Check for security updates"
  echo -e "  ${YELLOW}check_file_integrity${NC} - Check file integrity"
  echo -e "  ${YELLOW}update_file_integrity${NC} - Update file integrity database"
  
  if [[ "${CONFIG[MODULES]}" == "1" ]]; then
    echo -e "  ${YELLOW}module_enable${NC} - Enable a module"
    echo -e "  ${YELLOW}module_disable${NC} - Disable a module"
    echo -e "  ${YELLOW}module_list${NC} - List available modules"
  fi
  
  echo -e "\n${LIGHTGREEN}For more information, type 'help <command>' or 'man <command>'${NC}"
}

# Ensure the script is sourced correctly - only need this check once
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Please source this script instead of executing it:"
  echo "source ~/.bashrc"
fi
