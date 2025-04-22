# PowerShell script to fix line endings in all bash scripts
# Converts Windows CRLF line endings to Unix LF for all bash-related files
# Author: SENTINEL

# Figure out the parent directory - we need to run in the SENTINEL repo root
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$repoRoot = Split-Path -Parent $scriptDir

# File patterns to look for
$filePatterns = @(
    "*.sh",
    "bash*",
    ".bash*",
    "bashrc*",
    "bash_*/*",
    "bash_*",
    ".bash_*"
)

$logFile = "$repoRoot\bash_line_endings_fix.log"
"Starting fix at $(Get-Date)" | Out-File -FilePath $logFile -Force

Write-Host "Starting comprehensive line ending conversion for bash files..." -ForegroundColor Cyan
"Starting comprehensive line ending conversion for bash files..." | Out-File -FilePath $logFile -Append

# Find all matching files - make sure to search in the repo root
$files = Get-ChildItem -Path $repoRoot -Recurse -Include $filePatterns | Where-Object { !$_.PSIsContainer }

Write-Host "Found $($files.Count) files to process" -ForegroundColor Yellow
"Found $($files.Count) files to process" | Out-File -FilePath $logFile -Append

$convertedCount = 0
$alreadyCorrectCount = 0
$errorCount = 0

# Process each file
foreach ($file in $files) {
    try {
        $message = "Processing $($file.FullName)..."
        Write-Host $message -NoNewline
        $message | Out-File -FilePath $logFile -Append
        
        # Skip the Windows Code Fixes directory itself
        if ($file.FullName -like "*Windows Code Fixes*") {
            Write-Host " Skipped (Fixes script)" -ForegroundColor Yellow
            " Skipped (Fixes script)" | Out-File -FilePath $logFile -Append
            continue
        }
        
        # Read file binary content
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        
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
            [System.IO.File]::WriteAllBytes($file.FullName, $newBytes)
            
            # Make the file executable if it's not already
            try {
                chmod +x $file.FullName
            } catch {
                # Ignore chmod errors on Windows
            }
            
            Write-Host " Fixed!" -ForegroundColor Green
            " Fixed!" | Out-File -FilePath $logFile -Append
            $convertedCount++
        } else {
            Write-Host " Already correct" -ForegroundColor Cyan
            " Already correct" | Out-File -FilePath $logFile -Append
            $alreadyCorrectCount++
        }
    }
    catch {
        $errorMessage = " Error: $_"
        Write-Host $errorMessage -ForegroundColor Red
        $errorMessage | Out-File -FilePath $logFile -Append
        $errorCount++
    }
}

# Print summary
$summary = @"

Conversion Summary:
Files processed: $($files.Count)
Files already correct: $alreadyCorrectCount
Files converted: $convertedCount
Errors encountered: $errorCount

Line ending conversion complete!
Your bash scripts should now work correctly in a Linux environment.
"@

Write-Host $summary -ForegroundColor Cyan
$summary | Out-File -FilePath $logFile -Append

Write-Host "Complete log saved to $logFile" -ForegroundColor Yellow 