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

# Strict mode to catch errors
set -euo pipefail

# Define critical variables
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LOG_DIR="${HOME}/logs"
STATE_FILE="${HOME}/install.state"
BLESH_DIR="${HOME}/.local/share/blesh"
BLESH_LOADER="${HOME}/blesh_loader.sh"
MODULES_DIR="${HOME}/bash_modules.d"

# Colour helpers
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_blue=$'\033[1;34m'; c_reset=$'\033[0m'

# Ensure log directory exists
mkdir -p "${LOG_DIR}"
chmod 700 "${LOG_DIR}"

# Enhanced logging with timestamp
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="${LOG_DIR}/install.log"
    echo "[$timestamp] $*" | tee -a "$log_file"
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

# OS detection for permissions (placeholder for future logic)
OS_TYPE="$(uname)"

# Python version check before venv setup
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
if [[ ! "$PYTHON_VERSION" =~ ^3\.[6-9] ]] && [[ ! "$PYTHON_VERSION" =~ ^3\.[1-9][0-9] ]]; then
  fail "Python 3.6+ is required (found $PYTHON_VERSION)"
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
  mkdir -p \
    "${HOME}"/{autocomplete/{snippets,context,projects,params},logs,bash_modules.d} \
    "${HOME}/.cache/blesh" \
    "${HOME}/"{bash_aliases.d,bash_completion.d,bash_functions.d,contrib}
  chmod 700 "${LOG_DIR}" \
    "${HOME}/"{bash_aliases.d,bash_completion.d,bash_functions.d,contrib}
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
  if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR" || fail "Failed to create Python virtual environment"
    if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
      fail "Virtual environment creation failed - activate script not found"
    fi
    ok "Virtual environment created at $VENV_DIR"
  else
    ok "Virtual environment already exists at $VENV_DIR"
  fi
  source "$VENV_DIR/bin/activate"
  step "Installing required Python packages in venv"
  "$VENV_DIR/bin/pip" install --upgrade pip
  "$VENV_DIR/bin/pip" install npyscreen tqdm requests beautifulsoup4 numpy scipy scikit-learn joblib markovify unidecode rich
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
  git -C "${BLESH_DIR}" checkout v0.4.0
  if [[ ! -f "${BLESH_DIR}/ble.sh" ]]; then
    fail "BLE.sh repository doesn't contain expected files"
  fi
  make -C "${BLESH_DIR}" install PREFIX="${HOME}/.local" >/dev/null
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
BLESH_MAIN="${HOME}/.local/share/blesh/ble.sh"
if [[ -f ${BLESH_MAIN} ]]; then
  source "${BLESH_MAIN}" --attach=overhead
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
  if [[ -f "$rc" ]]; then
    safe_cp "$rc" "$rc.sentinel.bak.$(date +%s)"
    ok "Backed up $rc to $rc.sentinel.bak.$(date +%s)"
  fi
  step "Prompting for full replacement of $rc with SENTINEL bashrc"
  if [[ $INTERACTIVE -eq 1 ]]; then
    read -t 30 -p "Replace your $rc with SENTINEL's secure version? [y/N]: " confirm || confirm="n"
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
      echo '' >> "$rc"
      echo '# SENTINEL Framework Integration' >> "$rc"
      echo 'if [[ -f "${HOME}/bashrc.postcustom" ]]; then' >> "$rc"
      echo '    source "${HOME}/bashrc.postcustom"' >> "$rc"
      echo 'fi' >> "$rc"
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
  
  # Secure .bashrc in home
  if [[ -f "$HOME/.bashrc" ]]; then 
    chmod 644 "$HOME/.bashrc"
  fi
  
  # Secure .blerc if present
  if [[ -f "$HOME/.blerc" ]]; then 
    chmod 600 "$HOME/.blerc"
  fi
  
  # Secure cache directory
  if [[ -d "$HOME/.cache/blesh" ]]; then 
    chmod 700 "$HOME/.cache/blesh"
  fi
  
  ok "Secure permissions set on all files and directories"
  mark_done "PERMISSIONS_SECURED"
fi

###############################################################################
# 12. Run verification checks
###############################################################################
step "Verifying installation"

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
echo "If you encounter issues after installation:"
echo "1. Run: @autocomplete fix"
echo "2. If that doesn't work, run: bash $0"

# Run post-install check if present
POSTINSTALL_CHECK_SCRIPT="${PROJECT_ROOT}/sentinel_postinstall_check.sh"
if [[ -f "$POSTINSTALL_CHECK_SCRIPT" ]]; then
  step "Running SENTINEL post-installation verification"
  bash "$POSTINSTALL_CHECK_SCRIPT"
  ok "Post-installation verification complete. See summary above."
else
  warn "Post-installation verification script not found at $POSTINSTALL_CHECK_SCRIPT. Skipping."
fi

# Safe wrapper for rsync, cp, git clone
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
safe_git_clone() {
  if ! git clone "$@"; then
    fail "git clone operation failed: $*"
  fi
} 