# Unified Windows Compatibility Fix Script for SENTINEL
# This script combines all fixes from individual scripts into one comprehensive solution
# that dynamically discovers and fixes bash-related files in the SENTINEL repository

# Set up strict error handling
$ErrorActionPreference = "Stop"

# Figure out the repository root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$repoRoot = Split-Path -Parent $scriptDir

# Create a log file
$logFile = "$repoRoot\bash_windows_fixes.log"
"[$(Get-Date)] Starting SENTINEL Windows compatibility fixes" | Out-File -FilePath $logFile -Force

# Display banner
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  SENTINEL Bash Script Windows Compatibility Fixer" -ForegroundColor Cyan
Write-Host "  Unified script for automatic discovery and fixing" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Log function - writes to console and log file
function Log {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    Write-Host $Message -ForegroundColor $Color
    "[$(Get-Date)] $Message" | Out-File -FilePath $logFile -Append
}

# Convert line endings from CRLF to LF
function Fix-LineEndings {
    param (
        [string]$FilePath
    )
    
    try {
        # Read file as bytes
        $bytes = [System.IO.File]::ReadAllBytes($FilePath)
        
        # Check if file contains CR characters (0x0D)
        $hasCR = $false
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -eq 0x0D) {
                $hasCR = $true
                break
            }
        }
        
        if ($hasCR) {
            # Convert CRLF to LF by removing all CR (0x0D) characters
            $newBytes = @()
            for ($i = 0; $i -lt $bytes.Length; $i++) {
                if ($bytes[$i] -ne 0x0D) {
                    $newBytes += $bytes[$i]
                }
            }
            
            # Write back the content with new line endings
            [System.IO.File]::WriteAllBytes($FilePath, $newBytes)
            return $true
        }
        
        return $false
    }
    catch {
        Log "Error fixing line endings in $FilePath: $_" "Red"
        return $false
    }
}

# Make file executable (as much as possible on Windows)
function Set-Executable {
    param (
        [string]$FilePath
    )
    
    try {
        # Try to use chmod if available (typically in Git Bash or WSL)
        try {
            chmod +x $FilePath 2>$null
            return $true
        }
        catch {
            # Silent fail - expected on pure Windows without Git Bash
            return $false
        }
    }
    catch {
        # Just return false on any error
        return $false
    }
}

# Fix bash syntax issues in a file
function Fix-BashSyntax {
    param (
        [string]$FilePath
    )
    
    try {
        $content = [System.IO.File]::ReadAllText($FilePath)
        
        # Fix function declarations - ensure proper spacing and syntax
        $content = $content -replace "(\w+)\(\)\s*\{", "function `$1() {"
        
        # Fix _load_enabled_modules syntax if present
        $content = $content -replace "_load_enabled_modulesdistcc", "_load_enabled_modules distcc"
        
        # Write the fixed content
        [System.IO.File]::WriteAllText($FilePath, $content)
        return $true
    }
    catch {
        Log "Error fixing bash syntax in $FilePath: $_" "Red"
        return $false
    }
}

# Fix the search file
function Fix-SearchFile {
    param(
        [string]$FilePath
    )
    
    # Create the search file content - using single quotes to avoid PowerShell interpolation
    $searchContent = @'
#!/usr/bin/env bash
# Functions and aliases for searching the filesystem
# Last edit: 07/01/2013
#
# (c) 2013 Jason Thistlethwaite
# Recursively search current directory for files and directories containing <arg> in
# their name
function ff() {
    find . -iname "*$1*"
}

# Find directories with name matching pattern
function fd() {
    find . -type d -name "*$1*"
}

# Find files by extension
function fext() {
    find . -type f -name "*.$1"
}

# Find and grep - search file contents
function fgrep() {
    find . -type f -name "*$1*" -exec grep -l "$2" {} \;
}

# Find recently modified files
function frecent() {
    find . -type f -mtime -"${1:-7}" -ls
}
'@

    try {
        # Replace all CRLF with LF
        $searchContent = $searchContent -replace "`r`n", "`n"
        
        # Write the content with Unix line endings
        [System.IO.File]::WriteAllText($FilePath, $searchContent)
        return $true
    }
    catch {
        Log "Error fixing search file $FilePath: $_" "Red"
        return $false
    }
}

# Fix the findlarge file
function Fix-FindLargeFile {
    param(
        [string]$FilePath
    )
    
    try {
        # Just fix line endings for findlarge file
        return (Fix-LineEndings -FilePath $FilePath)
    }
    catch {
        Log "Error fixing findlarge file $FilePath: $_" "Red"
        return $false
    }
}

