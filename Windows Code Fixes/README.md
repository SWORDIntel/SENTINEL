# SENTINEL Windows Code Fixes

This directory contains PowerShell scripts designed to fix common issues with bash scripts when working in a Windows environment.

## Purpose

On Windows, bash scripts often encounter issues due to:

1. **Line ending differences**: Windows uses CRLF (`\r\n`) while Linux uses LF (`\n`)
2. **Syntax differences**: Subtle syntax variations between Windows and Linux shell environments
3. **File permissions**: Executable permissions don't work the same on Windows

These scripts are designed to automatically fix these issues so your bash scripts work correctly when transferred to a Linux environment.

## Available Scripts

### Main Scripts

- **`run_fixes.ps1`**: The primary script you should run - it will launch the unified fix script with proper error handling and user-friendly prompts.
- **`unified_fix_script.ps1`**: A comprehensive script that dynamically finds and fixes all bash-related files in the repository.

### Individual Fix Scripts (Legacy)

These individual scripts have been consolidated into the unified script but are kept for reference:

- `convert_line_endings.ps1`: Converts CRLF to LF in all bash files
- `fix_bash_line_endings.ps1`: More comprehensive line ending fixes
- `fix_bash_syntax.ps1`: Fixes common bash syntax issues
- `fix_findlarge.ps1`: Fixes the findlarge script
- `fix_line_endings.ps1`: Targeted line ending fixes for specific files
- `fix_search.ps1`: Fixes the search utility script
- `fix_text_formatting.ps1`: Fixes the text_formatting file
- `run_all_fixes.ps1`: Legacy script that ran all the individual fixes in sequence

## Usage

1. Open PowerShell with Administrator privileges
2. Navigate to the Windows Code Fixes directory
3. Run: `.\run_fixes.ps1`
4. Follow the prompts

The script will:
- Find all bash-related files in the repository
- Fix line endings
- Fix common syntax issues
- Apply special fixes to specific files
- Generate a log file with details of all changes

## Known Issues and Solutions

### PowerShell Linter Errors

The `unified_fix_script.ps1` file may show linter errors related to variable references with the `$_` automatic variable in error handling. These are false positives and don't affect script functionality.

The errors look like:
```
Variable reference is not valid. ':' was not followed by a valid variable name character. Consider using ${} to delimit the name.
```

These can be safely ignored as they relate to PowerShell's built-in error variable which works correctly despite the linter warnings.

### File Permission Handling

Windows doesn't natively support Unix-style file permissions. The scripts attempt to use `chmod` if available (such as when Git for Windows is installed), but this won't work on all Windows installations.

When transferring scripts to Linux, you may still need to run:
```bash
chmod +x scriptname.sh
```

### Working with WSL

If you're using Windows Subsystem for Linux (WSL), we recommend:

1. Using the fix scripts first to correct line endings and syntax
2. Then copying files to your WSL environment
3. Setting execute permissions within WSL using `chmod +x filename`

## Integration with Python Virtual Environments

If you're using the Python-based ML features of SENTINEL, ensure your virtual environment is compatible with Windows:

1. Create your virtual environment with: `python -m venv .venv`
2. Activate it in PowerShell with: `.\.venv\Scripts\Activate.ps1`
3. You may need to run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` (once per PowerShell session)

## Output

The script creates a detailed log file at the repository root: `bash_windows_fixes.log`

## Requirements

- PowerShell 5.0 or higher
- Administrator privileges (recommended)
- Git for Windows (optional, provides better chmod support)

## Troubleshooting

If you encounter issues:

1. Check the log file for detailed error messages
2. Ensure you're running PowerShell as Administrator
3. Try running individual fix scripts if the unified script fails
4. For persistent issues, please open a GitHub issue with the log file attached 