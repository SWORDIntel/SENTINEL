#!/usr/bin/env bash
###############################################################################
# SENTINEL – Framework installer
# -----------------------------------------------
# Hardened edition  •  v2.3.0  •  2025-05-16
# Installs/repairs directly to user's home directory
# and patches the user's Bash startup chain in an idempotent way.
###############################################################################
# Coding standards
#   • Strict mode:  set -euo pipefail
#   • All paths quoted, no implicit cd
#   • No eval; never rely on $IFS splitting
#   • Verbose log + coloured status lines
#   • Resumable: skips steps already done
###############################################################################

# Detect if script is being sourced instead of executed
# This prevents the user's shell from being terminated if they incorrectly use 'source install.sh'
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "Error: This script should be executed with 'bash install.sh', not sourced with 'source install.sh'." >&2
    echo "Sourcing would cause your shell to exit if an error occurs." >&2
    return 1
fi

# Strict mode to catch errors
set -euo pipefail

# Define critical variables
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LOG_DIR="${HOME}/logs"
STATE_FILE="${HOME}/install.state"
BLESH_DIR="${HOME}/.local/share/blesh"
BLESH_LOADER="${HOME}/blesh_loader.sh"
MODULES_DIR="${HOME}/bash_modules.d"

# Ensure logs directory exists before any logging
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi

# Colour helpers
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_blue=$'\033[1;34m'; c_reset=$'\033[0m'

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

# Secure git clone function with safety checks
safe_git_clone() {
    local depth_arg=""
    local url=""
    local target_dir=""
    
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
    
    ok "Repository cloned successfully"
}

# Error handler
trap 'fail "Installer aborted on line $LINENO; see ${LOG_DIR}/install.log"' ERR

# State management functions
mark_done()  { echo "$1" >> "${STATE_FILE}"; }
is_done()    { grep -qxF "$1" "${STATE_FILE:-/dev/null}" 2>/dev/null; }

# Unattended install flag
INTERACTIVE=1
for arg in "$@"; do
  case "$arg" in
    --non-interactive)
      INTERACTIVE=0
      ;;
  esac
 done

# Python version check before venv setup
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
if [[ ! "${PYTHON_VERSION}" =~ ^3\.[6-9] ]] && [[ ! "${PYTHON_VERSION}" =~ ^3\.[1-9][0-9] ]]; then
    fail "Python 3.6+ is required (found ${PYTHON_VERSION})"
fi

###############################################################################
# 1. Dependency check
###############################################################################
REQUIRED_CMDS=(git make awk sed rsync python3 pip3)
MISSING=()
for cmd in "${REQUIRED_CMDS[@]}"; do
  command -v "${cmd}" &>/dev/null || MISSING+=("${cmd}")
