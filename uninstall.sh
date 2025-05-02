#!/usr/bin/env bash
# SENTINEL Uninstallation Script
# Secure ENhanced Terminal INtelligent Layer
#
# This script removes SENTINEL components and restores backup files
# Last Update: 2023-12-15

# Set text color variables
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}${BOLD}"
echo '  ██████ ▓█████  ███▄    █ ▄▄▄█████▓ ██▓ ███▄    █ ▓█████  ██▓    '
echo '▒██    ▒ ▓█   ▀  ██ ▀█   █ ▓  ██▒ ▓▒▓██▒ ██ ▀█   █ ▓█   ▀ ▓██▒    '
echo '░ ▓██▄   ▒███   ▓██  ▀█ ██▒▒ ▓██░ ▒░▒██▒▓██  ▀█ ██▒▒███   ▒██░    '
echo '  ▒   ██▒▒▓█  ▄ ▓██▒  ▐▌██▒░ ▓██▓ ░ ░██░▓██▒  ▐▌██▒▒▓█  ▄ ▒██░    '
echo '▒██████▒▒░▒████▒▒██░   ▓██░  ▒██▒ ░ ░██░▒██░   ▓██░░▒████▒░██████▒'
echo '▒ ▒▓▒ ▒ ░░░ ▒░ ░░ ▒░   ▒ ▒   ▒ ░░   ░▓  ░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▓  ░'
echo '░ ░▒  ░ ░ ░ ░  ░░ ░░   ░ ▒░    ░     ▒ ░░ ░░   ░ ▒░ ░ ░  ░░ ░ ▒  ░'
echo '░  ░  ░     ░      ░   ░ ░   ░       ▒ ░   ░   ░ ░    ░     ░ ░   '
echo '      ░     ░  ░         ░           ░           ░    ░  ░    ░  ░'
echo -e "${NC}"
echo -e "${RED}${BOLD}SENTINEL Uninstallation Script${NC}"
echo -e "${RED}-----------------------------------${NC}\n"

# Check if running as root (not recommended)
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}Warning: Running this script as root is not recommended${NC}"
    echo -e "${YELLOW}The script will modify files in your home directory${NC}"
    echo -e "${YELLOW}It's better to run it as a regular user${NC}"
    echo -e "${YELLOW}Continue anyway?${NC}"
    read -p "$(echo -e "${YELLOW}Continue as root? [y/N] ${NC}")" continue_as_root
    case "$continue_as_root" in
        'Y'|'y'|'yes')
            echo -e "${YELLOW}Continuing as root user${NC}"
            ;;
        *)
            echo -e "${GREEN}Please run this script as a non-root user${NC}"
            exit 1
            ;;
    esac
fi

# Confirm uninstallation
echo -e "${RED}${BOLD}WARNING: This will remove all SENTINEL components from your system.${NC}"
echo -e "${YELLOW}Backup files will be moved to ~/BAK/ directory.${NC}"
read -p "$(echo -e "${YELLOW}Continue with uninstallation? [y/N] ${NC}")" confirm
case "$confirm" in
    'Y'|'y'|'yes')
        echo -e "${YELLOW}Proceeding with uninstallation...${NC}"
        ;;
    *)
        echo -e "${GREEN}Uninstallation canceled.${NC}"
        exit 0
        ;;
esac

# Create backup directory
BAK_DIR="${HOME}/BAK"
echo -e "${BLUE}Creating backup directory: ${BAK_DIR}${NC}"
mkdir -p "${BAK_DIR}" || {
    echo -e "${RED}Failed to create backup directory. Aborting.${NC}"
    exit 1
}

# Create a log of the uninstallation process
LOG_FILE="${BAK_DIR}/sentinel_uninstall.log"
echo "SENTINEL Uninstallation - $(date)" > "$LOG_FILE"

# Function to back up file before removal
backup_before_remove() {
    local file="$1"
    local basefile=$(basename "$file")
    
    if [ -e "$file" ]; then
        echo -e "${YELLOW}Moving $file to ${BAK_DIR}/${basefile}${NC}"
        mv "$file" "${BAK_DIR}/${basefile}" 2>/dev/null || {
            echo -e "${RED}Failed to move $file to backup directory${NC}"
            echo "Failed to backup: $file" >> "$LOG_FILE"
            return 1
        }
        echo "Backed up: $file to ${BAK_DIR}/${basefile}" >> "$LOG_FILE"
        return 0
    else
        echo "File not found: $file" >> "$LOG_FILE"
        return 1
    fi
}

