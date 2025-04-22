# Fix search file
# Figure out the parent directory - we need to run in the SENTINEL repo root
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$repoRoot = Split-Path -Parent $scriptDir

$content = @"
#!/usr/bin/env bash
# Functions and aliases for searching the filesystem
# Last edit: 07/01/2013
#
# (c) 2013 Jason Thistlethwaite
# Recursively search current directory for files and directories containing <arg> in
# their name
function ff() {
    find . -iname "*`$1*"
}

# Find directories with name matching pattern
function fd() {
    find . -type d -name "*`$1*"
}

# Find files by extension
function fext() {
    find . -type f -name "*.`$1"
}

# Find and grep - search file contents
function fgrep() {
    find . -type f -name "*`$1*" -exec grep -l "`$2" {} \;
}

# Find recently modified files
function frecent() {
    find . -type f -mtime -"`${1:-7}" -ls
}
"@

# Replace all CRLF with LF
$content = $content -replace "`r`n", "`n"

# Write the content with Unix line endings
$searchFile = "$repoRoot\bash_functions.d\search"
[System.IO.File]::WriteAllText($searchFile, $content)

Write-Host "Fixed bash_functions.d/search file with proper shebang and function declarations"

# Make the file executable
try {
    chmod +x $searchFile
    Write-Host "Made file executable"
} catch {
    # Ignore chmod errors on Windows
    Write-Host "Note: Couldn't set executable permissions (expected on Windows)"
} 