done
if ((${#MISSING[@]})); then
  fail "Missing system packages: ${MISSING[*]}. Install them and re-run."
fi
ok "All required CLI tools present"

# Debian-specific package dependency checking
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

###############################################################################
# 2. Create directory structure
###############################################################################
setup_directories() {
    if is_done "DIRS_CREATED"; then
        if [[ -d "${HOME}/logs" && -d "${HOME}/bash_modules.d" ]]; then
            ok "Directory tree already exists"
            return
        else
            warn "State file marked DIRS_CREATED but directories missing, re-creating"
        fi
    fi
    step "Creating directory tree under ${HOME}"
    
    # Create directories with error checking
    local dirs=(
        "${HOME}/autocomplete/snippets"
        "${HOME}/autocomplete/context"
        "${HOME}/autocomplete/projects"
        "${HOME}/autocomplete/params"
        "${HOME}/logs"
        "${HOME}/bash_modules.d"
        "${HOME}/.cache/blesh"
        "${HOME}/bash_aliases.d"
        "${HOME}/bash_completion.d"
        "${HOME}/bash_functions.d"
        "${HOME}/contrib"
    )
    
    for dir in "${dirs[@]}"; do
        safe_mkdir "$dir"
    done
    
    # Set secure permissions
    chmod 700 "${LOG_DIR}" \
        "${HOME}/"{bash_aliases.d,bash_completion.d,bash_functions.d,contrib} || \
        fail "Failed to set directory permissions"
    
    mark_done "DIRS_CREATED"
    ok "Directory tree ready"
}

###############################################################################
# 3. Python venv and dependencies
###############################################################################
setup_python_venv() {
    if is_done "PYTHON_VENV_READY"; then
        if [[ -f "${HOME}/venv/bin/activate" ]]; then
            ok "Python venv already exists"
            return
        else
            warn "State file marked PYTHON_VENV_READY but venv missing, re-creating"
        fi
    fi
    step "Setting up Python virtual environment and dependencies"
    VENV_DIR="${HOME}/venv"
    
    # Ensure parent directory exists
    safe_mkdir "$(dirname "$VENV_DIR")"
    
    if [[ ! -d "$VENV_DIR" ]]; then
        # Check if python3-venv is available
        if ! python3 -c "import venv" &>/dev/null; then
            fail "Python venv module not available. Please install python3-venv package (e.g. 'sudo apt install python3-venv' on Debian/Ubuntu)"
        fi
        
        if ! python3 -m venv "$VENV_DIR"; then
            fail "Failed to create Python virtual environment"
        fi
        if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
            fail "Virtual environment creation failed - activate script not found"
        fi
        ok "Virtual environment created at $VENV_DIR"
    else
        ok "Virtual environment already exists at $VENV_DIR"
    fi
    # shellcheck source=/dev/null
    source "$VENV_DIR/bin/activate"
    step "Installing required Python packages in venv"
    "$VENV_DIR/bin/pip" install --upgrade pip
    # Install dependencies from requirements.txt if available
    if [[ -f "${PROJECT_ROOT}/requirements.txt" ]]; then
        log "Installing Python dependencies from requirements.txt for reproducibility and security."
        "$VENV_DIR/bin/pip" install -r "${PROJECT_ROOT}/requirements.txt" || fail "Failed to install requirements.txt dependencies"
    else
        log "requirements.txt not found, falling back to hardcoded package list."
        "$VENV_DIR/bin/pip" install npyscreen tqdm requests beautifulsoup4 numpy scipy scikit-learn joblib markovify unidecode rich
    fi
    if [[ "${SENTINEL_ENABLE_TENSORFLOW:-0}" == "1" ]]; then
        "$VENV_DIR/bin/pip" install tensorflow
        ok "Tensorflow installed (advanced ML features enabled)"
    fi
    mark_done "PYTHON_VENV_READY"
    ok "Python dependencies installed in venv"
}

###############################################################################
# 4. Install BLE.sh (for enhanced autocomplete)
###############################################################################
install_blesh() {
  step "Installing BLE.sh to ${BLESH_DIR}"
  mkdir -p "${BLESH_DIR}"
  safe_git_clone --depth=1 https://github.com/akinomyoga/ble.sh.git "${BLESH_DIR}"
  BLESH_TAG="v0.3.4"
  if git -C "${BLESH_DIR}" rev-parse "$BLESH_TAG" >/dev/null 2>&1; then
    git -C "${BLESH_DIR}" checkout "$BLESH_TAG"
    ok "Checked out BLE.sh tag $BLESH_TAG"
  else
    warn "BLE.sh tag $BLESH_TAG not found; using default branch."
  fi
  
  # Check various potential locations for ble.sh
  if [[ ! -f "${BLESH_DIR}/ble.sh" ]]; then
    step "ble.sh not found, attempting to build it"
    
    # First try using make
    if [[ -f "${BLESH_DIR}/Makefile" ]]; then
      (cd "${BLESH_DIR}" && make) || warn "Make build failed, trying alternatives"
    fi
    
    # Check if ble.sh was generated in the out directory
    if [[ -f "${BLESH_DIR}/out/ble.sh" ]]; then
      # Create a symlink to the built file
      ln -sf "${BLESH_DIR}/out/ble.sh" "${BLESH_DIR}/ble.sh"
      ok "Created symlink to built ble.sh in out directory"
    elif [[ -f "${BLESH_DIR}/ble.pp" ]] && [[ -f "${BLESH_DIR}/make_command.sh" ]]; then
      # Try alternate build methods if needed
      warn "Built ble.sh not found in expected location, trying other approaches"
      (cd "${BLESH_DIR}" && bash make_command.sh) || warn "make_command.sh execution failed"
    fi
    
    # Final check if ble.sh exists anywhere
    if [[ ! -f "${BLESH_DIR}/ble.sh" ]] && [[ -f "${BLESH_DIR}/out/ble.sh" ]]; then
      ln -sf "${BLESH_DIR}/out/ble.sh" "${BLESH_DIR}/ble.sh"
      ok "Created symlink to ble.sh in out directory"
    elif [[ ! -f "${BLESH_DIR}/ble.sh" ]]; then
      fail "BLE.sh repository doesn't contain expected files and build failed"
    else
      ok "Successfully found/built ble.sh"
    fi
  fi
  
  # Install BLE.sh
  if ! make -C "${BLESH_DIR}" install PREFIX="${HOME}/.local" >/dev/null; then
    fail "BLE.sh make install failed. See logs for details."
  fi
  
  # Verify installation succeeded
  if [[ ! -f "${HOME}/.local/share/blesh/ble.sh" ]]; then
    fail "BLE.sh installation verification failed: ble.sh not found in ${HOME}/.local/share/blesh/"
  fi
  
  ok "BLE.sh installed"
}

if ! is_done "BLESH_INSTALLED"; then
  if [[ -f "${BLESH_DIR}/ble.sh" ]]; then
    ok "BLE.sh already present – skipping clone"
  else
    install_blesh
  fi
  mark_done "BLESH_INSTALLED"
fi

###############################################################################
# 5. Create BLE.sh loader
###############################################################################
if ! is_done "BLESH_LOADER_DROPPED"; then
  step "Writing BLE.sh loader ${BLESH_LOADER}"
  install -m 644 /dev/null "${BLESH_LOADER}"
  cat > "${BLESH_LOADER}" <<'EOF'
# Auto-generated by SENTINEL installer
# shellcheck shell=bash
if [[ -n ${SENTINEL_BLESH_LOADED:-} ]]; then return; fi
export SENTINEL_BLESH_LOADED=1
# Fix for 'unrecognized attach method' error
export BLESH_ATTACH_METHOD="attach"
BLESH_MAIN="${HOME}/.local/share/blesh/ble.sh"
if [[ -f ${BLESH_MAIN} ]]; then
  source "${BLESH_MAIN}" --attach=attach 2>/dev/null || echo "[install] Warning: Failed to load ble.sh" >&2
fi
EOF
  mark_done "BLESH_LOADER_DROPPED"
  ok "BLE.sh loader ready"
fi

###############################################################################
# 6. Backup and update bashrc
###############################################################################
patch_bashrc() {
  local rc="$1"
  local sentinel_bashrc="${PROJECT_ROOT}/bashrc"
  
  # Check if .bashrc is owned by root or not writable
  if [[ ! -w "$rc" ]]; then
    warn "Cannot write to $rc (permission denied, may be owned by root)"
    step "Creating a new bashrc file and requesting to source it from your existing .bashrc"
    
    # Create a separate user bashrc file
    local user_bashrc="${HOME}/.bashrc.sentinel"
    
    # Copy SENTINEL bashrc to user_bashrc if available
    if [[ -f "$sentinel_bashrc" ]]; then
      safe_cp "$sentinel_bashrc" "$user_bashrc"
      chmod 644 "$user_bashrc"
      ok "SENTINEL bashrc installed as $user_bashrc"
      
      # Prompt to add sourcing line to original .bashrc via sudo
      if [[ $INTERACTIVE -eq 1 ]]; then
        read -r -t 30 -p "Would you like to add a line to source $user_bashrc from your $rc? You may need to enter sudo password. [y/N]: " confirm || confirm="n"
      else
        confirm="n"
        log "Non-interactive mode: using default answer '$confirm'"
      fi
      
      if [[ "$confirm" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        # Use sudo to modify the root-owned .bashrc
        sudo bash -c "echo '' >> $rc"
        sudo bash -c "echo '# SENTINEL Framework Integration' >> $rc"
        sudo bash -c "echo \"if [[ -f \\\"${user_bashrc}\\\" ]]; then\" >> $rc"
        sudo bash -c "echo \"    source \\\"${user_bashrc}\\\"\" >> $rc"
        sudo bash -c "echo 'fi' >> $rc"
        ok "Added sourcing line to $rc via sudo"
      else
        echo "Please manually add the following lines to your $rc:"
        echo ""
        echo "# SENTINEL Framework Integration"
        echo "if [[ -f \"${user_bashrc}\" ]]; then"
        echo "    source \"${user_bashrc}\""
        echo "fi"
        ok "Created $user_bashrc but you'll need to source it manually"
      fi
      
      # Add line to source bashrc.postcustom from the user_bashrc
      if ! grep -q "source.*bashrc.postcustom" "$user_bashrc"; then
        {
          echo ''
          echo '# SENTINEL Extensions'
          echo "if [[ -f \"\${HOME}/bashrc.postcustom\" ]]; then"
          echo "    source \"\${HOME}/bashrc.postcustom\""
          echo 'fi'
        } >> "$user_bashrc"
        ok "Added line to source bashrc.postcustom in $user_bashrc"
      fi
      
      return 0
    else
      fail "SENTINEL bashrc not found at $sentinel_bashrc"
      return 1
    fi
  fi
  
  # Normal flow for writable .bashrc
  if [[ -f "$rc" ]]; then
    safe_cp "$rc" "$rc.sentinel.bak.$(date +%s)"
    ok "Backed up $rc to $rc.sentinel.bak.$(date +%s)"
  fi
  step "Prompting for full replacement of $rc with SENTINEL bashrc"
  if [[ $INTERACTIVE -eq 1 ]]; then
    read -r -t 30 -p "Replace your $rc with SENTINEL's secure version? [y/N]: " confirm || confirm="n"
  else
    confirm="n"
    log "Non-interactive mode: using default answer '$confirm'"
  fi
  if [[ "$confirm" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    if [[ -f "$sentinel_bashrc" ]]; then
      safe_cp "$sentinel_bashrc" "$rc"
      chmod 644 "$rc"
      ok "SENTINEL bashrc installed as $rc"
      log "Replaced $rc with SENTINEL bashrc at $(date)"
    else
      warn "SENTINEL bashrc not found at $sentinel_bashrc; skipping replacement."
    fi
  else
    step "Patching existing bashrc to load SENTINEL"
    if ! grep -q "source.*bashrc.postcustom" "$rc"; then
      {
        echo ''
        echo '# SENTINEL Framework Integration'
        echo "if [[ -f \"\${HOME}/bashrc.postcustom\" ]]; then"
        echo "    # Safe loading mechanism that won't crash the terminal"
        echo "    source \"\${HOME}/bashrc.postcustom\" 2>/dev/null || echo \"[bashrc] Warning: Failed to load bashrc.postcustom\" >&2"
        echo 'fi'
      } >> "$rc"
      ok "Patched $rc to load SENTINEL"
    else
      ok "SENTINEL already integrated in $rc"
    fi
  fi
}

if ! is_done "BASHRC_PATCHED"; then
  patch_bashrc "${HOME}/.bashrc"
  mark_done "BASHRC_PATCHED"
fi

###############################################################################
# 7. Copy post-custom bootstrap
###############################################################################
if ! is_done "POSTCUSTOM_READY"; then
  step "Deploying bashrc.postcustom"
  install -m 644 "${PROJECT_ROOT}/bashrc.postcustom" "${HOME}/bashrc.postcustom"
  
  # Enable VENV_AUTO by default
  if ! grep -q '^export VENV_AUTO=1' "${HOME}/bashrc.postcustom"; then
    echo 'export VENV_AUTO=1  # Enable Python venv auto-activation' >> "${HOME}/bashrc.postcustom"
  fi
  
  ok "bashrc.postcustom in place with VENV_AUTO enabled"
  mark_done "POSTCUSTOM_READY"
fi

###############################################################################
# 8. Copy bash modules
###############################################################################
if ! is_done "CORE_MODULES_INSTALLED"; then
  MODULE_SRC="${PROJECT_ROOT}/bash_modules.d"
  
  if [[ -d "$MODULE_SRC" ]]; then
    step "Copying core bash modules from '${MODULE_SRC}/'"
    rsync -a --delete "${MODULE_SRC}/" "${MODULES_DIR}/"
    chmod 700 "${MODULES_DIR}"
    find "${MODULES_DIR}" -type f -exec chmod 600 {} \;
    ok "Modules synced → ${MODULES_DIR}"
    
    # Automatically run install-autocomplete.sh if present
    AUTOCOMPLETE_INSTALLER="${MODULE_SRC}/install-autocomplete.sh"
    if [[ -f "$AUTOCOMPLETE_INSTALLER" ]]; then
      step "Running modular autocomplete installer"
      # Export MODULES_DIR explicitly for install-autocomplete.sh
      export MODULES_DIR="${MODULES_DIR}"
      bash "$AUTOCOMPLETE_INSTALLER" || warn "install-autocomplete.sh failed; check logs."
      ok "Modular autocomplete installer completed"
    else
      warn "install-autocomplete.sh not found in $MODULE_SRC; autocomplete modules may not be fully installed."
    fi
  else
    warn "No bash_modules.d/ directory found – skipping module sync"
  fi
  
  mark_done "CORE_MODULES_INSTALLED"
fi

###############################################################################
# 9. Copy shell support files to HOME
###############################################################################
if ! is_done "SHELL_SUPPORT_COPIED"; then
  step "Copying shell support files to HOME"
  
  # Copy main files
  for file in bash_aliases bash_completion bash_functions; do
    if [[ -f "${PROJECT_ROOT}/$file" ]]; then
      step "Installing $file to $HOME/.$file"
      cp "${PROJECT_ROOT}/$file" "$HOME/.$file"
      chmod 644 "$HOME/.$file"
      ok "$file installed"
    else
      warn "$file not found in repository"
    fi
  done
  
  # Copy support directories
  for dir in bash_aliases.d bash_completion.d bash_functions.d contrib; do
    SRC_DIR="${PROJECT_ROOT}/$dir"
    DST_DIR="${HOME}/$dir"
    
    if [[ -d "$SRC_DIR" ]]; then
      step "Copying $dir content to $DST_DIR"
      rsync -a "$SRC_DIR/" "$DST_DIR/"
      
      # Set appropriate permissions
      find "$DST_DIR" -type d -exec chmod 700 {} \;
      find "$DST_DIR" -type f -exec chmod 600 {} \;
      
      ok "$dir content copied with secure permissions"
    else
      warn "$SRC_DIR not found; skipping."
    fi
  done
  
  # Create .bash_modules file if it doesn't exist
  if [[ ! -f "$HOME/.bash_modules" ]]; then
    cp "${PROJECT_ROOT}/.bash_modules" "$HOME/.bash_modules"
    chmod 644 "$HOME/.bash_modules"
    ok "Created $HOME/.bash_modules"
  fi
  
  mark_done "SHELL_SUPPORT_COPIED"
fi

###############################################################################
# 10. Enable FZF module if present
###############################################################################
FZF_BIN="$(command -v fzf 2>/dev/null || true)"
POSTCUSTOM_FILE="${HOME}/bashrc.postcustom"

if [[ -n "$FZF_BIN" ]]; then
  step "fzf detected at $FZF_BIN; enabling SENTINEL FZF module"
  if ! grep -q '^export SENTINEL_FZF_ENABLED=1' "$POSTCUSTOM_FILE"; then
    echo 'export SENTINEL_FZF_ENABLED=1  # Enable FZF integration' >> "$POSTCUSTOM_FILE"
    ok "Enabled SENTINEL FZF module in $POSTCUSTOM_FILE"
  else
    ok "SENTINEL FZF module already enabled"
  fi
else
  warn "fzf not found; SENTINEL FZF module not enabled. Install fzf and set export SENTINEL_FZF_ENABLED=1 in $POSTCUSTOM_FILE to enable."
fi

###############################################################################
# 11. Secure permissions on all files
###############################################################################
if ! is_done "PERMISSIONS_SECURED"; then
  step "Securing permissions on all SENTINEL files and modules"
  
  # Secure all directories
  find "${HOME}/bash_modules.d" -type d -exec chmod 700 {} \;
  find "${HOME}/logs" -type d -exec chmod 700 {} \;
  
  # Secure all files
  find "${HOME}/bash_modules.d" -type f -exec chmod 600 {} \;
  
  # Make executable files executable
  find "${HOME}/bash_aliases.d" -type f -exec chmod 700 {} \;
  
  # Secure .bashrc in home if it's writable
  if [[ -f "$HOME/.bashrc" && -w "$HOME/.bashrc" ]]; then 
    chmod 644 "$HOME/.bashrc"
    ok "Secured permissions on $HOME/.bashrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    warn "Cannot change permissions on $HOME/.bashrc (not writable)"
  fi
  
  # Secure .bashrc.sentinel if it exists instead
  if [[ -f "$HOME/.bashrc.sentinel" ]]; then 
    chmod 644 "$HOME/.bashrc.sentinel"
    ok "Secured permissions on $HOME/.bashrc.sentinel"
  fi
  
  # Secure .blerc if present
  if [[ -f "$HOME/.blerc" && -w "$HOME/.blerc" ]]; then 
    chmod 600 "$HOME/.blerc"
    ok "Secured permissions on $HOME/.blerc"
  elif [[ -f "$HOME/.blerc" ]]; then
    warn "Cannot change permissions on $HOME/.blerc (not writable)"
  fi
  
  # Secure cache directory
  if [[ -d "$HOME/.cache/blesh" ]]; then 
    chmod 700 "$HOME/.cache/blesh"
    ok "Secured permissions on $HOME/.cache/blesh"
  fi
  
  ok "Secure permissions set on all files and directories"
  mark_done "PERMISSIONS_SECURED"
fi

###############################################################################
# 12. Run verification checks
###############################################################################
step "Verifying installation"

# Ensure autocomplete directory exists before verification
if [[ ! -d "${HOME}/autocomplete" ]]; then
  step "Creating missing autocomplete directory"
  safe_mkdir "${HOME}/autocomplete" 755
  safe_mkdir "${HOME}/autocomplete/snippets" 755
  safe_mkdir "${HOME}/autocomplete/context" 755
  safe_mkdir "${HOME}/autocomplete/projects" 755
  safe_mkdir "${HOME}/autocomplete/params" 755
  
  # Ensure proper permissions explicitly
  chmod 755 "${HOME}/autocomplete" 2>/dev/null
  find "${HOME}/autocomplete" -type d -exec chmod 755 {} \; 2>/dev/null
  
  # Make any executable scripts actually executable
  find "${HOME}/autocomplete" -type f -name "*.sh" -exec chmod 755 {} \; 2>/dev/null
  
  ok "Autocomplete directories created with proper permissions"
fi

# Check that essential directories exist
for dir in "${HOME}/autocomplete" "${MODULES_DIR}"; do
  if [[ ! -d "$dir" ]]; then
    warn "Essential directory $dir is missing!"
  else
    ok "Directory $dir exists"
  fi
done

# Check that essential files exist
for file in "${HOME}/.bashrc" "${HOME}/bashrc.postcustom" "${BLESH_LOADER}"; do
  if [[ ! -f "$file" ]]; then
    warn "Essential file $file is missing!"
  else
    ok "File $file exists"
  fi
done

# Check that Python venv exists and has basic packages
VENV_PYTHON="${HOME}/venv/bin/python3"
if [[ ! -f "$VENV_PYTHON" ]]; then
  warn "Python virtual environment not properly installed"
else
  ok "Python virtual environment found at ${HOME}/venv"
  
  # Test importing a few key packages
  for pkg in numpy markovify tqdm; do
    if ! "$VENV_PYTHON" -c "import $pkg" &>/dev/null; then
      warn "Python package $pkg not installed in venv"
    else
      ok "Python package $pkg installed correctly"
    fi
  done
fi

# Check that autocomplete is installed
if [[ ! -f "${HOME}/bash_aliases.d/autocomplete" ]]; then
  warn "Autocomplete script not found in ${HOME}/bash_aliases.d/"
else
  ok "Autocomplete script installed"
fi

###############################################################################
# 13. Final summary
###############################################################################
echo
ok "Installation completed successfully!"
echo "• Open a new terminal OR run:  source '${HOME}/bashrc.postcustom'"
echo "• Verify with:                @autocomplete status"
echo "• Logs:                       ${LOG_DIR}/install.log"
echo 

# Add specific guidance for Debian login shells
echo "Important for Debian/Ubuntu users:"
echo "• If using login shells (common with GUI terminals), ensure your ~/.profile or ~/.bash_profile"
echo "  sources ~/.bashrc so SENTINEL loads correctly. Add these lines if missing:"
echo "    if [ -f \"$HOME/.bashrc\" ]; then"
echo "        . \"$HOME/.bashrc\""
echo "    fi"
echo

echo "If you encounter issues after installation:"
echo "1. Run: @autocomplete fix"
echo "2. Ensure ~/.profile sources ~/.bashrc (see above)"
echo "3. If problems persist, run: bash $0"
echo

# Run post-install check if present
POSTINSTALL_CHECK_SCRIPT="${PROJECT_ROOT}/sentinel_postinstall_check.sh"
if [[ -f "$POSTINSTALL_CHECK_SCRIPT" ]]; then
  step "Running SENTINEL post-installation verification"
  bash "$POSTINSTALL_CHECK_SCRIPT"
  ok "Post-installation verification complete. See summary above."
else
  warn "Post-installation verification script not found at $POSTINSTALL_CHECK_SCRIPT. Skipping."
fi 