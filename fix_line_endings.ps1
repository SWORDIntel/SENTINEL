# PowerShell script to fix CRLF to LF line endings thoroughly
# This script uses explicit binary reading to ensure proper detection and conversion

Write-Host "Starting thorough line ending conversion for all relevant files..."

# Define the file patterns to search for
$filePatterns = @("*.sh", "bash*", ".bash*", "bashrc*", "*_*")

# Find all matching files
$files = Get-ChildItem -Path . -Recurse -Include $filePatterns | Where-Object { !$_.PSIsContainer }

Write-Host "Found $($files.Count) files to process."

$convertedCount = 0
$alreadyCorrectCount = 0
$errorCount = 0

# Process each file
foreach ($file in $files) {
    try {
        # Read file as binary
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        
        # Check if file is empty
        if ($bytes.Length -eq 0) {
            Write-Host "Skipping empty file: $($file.FullName)"
            continue
        }
        
        # Check if file contains CR characters (0x0D)
        $hasCR = $false
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -eq 0x0D) {
                $hasCR = $true
                break
            }
        }
        
        if (!$hasCR) {
            Write-Host "Already correct (LF): $($file.FullName)" -ForegroundColor Green
            $alreadyCorrectCount++
            continue
        }
        
        # Convert CRLF to LF by removing all CR (0x0D) characters
        $newBytes = @()
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -ne 0x0D) {
                $newBytes += $bytes[$i]
            }
        }
        
        # Write back the content with new line endings
        [System.IO.File]::WriteAllBytes($file.FullName, $newBytes)
        
        Write-Host "Converted: $($file.FullName)" -ForegroundColor Yellow
        $convertedCount++
    }
    catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host "`nConversion Summary:" -ForegroundColor Cyan
Write-Host "Files processed: $($files.Count)" -ForegroundColor Cyan
Write-Host "Files already correct: $alreadyCorrectCount" -ForegroundColor Green
Write-Host "Files converted: $convertedCount" -ForegroundColor Yellow
Write-Host "Errors encountered: $errorCount" -ForegroundColor Red
Write-Host "`nLine ending conversion complete!" -ForegroundColor Cyan 