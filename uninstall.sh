#!/usr/bin/env bash
###############################################################################
# SENTINEL – Framework uninstaller
# -----------------------------------------------
# Hardened edition  •  v2.3.0  •  2025-05-16
# Completely removes the SENTINEL framework and restores backup files
###############################################################################

set -euo pipefail

# Colour helpers
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_blue=$'\033[1;34m'; c_reset=$'\033[0m'

# Logging functions
log() { printf '[%(%F %T)T] %b\n' -1 "$*"; }
step() { log "${c_blue}==>${c_reset} $*"; }
ok()   { log "${c_green}✔${c_reset}  $*"; }
warn() { log "${c_yellow}⚠${c_reset}  $*"; }
fail() { log "${c_red}✖${c_reset}  $*"; exit 1; }

# Define paths for SENTINEL components (expanded for thorough cleanup)
SENTINEL_DIRS=(
    "${HOME}/bash_aliases.d"
    "${HOME}/bash_completion.d"
    "${HOME}/bash_functions.d"
    "${HOME}/contrib"
    "${HOME}/logs"
    "${HOME}/autocomplete"
    "${HOME}/bash_modules.d"
    "${HOME}/venv"
    "${HOME}/.cache/blesh"
    "${HOME}/.local/share/blesh"
    "${HOME}/.sentinel"
)
SENTINEL_FILES=(
    "${HOME}/.bash_modules"
    "${HOME}/blesh_loader.sh"
    "${HOME}/bashrc.postcustom"
    "${HOME}/install.state"
    "${HOME}/.bashrc.precustom"
    "${HOME}/.bash_functions"
    "${HOME}/.bash_aliases"
    "${HOME}/.blerc"
    "${HOME}/.sentinel_*"
)

# Check for legacy installation
LEGACY_SENTINEL_HOME="${HOME}/.sentinel"

# No confirmation - complete automated removal
step "This will completely remove SENTINEL from your system"
warn "All SENTINEL files, settings, and customizations will be permanently deleted."
# Automatic confirmation - no prompting

# Create backup as a single zip file
step "Creating backup of current SENTINEL installation as a single zip file"
BACKUP_TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_ZIP="${HOME}/sentinel_backup_${BACKUP_TIMESTAMP}.zip"
TEMP_BACKUP_DIR="$(mktemp -d)"

# Create a temp directory for gathering files before zipping
mkdir -p "$TEMP_BACKUP_DIR/sentinel_backup"

# Backup legacy directory if it exists
if [[ -d "${LEGACY_SENTINEL_HOME}" ]]; then
    cp -r "${LEGACY_SENTINEL_HOME}" "$TEMP_BACKUP_DIR/sentinel_backup/"
fi

# Backup current SENTINEL files
for file in "${SENTINEL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        mkdir -p "$TEMP_BACKUP_DIR/sentinel_backup/files"
        cp "$file" "$TEMP_BACKUP_DIR/sentinel_backup/files/"
    fi
done

# Backup current SENTINEL directories
for dir in "${SENTINEL_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        dir_name=$(basename "$dir")
        mkdir -p "$TEMP_BACKUP_DIR/sentinel_backup/directories"
        cp -r "$dir" "$TEMP_BACKUP_DIR/sentinel_backup/directories/"
    fi
done

# Also backup .bashrc
if [[ -f "${HOME}/.bashrc" ]]; then
    mkdir -p "$TEMP_BACKUP_DIR/sentinel_backup/config"
    cp "${HOME}/.bashrc" "$TEMP_BACKUP_DIR/sentinel_backup/config/"
fi

# Create the zip file
cd "$TEMP_BACKUP_DIR"
zip -r "$BACKUP_ZIP" sentinel_backup > /dev/null 2>&1
cd - > /dev/null

# Clean up temp directory
rm -rf "$TEMP_BACKUP_DIR"

ok "SENTINEL backup created: $BACKUP_ZIP"

# Restore original .bashrc if a sentinel backup exists
if [[ -f "${HOME}/.bashrc.sentinel.bak" ]]; then
    step "Restoring original .bashrc from backup"
    cp "${HOME}/.bashrc.sentinel.bak" "${HOME}/.bashrc"
    ok "Original .bashrc restored"
else
    step "Removing SENTINEL references from .bashrc"
    if [[ -f "${HOME}/.bashrc" ]]; then
        # Remove SENTINEL integration lines from .bashrc
        sed -i '/# SENTINEL Framework Integration/,+3d' "${HOME}/.bashrc" || warn "Could not remove SENTINEL references from .bashrc"
        ok "SENTINEL references removed from .bashrc"
    fi
fi

# Remove legacy SENTINEL home directory if it exists
if [[ -d "${LEGACY_SENTINEL_HOME}" ]]; then
    step "Removing legacy SENTINEL home directory"
    rm -rf "${LEGACY_SENTINEL_HOME}"
    ok "Removed ${LEGACY_SENTINEL_HOME}"
fi

# Remove SENTINEL files
step "Removing SENTINEL files"
for file in "${SENTINEL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        rm -f "$file"
        ok "Removed $file"
    fi
done

# Remove SENTINEL directories - automatic wipe
step "Removing SENTINEL directories (automatic wipe)"
for dir in "${SENTINEL_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
        ok "Removed $dir"
    fi
done

# Remove BLE.sh
step "Removing BLE.sh"
if [[ -d "${HOME}/.local/share/blesh" ]]; then
    rm -rf "${HOME}/.local/share/blesh"
    ok "Removed BLE.sh installation"
fi

if [[ -d "${HOME}/.cache/blesh" ]]; then
    rm -rf "${HOME}/.cache/blesh"
    ok "Removed BLE.sh cache"
fi

if [[ -f "${HOME}/.blerc" ]]; then
    rm -f "${HOME}/.blerc"
    ok "Removed .blerc configuration file"
fi

# Create a clean minimal .bashrc file with proper permissions
step "Creating a clean minimal .bashrc file"

# Backup current .bashrc first
cp "${HOME}/.bashrc" "${HOME}/.bashrc.backup.$(date +%Y%m%d%H%M%S)"
ok "Original .bashrc backed up"

# Create a minimal .bashrc with secure permissions
cat > "${HOME}/.bashrc" << 'EOF'
#!/usr/bin/env bash
# Clean minimal .bashrc - After SENTINEL removal
# Created by SENTINEL uninstaller

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Include any additional custom aliases if file exists
if [ -f ~/.bash_aliases_custom ]; then
    . ~/.bash_aliases_custom
fi
EOF

# Set proper permissions on .bashrc
chmod 600 "${HOME}/.bashrc"
ok "Created a clean .bashrc with secure permissions (600)"

# Final message
echo
ok "SENTINEL has been completely uninstalled!"
echo "• All SENTINEL components have been thoroughly removed"
echo "• A backup of your SENTINEL installation is available at: ${BACKUP_ZIP}"
echo "• A clean minimal .bashrc has been created with secure permissions"
echo "• Please restart your terminal for changes to take effect"
echo "• If you want to reinstall SENTINEL later, run: bash /path/to/SENTINEL/install.sh" 