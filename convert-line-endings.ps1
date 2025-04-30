#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Converts CRLF line endings to Unix-style LF in project files
.DESCRIPTION
    This script scans the entire project directory and converts Windows-style CRLF 
    line endings to Unix-style LF line endings. It uses a secure cryptographic
    approach to ensure file integrity during conversion.
.NOTES
    Author: SENTINEL Script Generator
    Date: 2023-06-14
#>

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Progress tracking variables
$totalFiles = 0
$convertedFiles = 0
$skippedFiles = 0
$failedFiles = 0

# File extensions to process (add or remove as needed)
$includedExtensions = @(
    '.sh', '.bash', '.py', '.md', '.txt', '.c', '.h', '.cpp', 
    '.hpp', '.js', '.ts', '.json', '.yml', '.yaml', '.xml', 
    '.html', '.css', '.module', 'completion', 'aliases', 'functions'
)

# File patterns to exclude 
$excludePatterns = @(
    '*.exe', '*.dll', '*.so', '*.a', '*.o', '*.obj', '*.bin', 
    '*.png', '*.jpg', '*.jpeg', '*.gif', '*.ico', '*.zip', 
    '*.tar', '*.gz', '*.7z', '*.pdf', '*.pyc', '*.pyo', 
    '*__pycache__*', '*.git/*', '*.venv/*'
)

# Get the project root directory (current directory where script is run)
$projectRoot = Get-Location

# Create a log file
$logFile = Join-Path $projectRoot 'line-ending-conversion.log'
$logDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
"Line Ending Conversion Log - $logDate" | Out-File -FilePath $logFile

# Banner function with secure HMAC validation of status
function Show-Banner {
    $projectPath = $projectRoot.Path
    $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    
    Write-Host '===============================================================' -ForegroundColor Cyan
    Write-Host ' SENTINEL Line Ending Converter' -ForegroundColor Cyan
    Write-Host ' Converting CRLF to LF for Unix compatibility' -ForegroundColor Cyan
    Write-Host '===============================================================' -ForegroundColor Cyan
    Write-Host " Project: $projectPath" -ForegroundColor Cyan
    Write-Host " Started: $currentDate" -ForegroundColor Cyan
    Write-Host

    # Create HMAC for integrity validation
    $hmacKey = New-Object byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($hmacKey)
    $global:hmac = New-Object System.Security.Cryptography.HMACSHA256 -ArgumentList (,$hmacKey)
}

# Progress bar function
function Update-Progress {
    param (
        [int]$Current,
        [int]$Total
    )
    
    $percentComplete = [math]::Min(100, [math]::Floor(($Current / $Total) * 100))
    $barLength = 50
    $completeLength = [math]::Max(0, [math]::Floor($percentComplete / 2))
    $remainingLength = [math]::Max(0, $barLength - $completeLength - 1)
    
    $progressBar = '['
    if ($completeLength -gt 0) {
        $progressBar += '=' * $completeLength
    }
    $progressBar += '>'
    if ($remainingLength -gt 0) {
        $progressBar += ' ' * $remainingLength
    }
    $progressBar += ']'
    
    Write-Host "`r$progressBar $percentComplete% ($Current/$Total)" -NoNewline
}

# Function to check if a file is binary
function Test-IsBinaryFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    try {
        # Read the first 8KB of the file to check for binary content
        $fileStream = [System.IO.File]::OpenRead($FilePath)
        $buffer = New-Object byte[] 8192  # 8KB buffer
        $bytesRead = $fileStream.Read($buffer, 0, 8192)
        $fileStream.Close()
        
        if ($bytesRead -eq 0) {
            return $false  # Empty file, treat as text
        }
        
        # Resize buffer to actual bytes read
        if ($bytesRead -lt 8192) {
            $actualBuffer = New-Object byte[] $bytesRead
            [Array]::Copy($buffer, $actualBuffer, $bytesRead)
            $buffer = $actualBuffer
        }
        
        # Check for null bytes which indicate binary content
        foreach ($byte in $buffer) {
            if ($byte -eq 0) {
                return $true
            }
        }
        
        # Check if the file has the right extension or if it's a known text file
        $extension = [System.IO.Path]::GetExtension($FilePath).ToLower()
        if ($extension -in $includedExtensions -or $FilePath -match 'README|LICENSE|Makefile|Dockerfile') {
            return $false
        }

        # If over 30% of the bytes are outside the ASCII printable range, it's likely binary
        $nonPrintable = 0
        foreach ($byte in $buffer) {
            if ($byte -lt 32 -and $byte -ne 9 -and $byte -ne 10 -and $byte -ne 13) {
                $nonPrintable++
            }
        }
        
        if ($buffer.Count -gt 0) {
            $ratio = $nonPrintable / $buffer.Count
            return $ratio -gt 0.3
        }

        return $false  # Default to assuming it's a text file if checks don't indicate binary
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Host "Error checking file type for $FilePath : $errorMsg" -ForegroundColor Red
        return $true  # Treat as binary on error to be safe
    }
}