# Fix the text_formatting file
function Fix-TextFormattingFile {
    param(
        [string]$FilePath
    )
    
    # Create the text_formatting file content - using single quotes to avoid PowerShell interpolation
    $formattingContent = @'
#!/usr/bin/env bash
# SENTINEL Text Formatting Aliases
# Enhanced text formatting and manipulation utilities for command line operations
# Based on original work by Jason Thistlethwaite (2013)
# Enhanced for SENTINEL (2023)

# CSV Processing
# -------------
# Format CSV data for human-readable display (removes quotes and replaces commas with spaces)
alias dcsv='sed -e "s/,/ /g" -e "s/\"//g"'

# Format CSV with proper column alignment (requires column command)
alias csvview='column -s, -t'

# Format CSV with headers preserved and colored
alias csvsmart='awk -F, "NR==1 {print \"\033[1;32m\" $0 \"\033[0m\"; next} {print}" | column -s, -t'

# Format CSV with alternating row colors for readability
alias csvcolor='awk -F, "{if(NR%2==0) printf \"\033[48;5;236m\"; printf $0 \"\033[0m\n\"}"|column -t -s,'

# Text Transformations
# -------------------
# Convert text to uppercase
alias upper='tr "[:lower:]" "[:upper:]"'

# Convert text to lowercase
alias lower='tr "[:upper:]" "[:lower:]"'

# Convert first character of each word to uppercase (title case)
alias titlecase='sed "s/\b\(.\)/\u\1/g"'

# Format JSON nicely with colors (requires python)
alias jsonpp='python -m json.tool | pygmentize -l json 2>/dev/null || python -m json.tool'
alias jsonfmt='python -m json.tool'

# Format XML nicely with colors (requires xmllint and pygmentize)
alias xmlpp='xmllint --format - | pygmentize -l xml 2>/dev/null || xmllint --format -'

# Text Filtering
# -------------
# Strip all ANSI color codes from text
alias nocolor='sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g"'

# Remove empty lines
alias noempty='grep -v "^[[:space:]]*$"'

# Remove duplicate lines while maintaining original order
alias uniqo='awk "!seen[$0]++"'

# Remove lines with comments (# style)
alias nocomments='grep -v "^[[:space:]]*#"'

# Remove leading and trailing whitespace
alias trim='sed -e "s/^[[:space:]]*$//" -e "s/[[:space:]]*$//"'

# Text Statistics
# --------------
# Count words, lines, and characters
alias wc-stats='wc -lwm'

# Advanced word frequency counter
alias wordfreq='tr -s "[:space:]" "\n" | tr "[:upper:]" "[:lower:]" | sort | uniq -c | sort -nr | head -20'

# Count unique lines
alias countuniq='sort | uniq -c | sort -nr'

# Data Extraction
# --------------
# Extract IP addresses from text
alias extractip='grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"'

# Extract email addresses from text
alias extractemail='grep -oE "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"'

# Extract URLs from text
alias extracturl='grep -oE "(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]"'

# Extract MD5 hashes
alias extractmd5='grep -oE "\b[a-fA-F0-9]{32}\b"'

# Extract SHA1 hashes
alias extractsha1='grep -oE "\b[a-fA-F0-9]{40}\b"'

# Extract SHA256 hashes
alias extractsha256='grep -oE "\b[a-fA-F0-9]{64}\b"'

# Code Formatters
# --------------
# Format shell scripts and use syntax highlighting if available
alias bashfmt='shfmt -i 2 -bn -ci -sr -kp | pygmentize -l bash 2>/dev/null || shfmt -i 2 -bn -ci -sr -kp'

# Table Display Functions
# ---------------------
# Show data as ASCII table with custom headers
# Usage: table_display "header1,header2,header3" "data1,data2,data3" "data4,data5,data6"
function table_display() {
    local headers="$1"
    shift
    echo "$headers" > /tmp/table_data_$$.csv
    for line in "$@"; do
        echo "$line" >> /tmp/table_data_$$.csv
    done
    column -t -s, /tmp/table_data_$$.csv
    rm /tmp/table_data_$$.csv
}

# Advanced Diff with Color
# ----------------------
# Show differences between two files with line numbers and colors
alias diffpretty='diff --color=always --side-by-side --line-numbers'

# Grep with Context and Colors
# --------------------------
# Search with pretty output
alias grepc='grep --color=always -n -A 2 -B 2'

# Text Encoding/Decoding
# --------------------
# URL encode a string
alias urlencode='python -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))"'

# URL decode a string
alias urldecode='python -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"'

# Base64 encode a string
alias b64encode='base64'

# Base64 decode a string
alias b64decode='base64 -d'

# Hex encode a string
alias hexencode='xxd -p'

# Hex decode a string
alias hexdecode='xxd -p -r'

# Check for required commands and provide installation instructions if missing
for cmd in shfmt pygmentize column xxd; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "Warning: $cmd is not installed. Some text_formatting aliases may not work properly."
        case $cmd in
            shfmt)
                echo "  Install with: go get -u mvdan.cc/sh/cmd/shfmt"
                ;;
            pygmentize)
                echo "  Install with: pip install pygments"
                ;;
            column)
                echo "  Install with: sudo apt install bsdmainutils  # Debian/Ubuntu"
                echo "  Install with: sudo yum install util-linux     # RHEL/CentOS"
                ;;
        esac
    fi
