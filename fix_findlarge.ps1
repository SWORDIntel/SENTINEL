# Fix line endings in findlarge file
$file = "$PWD\bash_functions.d\findlarge"
$content = [System.IO.File]::ReadAllText($file)
$content = $content -replace "`r`n", "`n"
[System.IO.File]::WriteAllText($file, $content)
Write-Host "Fixed line endings in $file" 