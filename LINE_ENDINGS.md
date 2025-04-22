# Line Ending Management for SENTINEL

This document describes how to maintain proper line endings when developing SENTINEL across different operating systems.

## Problem

SENTINEL is designed to work on Linux/Unix systems where line endings are LF (Line Feed, `\n`). However, Windows uses CRLF (Carriage Return + Line Feed, `\r\n`) as line endings, which can cause syntax errors when bash scripts with Windows line endings are run on Linux systems.

Common error messages include:
```
-bash: /root/.bashrc: line 1182: syntax error near unexpected token `('
-bash: /root/.bashrc: line 1182: `  findlarge() {'
```

## Solution

### On Linux Systems

Use the following command to convert all relevant files from CRLF to LF:

```bash
find . -type f -name "*.sh" -o -name "bash*" -o -name "*_*" | xargs -I{} bash -c 'tr -d "\r" < "{}" > "{}.fixed" && mv "{}.fixed" "{}"'
```

### On Windows Systems

#### Using PowerShell

1. Run the following PowerShell command to convert line endings:

```powershell
Get-ChildItem -Recurse -Include *.sh,bash*,*_*,*.d/* | 
Where-Object { !$_.PSIsContainer } | 
ForEach-Object { 
    $content = [System.IO.File]::ReadAllText($_.FullName)
    $content = $content -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($_.FullName, $content)
    Write-Host "Converted: $($_.FullName)"
}
```

#### Using Text Editors

- **VS Code**: Set `files.eol` to `\n` in your settings.json
- **Notepad++**: Edit > EOL Conversion > Unix (LF)
- **Sublime Text**: View > Line Endings > Unix

## Git Configuration

Configure Git to handle line endings appropriately:

### Global Git Configuration

```bash
# Configure Git to convert CRLF to LF on commit
git config --global core.autocrlf input
```

### Repository-specific configuration

SENTINEL includes a `.gitattributes` file that enforces LF line endings:

```
# Enforce LF line endings
* text=auto eol=lf

# Binary files should not be modified
*.png binary
*.jpg binary
*.gif binary
```

## Verifying Line Endings

To check if a file has the correct line endings:

### On Linux

```bash
file filename  # Should say "with LF line terminators"
```

### On Windows (PowerShell)

```powershell
$bytes = [System.IO.File]::ReadAllBytes("filename")
$hasCR = $false
foreach ($byte in $bytes) {
    if ($byte -eq 0x0D) {
        $hasCR = $true
        break
    }
}
if ($hasCR) { "Contains CR (CRLF)" } else { "LF only" }
```

## When Contributing to SENTINEL

1. Always ensure your bash scripts have LF line endings before committing
2. Run the appropriate conversion command if you're developing on Windows
3. Verify that scripts are executable with `chmod +x filename` on Linux systems 