# Fix line endings in findlarge file
# Figure out the parent directory - we need to run in the SENTINEL repo root
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$repoRoot = Split-Path -Parent $scriptDir

$file = "$repoRoot\bash_functions.d\findlarge"
$content = [System.IO.File]::ReadAllText($file)
$content = $content -replace "`r`n", "`n"
[System.IO.File]::WriteAllText($file, $content)
Write-Host "Fixed line endings in $file"

# Make the file executable
try {
    chmod +x $file
    Write-Host "Made file executable"
} catch {
    # Ignore chmod errors on Windows
    Write-Host "Note: Couldn't set executable permissions (expected on Windows)"
} 