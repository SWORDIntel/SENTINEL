#!/usr/bin/env bash
# SENTINEL Installer - Bash Functions

ensure_local_bin_in_path() {
    step "Ensuring ~/.local/bin is in PATH"
    local postcustom="${HOME}/bashrc.postcustom"

    if [[ ! -f "$postcustom" ]]; then
        touch "$postcustom"
        chmod 644 "$postcustom"
    fi

    if ! grep -q '\.local/bin' "$postcustom"; then
        {
            echo ''
            echo '# Ensure ~/.local/bin is in PATH for pip-installed tools'
            echo 'if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then'
            echo '    export PATH="$HOME/.local/bin:$PATH"'
            echo 'fi'
        } >> "$postcustom"
        ok "Added ~/.local/bin to PATH in bashrc.postcustom"
    else
        ok "~/.local/bin already in PATH configuration"
    fi
}

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
    if ! grep -q "source.*waveterm.rc" "$rc"; then
      {
        echo ''
        echo '# SENTINEL Framework Integration'
        echo "if [[ -f \"\${HOME}/waveterm.rc\" ]]; then"
        echo "    # Safe loading mechanism that won't crash the terminal"
        echo "    source \"\${HOME}/waveterm.rc\" 2>/dev/null || echo \"[bashrc] Warning: Failed to load waveterm.rc\" >&2"
        echo 'fi'
      } >> "$rc"
      ok "Patched $rc to load SENTINEL"
    else
      ok "SENTINEL already integrated in $rc"
    fi
  fi
}

copy_postcustom_bootstrap() {
    if ! is_done "POSTCUSTOM_READY"; then
      step "Deploying bashrc.postcustom and waveterm.rc"
      install -m 644 "${PROJECT_ROOT}/bashrc.postcustom" "${HOME}/bashrc.postcustom"
      install -m 644 "${PROJECT_ROOT}/waveterm.rc" "${HOME}/waveterm.rc"


      ok "bashrc.postcustom and waveterm.rc in place with VENV_AUTO enabled"
      mark_done "POSTCUSTOM_READY"
    fi
}

copy_bash_modules() {
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
}

copy_shell_support_files() {
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
}

enable_fzf_module() {
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
}

secure_permissions() {
    if ! is_done "PERMISSIONS_SECURED"; then
      step "Securing permissions on all SENTINEL files and modules"

      # Secure all directories
      find "${HOME}/bash_modules.d" -type d -exec chmod 700 {} \;
      find "${HOME}/logs" -type d -exec chmod 700 {} \;

      # Secure all files
      find "${HOME}/bash_modules.d" -type f -exec chmod 600 {} \;

      # Make executable files executable
      find "${HOME}/bash_aliases.d" -type f -exec chmod 700 {} \;
      find "${HOME}/.local/bin" -type f -exec chmod 755 {} \; 2>/dev/null || true

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
}

run_verification_checks() {
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
    for dir in "${HOME}/autocomplete" "${MODULES_DIR}" "${HOME}/.local/bin"; do
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

    # Verify PATH configuration
    if grep -q '\.local/bin' "${HOME}/bashrc.postcustom"; then
      ok "PATH configuration includes ~/.local/bin"
    else
      warn "PATH may not include ~/.local/bin"
    fi
}

final_summary() {
    echo
    ok "Installation completed successfully!"
    echo "Installer version: ${INSTALLER_VERSION}"
    echo
    echo "• Open a new terminal OR run:  source '${HOME}/bashrc.postcustom'"
    echo "• Verify with:                @autocomplete status"
    echo "• Logs:                       ${LOG_DIR}/install.log"
    echo "• Rollback if needed:         ${ROLLBACK_SCRIPT}"
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
    echo "3. Check PATH includes ~/.local/bin: echo \$PATH"
    echo "4. If problems persist, run: bash $0"
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

    # Create a summary file for referencem
    SUMMARY_FILE="${HOME}/SENTINEL_INSTALL_SUMMARY.txt"
    {
      echo "SENTINEL Installation Summary"
      echo "============================="
      echo "Date: $(date)"
      echo "Version: ${INSTALLER_VERSION}"
      echo "Python: $PYTHON_CMD"
      echo "Install State: ${STATE_FILE}"
      echo "Rollback Script: ${ROLLBACK_SCRIPT}"
      echo ""
      echo "Key Locations:"
      echo "- Modules: ${MODULES_DIR}"
      echo "- Logs: ${LOG_DIR}"
      echo "- Python venv: ${HOME}/venv"
      echo "- BLE.sh: ${BLESH_DIR}"
      echo ""
      echo "To activate SENTINEL in new shells, one of these should be present:"
      echo "1. ${HOME}/.bashrc sources ${HOME}/bashrc.postcustom"
      echo "2. ${HOME}/.bashrc.sentinel is sourced from ${HOME}/.bashrc"
      echo ""
      echo "For support, check the logs at ${LOG_DIR}/install.log"
    } > "$SUMMARY_FILE"

    ok "Installation summary saved to ${SUMMARY_FILE}"
}
