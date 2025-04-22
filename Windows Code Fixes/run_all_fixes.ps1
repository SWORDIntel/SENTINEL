# Master script to run all Windows Code Fixes
# This script executes all the fix scripts in the correct order to fix bash files

# Display a header
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  SENTINEL Bash Script Windows Code Fixes - Master Script" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Change to the parent directory since scripts expect to run from there
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$originalLocation = Get-Location
Set-Location (Split-Path -Parent $scriptDir)

try {
    # Display current working directory for verification
    Write-Host "Working Directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Starting fixes in sequence..." -ForegroundColor Cyan
    
    # 1. First fix line endings to ensure scripts can be processed properly
    Write-Host "STEP 1: Fixing line endings in all bash files..." -ForegroundColor Green
    & "$scriptDir\fix_bash_line_endings.ps1"
    Write-Host "Line ending fixes complete!" -ForegroundColor Green
    Write-Host ""
    
    # 2. Fix specific files with custom replacements
    Write-Host "STEP 2: Fixing specific bash syntax issues..." -ForegroundColor Green
    & "$scriptDir\fix_bash_syntax.ps1"
    Write-Host ""
    
    # 3. Fix the search file
    Write-Host "STEP 3: Fixing search file..." -ForegroundColor Green
    & "$scriptDir\fix_search.ps1"
    Write-Host ""
    
    # 4. Fix findlarge file
    Write-Host "STEP 4: Fixing findlarge file..." -ForegroundColor Green
    & "$scriptDir\fix_findlarge.ps1"
    Write-Host ""
    
    # 5. Fix text formatting    
    Write-Host "STEP 5: Fixing text_formatting file..." -ForegroundColor Green
    & "$scriptDir\fix_text_formatting.ps1"
    Write-Host ""
    
    # 6. Run the comprehensive line ending check one more time
    Write-Host "STEP 6: Final validation of line endings..." -ForegroundColor Green
    & "$scriptDir\convert_line_endings.ps1"
    Write-Host ""
    
    # Display completion message
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  All fixes have been applied successfully!" -ForegroundColor Green
    Write-Host "  Your bash scripts should now work correctly in Linux." -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Cyan
}
catch {
    # Error handling
    Write-Host "ERROR: An error occurred during the fix process:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Script execution aborted." -ForegroundColor Red
}
finally {
    # Restore original location
    Set-Location $originalLocation
} 