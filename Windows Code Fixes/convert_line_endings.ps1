# PowerShell script to convert CRLF to LF line endings in all relevant files
# This script finds all bash scripts and configuration files and converts their line endings

# Figure out the parent directory - we need to run in the SENTINEL repo root
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$repoRoot = Split-Path -Parent $scriptDir

Write-Host "Converting line endings from CRLF to LF for bash scripts and configuration files..."

# Define the file patterns to search for
$filePatterns = @("*.sh", "bash*", "bashrc*", "*_*", ".bash*")

# Find all matching files
$files = Get-ChildItem -Path $repoRoot -Recurse -File -Include $filePatterns | 
         Where-Object { $_.FullName -notlike "*Windows Code Fixes*" }

Write-Host "Found $($files.Count) files to process."

# Process each file
foreach ($file in $files) {
    try {
        # Read the content with current line endings
        $content = Get-Content -Path $file.FullName -Raw
        
        # Skip binary files or already processed files
        if ($null -eq $content -or -not $content.Contains("`r`n")) {
            Write-Host "Skipping $($file.FullName) (already has LF endings or is binary)"
            continue
        }
        
        # Replace CRLF with LF
        $newContent = $content.Replace("`r`n", "`n")
        
        # Write back the content with new line endings
        [System.IO.File]::WriteAllText($file.FullName, $newContent)
        
        Write-Host "Converted: $($file.FullName)"
    }
    catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host "Line ending conversion complete!" 