# Function to handle backup files
restore_from_backup() {
    local bakfile="$1"
    local origfile="${bakfile%.bak}"
    
    if [ -f "$bakfile" ]; then
        echo -e "${GREEN}Restoring $origfile from backup${NC}"
        
        # Check if original file exists but not as a SENTINEL version
        if [ -f "$origfile" ] && ! grep -q "SENTINEL" "$origfile" 2>/dev/null; then
            # Original exists but isn't a SENTINEL file, move both to BAK
            echo -e "${YELLOW}Both original and backup exist, moving both to ${BAK_DIR}${NC}"
            mv "$origfile" "${BAK_DIR}/$(basename "$origfile")"
            mv "$bakfile" "${BAK_DIR}/$(basename "$bakfile")"
        else
            # Either original doesn't exist or is a SENTINEL version
            mv "$bakfile" "$origfile"
            echo "Restored: $origfile from $bakfile" >> "$LOG_FILE"
        fi
        return 0
    else
        echo "Backup not found: $bakfile" >> "$LOG_FILE"
        return 1
    fi
}

# Step 1: Remove SENTINEL directories
echo -e "\n${BLUE}${BOLD}Step 1: Removing SENTINEL directories${NC}"
for dir in "${HOME}/.sentinel" \
           "${HOME}/secure_workspace" \
           "${HOME}/.bash_modules.d"; do
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}Removing directory: $dir${NC}"
        rm -rf "$dir" 2>/dev/null && {
            echo "Removed directory: $dir" >> "$LOG_FILE"
        } || {
            echo -e "${RED}Failed to remove directory: $dir${NC}"
            echo "Failed to remove directory: $dir" >> "$LOG_FILE"
        }
    fi
done

# Step 1B: Clean up cache files (especially ble.sh which causes problems)
echo -e "\n${BLUE}${BOLD}Step 1B: Cleaning up cache files${NC}"

# Check for and kill any ble.sh processes that might be keeping files locked
echo -e "${YELLOW}Checking for ble.sh processes...${NC}"
# Find any processes related to ble.sh
BLESH_PROCS=$(ps -ef | grep -i ble.sh | grep -v grep | awk '{print $2}')
if [ -n "$BLESH_PROCS" ]; then
    echo -e "${YELLOW}Found ble.sh related processes:${NC}"
    ps -f $BLESH_PROCS
    read -p "$(echo -e "${YELLOW}Kill these processes? [y/N] ${NC}")" kill_procs
    case "$kill_procs" in
        'Y'|'y'|'yes')
            echo -e "${YELLOW}Terminating ble.sh processes...${NC}"
            for pid in $BLESH_PROCS; do
                kill -9 $pid 2>/dev/null
                echo "Terminated process: $pid" >> "$LOG_FILE"
            done
            echo -e "${GREEN}Processes terminated${NC}"
            # Small delay to allow processes to exit
            sleep 1
            ;;
        *)
            echo -e "${YELLOW}Keeping processes running.${NC}"
            echo "Skipped termination of ble.sh processes (user declined)" >> "$LOG_FILE"
            ;;
    esac
fi

