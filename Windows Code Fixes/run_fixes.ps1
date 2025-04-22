# SENTINEL Windows Compatibility Fix Launcher
# This script runs the unified fix script with proper error handling

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

try {
    # Display welcome message
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  SENTINEL Windows Compatibility Fix - Launcher" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script will fix line endings and syntax issues in bash files" -ForegroundColor Yellow
    Write-Host "to ensure they work correctly in Linux environments." -ForegroundColor Yellow
    Write-Host ""
    
    # Prompt for confirmation
    $confirmation = Read-Host "Do you want to proceed? (y/n)"
    if ($confirmation -ne 'y') {
        Write-Host "Operation cancelled." -ForegroundColor Red
        exit 0
    }
    
    # Run the unified fix script
    Write-Host "Running fixes..." -ForegroundColor Green
    
    # Execute the script directly
    & "$scriptDir\unified_fix_script.ps1"
    
    Write-Host "Fixes completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Fix process failed. Please check the log file for details." -ForegroundColor Red
    exit 1
} 