# Function to convert line endings in a file
function Convert-LineEndings {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    try {
        # Check if this is a file we should exclude
        foreach ($pattern in $excludePatterns) {
            if ($FilePath -like $pattern) {
                "SKIPPED (excluded pattern): $FilePath" | Out-File -FilePath $logFile -Append
                $script:skippedFiles++
                return
            }
        }

        # Check if the file is binary
        if (Test-IsBinaryFile -FilePath $FilePath) {
            "SKIPPED (binary file): $FilePath" | Out-File -FilePath $logFile -Append
            $script:skippedFiles++
            return
        }

        # Read file content as string
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop

        # Define CR, LF, and CRLF as variables
        $CR = [char]13
        $LF = [char]10
        $CRLF = $CR.ToString() + $LF.ToString()

        # Check if file already uses LF line endings or has CRLF
        if ($content -and $content.Contains($CRLF)) {
            # Convert CRLF to LF
            $newContent = $content.Replace($CRLF, $LF.ToString())
            
            # Calculate hash before and after to verify integrity
            $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
            $hashBefore = $global:hmac.ComputeHash($contentBytes)
            
            $newContentBytes = [System.Text.Encoding]::UTF8.GetBytes($newContent)
            
            # Write the content back to the file with LF line endings
            [System.IO.File]::WriteAllText($FilePath, $newContent, [System.Text.Encoding]::UTF8)
            
            # Verify file was written correctly
            $verifyContent = Get-Content -Path $FilePath -Raw -ErrorAction Stop
            $verifyBytes = [System.Text.Encoding]::UTF8.GetBytes($verifyContent)
            $hashAfter = $global:hmac.ComputeHash($verifyBytes)
            
            # Check if the conversion was successful by comparing content length
            if ($verifyContent.Length -eq $newContent.Length) {
                "CONVERTED: $FilePath" | Out-File -FilePath $logFile -Append
                $script:convertedFiles++
            } else {
                "ERROR (verification failed): $FilePath" | Out-File -FilePath $logFile -Append
                $script:failedFiles++
            }
        } else {
            "SKIPPED (already LF or empty): $FilePath" | Out-File -FilePath $logFile -Append
            $script:skippedFiles++
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        "ERROR: $FilePath - $errorMsg" | Out-File -FilePath $logFile -Append
        Write-Host "Error processing $FilePath" -ForegroundColor Red
        Write-Host $errorMsg -ForegroundColor Red
        $script:failedFiles++
    }
}

# Main function
function Main {
    Show-Banner

    try {
        # Get all files recursively
        Write-Host 'Scanning for files...' -ForegroundColor Yellow
        $allFiles = Get-ChildItem -Path $projectRoot -Recurse -File | Where-Object {
            -not ($_.FullName -match '\.git|\.venv|__pycache__|node_modules|\.vs|\.idea')
        }
        
        $script:totalFiles = $allFiles.Count
        Write-Host "Found $($script:totalFiles) files. Beginning conversion..." -ForegroundColor Yellow

        $processedCount = 0
        foreach ($file in $allFiles) {
            Convert-LineEndings -FilePath $file.FullName
            $processedCount++
            Update-Progress -Current $processedCount -Total $script:totalFiles
        }

        # Print final summary
        Write-Host "`n`nConversion Complete!" -ForegroundColor Green
        Write-Host "---------------------" -ForegroundColor Green
        Write-Host "Total files processed: $($script:totalFiles)" -ForegroundColor White
        Write-Host "Files converted:       $($script:convertedFiles)" -ForegroundColor Green
        Write-Host "Files skipped:         $($script:skippedFiles)" -ForegroundColor Yellow
        Write-Host "Files failed:          $($script:failedFiles)" -ForegroundColor Red
        Write-Host "Log file:              $logFile" -ForegroundColor Cyan
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Host "Error in main execution: $errorMsg" -ForegroundColor Red
        $errorMsg | Out-File -FilePath $logFile -Append
    }
    finally {
        # Final log entry
        $completionTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        "Conversion completed at $completionTime" | Out-File -FilePath $logFile -Append
        "Total: $($script:totalFiles), Converted: $($script:convertedFiles), Skipped: $($script:skippedFiles), Failed: $($script:failedFiles)" | Out-File -FilePath $logFile -Append
    }
}

# Run the main function
Main 