if [ -d "${HOME}/.cache/blesh" ]; then
    echo -e "${YELLOW}Cleaning up ble.sh cache directory...${NC}"
    
    # First attempt to fix permissions
    chmod -R 755 "${HOME}/.cache/blesh" 2>/dev/null || {
        echo -e "${RED}Failed to set permissions on ${HOME}/.cache/blesh, attempting alternative cleanup...${NC}"
    }
    
    # Target problematic files first
    find "${HOME}/.cache/blesh" -name "*.part" -type f -delete 2>/dev/null
    find "${HOME}/.cache/blesh" -name "decode.readline*.txt*" -type f -delete 2>/dev/null
    
    # Try to remove the entire directory
    rm -rf "${HOME}/.cache/blesh" 2>/dev/null && {
        echo "Removed ble.sh cache directory" >> "$LOG_FILE"
        echo -e "${GREEN}Successfully removed ble.sh cache directory${NC}"
    } || {
        echo -e "${RED}Could not completely remove ${HOME}/.cache/blesh, using sudo...${NC}"
        
        # Ask for sudo if needed
        read -p "$(echo -e "${YELLOW}Attempt to remove cache files with sudo? [y/N] ${NC}")" use_sudo
        case "$use_sudo" in
            'Y'|'y'|'yes')
                sudo rm -rf "${HOME}/.cache/blesh" 2>/dev/null && {
                    echo "Removed ble.sh cache directory with sudo" >> "$LOG_FILE"
                    echo -e "${GREEN}Successfully removed ble.sh cache directory with sudo${NC}"
                } || {
                    echo -e "${RED}Failed to remove ${HOME}/.cache/blesh even with sudo${NC}"
                    echo "Failed to remove ble.sh cache directory" >> "$LOG_FILE"
                }
                ;;
            *)
                echo -e "${YELLOW}Skipping removal of problematic cache files${NC}"
                echo "Skipped removal of ble.sh cache (user declined sudo)" >> "$LOG_FILE"
                ;;
        esac
    }
fi

# Check for other SENTINEL-related cache
if [ -d "${HOME}/.cache/sentinel" ]; then
    echo -e "${YELLOW}Removing SENTINEL cache directory...${NC}"
    rm -rf "${HOME}/.cache/sentinel" 2>/dev/null && {
        echo "Removed SENTINEL cache directory" >> "$LOG_FILE"
    } || {
        echo -e "${RED}Failed to remove ${HOME}/.cache/sentinel${NC}"
        echo "Failed to remove SENTINEL cache directory" >> "$LOG_FILE"
    }
fi

# Step 2: Remove SENTINEL files
echo -e "\n${BLUE}${BOLD}Step 2: Removing SENTINEL files${NC}"
SENTINEL_FILES=(
    "${HOME}/.bashrc"
    "${HOME}/.bash_aliases"
    "${HOME}/.bash_functions"
    "${HOME}/.bash_completion"
    "${HOME}/.bash_modules"
    "${HOME}/.bashrc.precustom"
    "${HOME}/.bashrc.postcustom"
    "${HOME}/.bookmarks"
)

for file in "${SENTINEL_FILES[@]}"; do
    if [ -f "$file" ] && grep -q "SENTINEL" "$file" 2>/dev/null; then
        backup_before_remove "$file"
    fi
done

# Step 3: Handle backup files
echo -e "\n${BLUE}${BOLD}Step 3: Handling backup files${NC}"
# Find all .bak files in home directory
find "${HOME}" -maxdepth 1 -name "*.bak" -type f | while read bakfile; do
    base_file="${bakfile%.bak}"
    
    # If original file doesn't exist or is a SENTINEL file, restore from backup
    if [ ! -f "$base_file" ] || grep -q "SENTINEL" "$base_file" 2>/dev/null; then
        restore_from_backup "$bakfile"
    else
        # Otherwise move the backup to the BAK directory
        echo -e "${YELLOW}Moving backup file $bakfile to ${BAK_DIR}${NC}"
        mv "$bakfile" "${BAK_DIR}/$(basename "$bakfile")" 2>/dev/null
        echo "Moved backup: $bakfile to ${BAK_DIR}" >> "$LOG_FILE"
    fi
done

# Step 4: Restore original bash environment
echo -e "\n${BLUE}${BOLD}Step 4: Restoring original bash environment${NC}"
# Create a minimal .bashrc if none exists
if [ ! -f "${HOME}/.bashrc" ]; then
    echo -e "${YELLOW}Creating minimal .bashrc file${NC}"
    cat > "${HOME}/.bashrc" << 'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
EOF
    echo "Created minimal .bashrc" >> "$LOG_FILE"
fi

# Step 5: Remove leftover directories
echo -e "\n${BLUE}${BOLD}Step 5: Cleaning up leftover directories${NC}"
# Define optional directories to remove
OPTIONAL_DIRS=(
    "${HOME}/.bash_aliases.d"
    "${HOME}/.bash_functions.d"
    "${HOME}/.bash_completion.d"
    "${HOME}/build_workspace"
    "${HOME}/.distcc"
    "${HOME}/.ccache"
    "${HOME}/obfuscated_files"
)

