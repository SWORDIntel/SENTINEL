# FZF Integration with SENTINEL

This document provides instructions for integrating [fzf](https://github.com/junegunn/fzf) (Fuzzy Finder) with the SENTINEL framework.

## Overview

FZF is a general-purpose command-line fuzzy finder that enhances your command-line experience with interactive filtering and search capabilities.

## Prerequisites

- Make sure fzf is installed on your system. If not, you can install it using:
  ```bash
  # For Debian/Ubuntu
  sudo apt install fzf
  
  # For Fedora
  sudo dnf install fzf
  
  # For macOS
  brew install fzf
  
  # Using git
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
  ```

- SENTINEL's ble.sh integration must be properly installed and working.

## Configuration

### Automatic Setup

When SENTINEL is installed, it automatically configures fzf integration if fzf is detected on your system. This includes:

1. Setting up key bindings for directory and history navigation
2. Configuring completion for files and directories
3. Enabling git integration for fzf

### Manual Setup

If you need to manually set up the integration:

1. Make sure the following files are installed in your `~/.local/share/blesh/contrib/integration/` directory:
   - `fzf.common.bash`
   - `fzf-completion.bash`
   - `fzf-git.bash`
   - `fzf-initialize.bash`
   - `fzf-key-bindings.bash`
   - `fzf-menu.bash`

2. Add the following line to your `~/.bashrc` or `~/.bash_profile`:
   ```bash
   # Load fzf integration for SENTINEL
   source ~/.local/share/blesh/contrib/integration/fzf-initialize.bash
   ```

## Troubleshooting

If you encounter issues with the fzf integration:

1. **ble.sh not loading properly**:
   - Ensure ble.sh is correctly installed: `~/.local/share/blesh/ble.sh` should exist
   - Check file permissions: `chmod +x ~/.local/share/blesh/ble.sh`
   - Add `source ~/.local/share/blesh/ble.sh` to your `.bashrc` file

2. **Permission issues**:
   - Ensure all integration files are executable: 
     ```bash
     chmod +x ~/.local/share/blesh/contrib/integration/fzf*
     ```

3. **Missing features**:
   - Verify fzf is properly installed: `which fzf` should return a valid path
   - Check if the fzf integration files are properly sourced

## Key Bindings

- `Ctrl+R` - Search command history
- `Ctrl+T` - Search for files and directories
- `Alt+C` - Change directory interactively
- `**<TAB>` - Fuzzy completion for files and directories

## Customization

You can customize fzf behavior by setting environment variables:

```bash
# Set default command for listing files
export FZF_DEFAULT_COMMAND='fd --type f'

# Customize the appearance
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Set command for Ctrl+T
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
```

Add these to your `.bashrc` file before sourcing ble.sh and SENTINEL.

## SENTINEL-Specific Features

When integrated with SENTINEL, fzf provides enhanced functionality:

1. Command chain prediction with fuzzy matching
2. Smart parameter suggestion based on command history
3. Context-aware autocompletion
4. Secure token generation for commands that require authentication 