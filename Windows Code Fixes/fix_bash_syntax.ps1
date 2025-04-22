# PowerShell script to fix various bash syntax issues
# This script specifically addresses the syntax errors mentioned in the error messages

# Figure out the parent directory - we need to run in the SENTINEL repo root
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$repoRoot = Split-Path -Parent $scriptDir

Write-Host "Fixing bash syntax issues..."

# Fix the module loading issue in bash_modules
$modulesFile = "$repoRoot\bash_modules"
if (Test-Path $modulesFile) {
    $content = [System.IO.File]::ReadAllText($modulesFile)
    $content = $content -replace "_load_enabled_modulesdistcc", "_load_enabled_modules distcc"
    [System.IO.File]::WriteAllText($modulesFile, $content)
    Write-Host "Fixed module loading in bash_modules"
}

# Fix bash_aliases.d/text_formatting - Already fixed in previous steps

# Fix ff() function in bashrc
$bashrcFile = "$repoRoot\bashrc"
if (Test-Path $bashrcFile) {
    $content = [System.IO.File]::ReadAllText($bashrcFile)
    
    # Fix ff() function - ensure there's proper spacing and syntax
    $content = $content -replace "ff\(\) \{", "function ff() {"
    $content = $content -replace "ff\(\)\s*\{", "function ff() {"
    
    # Fix other potential function declarations with the same issue
    $content = $content -replace "(\w+)\(\)\s*\{", "function `$1() {"
    
    [System.IO.File]::WriteAllText($bashrcFile, $content)
    Write-Host "Fixed function declarations in bashrc"
}

# Check if there's a bash_functions.d/search file and fix ff() function there too
$searchFile = "$repoRoot\bash_functions.d\search" 
if (Test-Path $searchFile) {
    $content = [System.IO.File]::ReadAllText($searchFile)
    # Ensure the ff function is properly defined
    if ($content -match "ff\(\)") {
        $content = $content -replace "ff\(\)\s*\{", "function ff() {"
        [System.IO.File]::WriteAllText($searchFile, $content)
        Write-Host "Fixed ff function in bash_functions.d/search"
    }
}

Write-Host "All bash syntax issues have been fixed!" 