echo -e "${YELLOW}The following directories can be removed:${NC}"
for i in "${!OPTIONAL_DIRS[@]}"; do
    if [ -d "${OPTIONAL_DIRS[$i]}" ]; then
        echo -e "  $((i+1)). ${OPTIONAL_DIRS[$i]}"
    else
        unset 'OPTIONAL_DIRS[$i]'
    fi
done

echo -e "${YELLOW}Do you want to remove these directories?${NC}"
read -p "$(echo -e "${YELLOW}Remove directories? [A]ll, [N]one, [S]elect: ${NC}")" remove_dirs
case "$remove_dirs" in
    'A'|'a'|'all')
        for dir in "${OPTIONAL_DIRS[@]}"; do
            if [ -d "$dir" ]; then
                echo -e "${YELLOW}Removing directory: $dir${NC}"
                rm -rf "$dir" 2>/dev/null && {
                    echo "Removed directory: $dir" >> "$LOG_FILE"
                } || {
                    echo -e "${RED}Failed to remove directory: $dir${NC}"
                    echo "Failed to remove directory: $dir" >> "$LOG_FILE"
                }
            fi
        done
        ;;
    'N'|'n'|'none')
        echo -e "${GREEN}Keeping all directories.${NC}"
        ;;
    'S'|'s'|'select')
        for i in "${!OPTIONAL_DIRS[@]}"; do
            if [ -d "${OPTIONAL_DIRS[$i]}" ]; then
                read -p "$(echo -e "${YELLOW}Remove ${OPTIONAL_DIRS[$i]}? [y/N] ${NC}")" remove_dir
                case "$remove_dir" in
                    'Y'|'y'|'yes')
                        echo -e "${YELLOW}Removing directory: ${OPTIONAL_DIRS[$i]}${NC}"
                        rm -rf "${OPTIONAL_DIRS[$i]}" 2>/dev/null && {
                            echo "Removed directory: ${OPTIONAL_DIRS[$i]}" >> "$LOG_FILE"
                        } || {
                            echo -e "${RED}Failed to remove directory: ${OPTIONAL_DIRS[$i]}${NC}"
                            echo "Failed to remove directory: ${OPTIONAL_DIRS[$i]}" >> "$LOG_FILE"
                        }
                        ;;
                    *)
                        echo -e "${GREEN}Keeping directory: ${OPTIONAL_DIRS[$i]}${NC}"
                        ;;
                esac
            fi
        done
        ;;
    *)
        echo -e "${GREEN}Keeping all directories.${NC}"
        ;;
esac

# Step 5B: Clean up leftover config files
echo -e "\n${BLUE}${BOLD}Step 5B: Cleaning up leftover configuration files${NC}"
EXTRA_CONFIG_FILES=(
    "${HOME}/.sentinel_paths"
    "${HOME}/.local/share/blesh/init-attach.sh"
    "${HOME}/.local/share/blesh/init-complete.sh"
    "${HOME}/.local/share/blesh/init-cmap.sh"
    "${HOME}/.local/share/blesh/init-color.sh"
    "${HOME}/.local/share/blesh/init-bind.sh"
)

echo -e "${YELLOW}Checking for additional configuration files...${NC}"
for file in "${EXTRA_CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${YELLOW}Found: $file${NC}"
        backup_before_remove "$file"
    fi
done

# Also look for ble.sh installation directory
if [ -d "${HOME}/.local/share/blesh" ]; then
    echo -e "${YELLOW}ble.sh installation found at ${HOME}/.local/share/blesh${NC}"
    read -p "$(echo -e "${YELLOW}Remove ble.sh installation? [y/N] ${NC}")" remove_blesh
    case "$remove_blesh" in
        'Y'|'y'|'yes')
            echo -e "${YELLOW}Removing ble.sh installation...${NC}"
            rm -rf "${HOME}/.local/share/blesh" 2>/dev/null && {
                echo "Removed ble.sh installation directory" >> "$LOG_FILE"
                echo -e "${GREEN}Successfully removed ble.sh installation${NC}"
            } || {
                echo -e "${RED}Failed to remove ${HOME}/.local/share/blesh${NC}"
                echo "Failed to remove ble.sh installation directory" >> "$LOG_FILE"
            }
            ;;
        *)
            echo -e "${GREEN}Keeping ble.sh installation.${NC}"
            ;;
    esac
