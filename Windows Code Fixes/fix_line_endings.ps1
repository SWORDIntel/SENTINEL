# PowerShell script to fix line endings in bash scripts
# This converts Windows CRLF line endings to Unix LF

$filesToFix = @(
    "bash_functions.d/findlarge",
    "bash_functions.d/search"
)

Write-Host "Starting line ending conversion for bash script files..." -ForegroundColor Cyan

foreach ($file in $filesToFix) {
    Write-Host "Processing $file..." -ForegroundColor Yellow
    
    if (Test-Path $file) {
        # Read file binary content
        $bytes = [System.IO.File]::ReadAllBytes($file)
        
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
            [System.IO.File]::WriteAllBytes($file, $newBytes)
            
            Write-Host "  Fixed line endings in $file" -ForegroundColor Green
            
            # Make the file executable
            Write-Host "  Making file executable..." -ForegroundColor Yellow
            chmod +x $file
        } else {
            Write-Host "  File already has correct line endings" -ForegroundColor Green
        }
    } else {
        Write-Host "  File not found: $file" -ForegroundColor Red
    }
}

Write-Host "Line ending conversion complete!" -ForegroundColor Cyan 