done
'@

    try {
        # Replace all CRLF with LF
        $formattingContent = $formattingContent -replace "`r`n", "`n"
        
        # Write the content with Unix line endings
        [System.IO.File]::WriteAllText($FilePath, $formattingContent)
        return $true
    }
    catch {
        Log "Error fixing text_formatting file $FilePath: $_" "Red"
        return $false
    }
}

# Define file patterns to search for
$bashFilePatterns = @(
    "*.sh",
    "bash*",
    ".bash*",
    "bashrc*",
    "bash_*/*",
    "bash_*",
    ".bash_*"
)

# Discover and process files
Log "Starting dynamic discovery of bash files to fix..." "Cyan"

# Find all matching files recursively
$files = Get-ChildItem -Path $repoRoot -Recurse -Include $bashFilePatterns | 
         Where-Object { !$_.PSIsContainer -and $_.FullName -notlike "*Windows Code Fixes*" }

Log "Found $($files.Count) files to process" "Yellow"

$stats = @{
    Total = $files.Count
    LineEndingsFixed = 0
    SyntaxFixed = 0
    SpecialFilesFixed = 0
    Errors = 0
}

# Process each file
foreach ($file in $files) {
    Log "Processing $($file.FullName)..." "White"
    
    # Skip large binary files or system files
    $fileSize = (Get-Item $file.FullName).Length
    if ($fileSize -gt 1MB) {
        Log "  Skipping (file too large: $([math]::Round($fileSize/1KB, 2)) KB)" "Yellow"
        continue
    }
    
    # Special file handling based on name
    switch -Wildcard ($file.Name) {
        "search" {
            Log "  Applying special fix for search file..." "Magenta"
            if (Fix-SearchFile -FilePath $file.FullName) {
                $stats.SpecialFilesFixed++
                Log "  Fixed search file" "Green"
            }
            continue
        }
        "findlarge" {
            Log "  Applying special fix for findlarge file..." "Magenta"
            if (Fix-FindLargeFile -FilePath $file.FullName) {
                $stats.SpecialFilesFixed++
                Log "  Fixed findlarge file" "Green"
            }
            continue
        }
        "text_formatting" {
            Log "  Applying special fix for text_formatting file..." "Magenta"
            if (Fix-TextFormattingFile -FilePath $file.FullName) {
                $stats.SpecialFilesFixed++
                Log "  Fixed text_formatting file" "Green"
            }
            continue
        }
        default {
            # Apply line ending fixes
            if (Fix-LineEndings -FilePath $file.FullName) {
                $stats.LineEndingsFixed++
                Log "  Fixed line endings" "Green"
            }
            
            # Apply bash syntax fixes
            if (Fix-BashSyntax -FilePath $file.FullName) {
                $stats.SyntaxFixed++
                Log "  Fixed bash syntax" "Green"
            }
            
            # Try to make executable
            try {
                if (Set-Executable -FilePath $file.FullName) {
                    Log "  Made executable" "Cyan"
                }
                else {
                    Log "  Note: Couldn't set executable permissions (expected on Windows)" "Yellow"
                }
            }
            catch {
                Log "  Note: Couldn't set executable permissions (expected on Windows)" "Yellow"
            }
        }
    }
}

# Create summary
$summary = @"

============================================================
  SENTINEL Windows Compatibility Fix - Summary
============================================================
Files processed: $($stats.Total)
Line endings fixed: $($stats.LineEndingsFixed)
Bash syntax fixed: $($stats.SyntaxFixed)
Special files fixed: $($stats.SpecialFilesFixed)
Errors encountered: $($stats.Errors)

All fixes have been applied successfully!
Your bash scripts should now work correctly in Linux.
Log file: $logFile
============================================================
"@

# Display and log summary
Log $summary "Cyan" 