fi

# Step 5C: Security cleanup
echo -e "\n${BLUE}${BOLD}Step 5C: Security cleanup${NC}"

# Check for and securely remove sensitive files
SENSITIVE_FILES=(
    "${HOME}/.sentinel/auth_tokens"
    "${HOME}/.sentinel/api_keys"
    "${HOME}/.sentinel/secure_tokens"
    "${HOME}/.sentinel/hmac_keys"
    "${HOME}/.sentinel/credentials.json"
    "${HOME}/.sentinel/tokens.db"
)

echo -e "${YELLOW}Checking for sensitive credential files...${NC}"
FOUND_SENSITIVE=0
for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        FOUND_SENSITIVE=1
        echo -e "${YELLOW}Found sensitive file: $file${NC}"
    fi
done

if [ $FOUND_SENSITIVE -eq 1 ]; then
    echo -e "${RED}Warning: Sensitive credential files were found${NC}"
    read -p "$(echo -e "${YELLOW}Securely delete these files? [Y/n] ${NC}")" secure_delete
    case "$secure_delete" in
        'N'|'n'|'no')
            echo -e "${YELLOW}Skipping secure deletion. Files will be kept in backup.${NC}"
            for file in "${SENSITIVE_FILES[@]}"; do
                if [ -f "$file" ]; then
                    backup_before_remove "$file"
                fi
            done
            ;;
        *)
            echo -e "${YELLOW}Securely wiping sensitive files...${NC}"
            for file in "${SENSITIVE_FILES[@]}"; do
                if [ -f "$file" ]; then
                    # Check for shred command
                    if command -v shred &>/dev/null; then
                        echo -e "${YELLOW}Securely wiping: $file${NC}"
                        shred -u -z -n 3 "$file" 2>/dev/null && {
                            echo "Securely wiped: $file" >> "$LOG_FILE"
                        } || {
                            echo -e "${RED}Failed to securely wipe $file${NC}"
                            echo "Failed to securely wipe: $file" >> "$LOG_FILE"
                            backup_before_remove "$file"
                        }
                    else
                        # Fallback if shred not available
                        echo -e "${YELLOW}Secure shred not available, overwriting with zeros: $file${NC}"
                        dd if=/dev/zero of="$file" bs=1k count=1 conv=notrunc 2>/dev/null
                        rm -f "$file" 2>/dev/null && {
                            echo "Overwritten and removed: $file" >> "$LOG_FILE"
                        } || {
                            echo -e "${RED}Failed to overwrite and remove $file${NC}"
                            echo "Failed to overwrite: $file" >> "$LOG_FILE"
                            backup_before_remove "$file"
                        }
                    fi
                fi
            done
            ;;
    esac
fi

# Clean up any temporary security tokens in standard locations
if [ -d "${HOME}/.cache/sentinel_tokens" ]; then
    echo -e "${YELLOW}Removing temporary security tokens...${NC}"
    rm -rf "${HOME}/.cache/sentinel_tokens" 2>/dev/null && {
        echo "Removed temporary token directory" >> "$LOG_FILE"
    } || {
        echo -e "${RED}Failed to remove ${HOME}/.cache/sentinel_tokens${NC}"
        echo "Failed to remove temporary token directory" >> "$LOG_FILE"
    }
fi

# Step 6: Finalize uninstallation
echo -e "\n${BLUE}${BOLD}Step 6: Finalizing uninstallation${NC}"
echo -e "${GREEN}${BOLD}SENTINEL has been successfully uninstalled.${NC}"
echo -e "${YELLOW}Backup files have been moved to: ${BAK_DIR}${NC}"
echo -e "${YELLOW}Log file saved as: ${LOG_FILE}${NC}"
echo -e "${GREEN}You may want to start a new shell session to apply changes.${NC}"

# Set permissions on the uninstall log
chmod 600 "$LOG_FILE"

echo -e "${GREEN}${BOLD}Thank you for using SENTINEL!${NC}\n"

# Exit success
exit 0 