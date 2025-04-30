# SENTINEL Line Endings Fix Guide

## The Problem

If you're seeing errors like these when running Bash scripts or sourcing `.bashrc`:

```
-bash: /path/to/file: line X: syntax error near unexpected token `$'{\r''
-bash: /path/to/file: line X: `function() {
```

This is caused by **Windows-style line endings (CRLF)** in files that Linux expects to have **Unix-style line endings (LF)**.

Windows uses Carriage Return + Line Feed (`\r\n` or CRLF) as line endings, while Linux and macOS use just Line Feed (`\n` or LF). When Bash tries to interpret files with Windows line endings, it sees the `\r` character (Carriage Return) as part of the text rather than a line ending marker, causing syntax errors.

## Quick Fix

We've provided several tools to fix this issue:

### On Windows (Before transferring to Linux)

1. **Using PowerShell**:
   ```powershell
   cd \path\to\SENTINEL
   contrib\fix_line_endings.ps1
   ```

2. **Using Python directly**:
   ```powershell
   cd \path\to\SENTINEL
   python contrib\fix_line_endings.py --verbose --all
   ```

### On Linux (After seeing the error)

1. **Using the Bash script**:
   ```bash
   cd /path/to/SENTINEL
   bash contrib/fix_line_endings.sh
   ```

2. **Using Python directly**:
   ```bash
   cd /path/to/SENTINEL
   python3 contrib/fix_line_endings.py --verbose --all
   ```

3. **Manual fix with dos2unix** (if available):
   ```bash
   # Install dos2unix if not already installed
   sudo apt-get install dos2unix  # Debian/Ubuntu
   sudo dnf install dos2unix      # Fedora
   sudo pacman -S dos2unix        # Arch Linux
   
   # Fix line endings in all shell scripts
   find . -type f -name "*.sh" -exec dos2unix {} \;
   find . -name ".bash*" -exec dos2unix {} \;
   find . -name "bash_*" -exec dos2unix {} \;
   find ./bash_completion.d/ -type f -exec dos2unix {} \;
   ```

After fixing the line endings, source your .bashrc again:
```bash
source ~/.bashrc
```

## How to Prevent This Issue

### Git Configuration

You can configure Git to automatically handle line endings:

```bash
# Configure Git to convert CRLF to LF on commit
git config --global core.autocrlf input

# Configure Git to reject files with CRLF line endings
git config --global core.safecrlf true
```

### Editor Configuration

Most code editors can be configured to use LF line endings for shell scripts:

- **VS Code**: Add to settings.json:
  ```json
  "files.eol": "\n",
  "[shellscript]": {
    "files.eol": "\n"
  }
  ```

- **Notepad++**: Settings → Preferences → New Document → Format → Unix (LF)

- **Vim**: Add to .vimrc:
  ```
  set fileformat=unix
  ```

## Technical Details

The conversion scripts in the `contrib/` directory:

1. Search for shell script files with Windows line endings
2. Create backups of affected files with `.bak-winformat` extension
3. Convert CRLF (`\r\n`) to LF (`\n`) line endings
4. Log all changes to `bash_line_endings_fix.log`

The scripts use different methods depending on the environment:
- Windows uses a Python script for the conversion
- Linux tries to use `dos2unix` first, and falls back to Python if not available

## Additional Information

`.gitattributes` file can be used to enforce line endings on a per-file basis:

```
# Set default behavior to automatically normalize line endings
* text=auto

# Explicitly declare text files you want to always be normalized and converted
# to native line endings on checkout
*.sh text eol=lf
.bash* text eol=lf
bash_* text eol=lf
```

This ensures that all shell scripts are always checked out with LF line endings regardless of the operating system. 