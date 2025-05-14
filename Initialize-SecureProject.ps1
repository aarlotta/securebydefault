# Initialize-SecureProject.ps1
# Script to initialize the Secure PowerShell Module project structure

<#
.SYNOPSIS
    Initializes a secure PowerShell module project structure with Git repository and required directories.
.DESCRIPTION
    Creates a standardized project structure for PowerShell module development, including Git initialization,
    directory structure, and configuration files. The script is idempotent and can be run multiple times
    safely without affecting existing content.
.VERSION
    1.0.0
.PROMPT_ID
    Prompt 001
#>

param(
    [switch]$Force
)

# Define Unicode characters for status indicators
$WARNING_SYMBOL = [char]0x26A0  # ⚠
$SUCCESS_SYMBOL = [char]0x2714  # ✔
$INFO_SYMBOL = [char]0x2139     # ℹ

# Set UTF-8 encoding for proper emoji support
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Check execution policy and provide guidance if needed
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -eq 'Restricted') {
    Write-Host "`n$WARNING_SYMBOL  PowerShell execution policy is currently set to 'Restricted'" -ForegroundColor Yellow
    Write-Host "To run this script, you need to change the execution policy. You have two options:" -ForegroundColor Yellow
    Write-Host "`nOption 1 - Temporary (Recommended for this script):" -ForegroundColor Cyan
    Write-Host "    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass" -ForegroundColor White
    Write-Host "    Then run this script again." -ForegroundColor White
    Write-Host "`nOption 2 - Permanent (Requires Administrator privileges):" -ForegroundColor Cyan
    Write-Host "    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned" -ForegroundColor White
    Write-Host "    Then run this script again." -ForegroundColor White
    Write-Host "`nFor more information, visit: https://go.microsoft.com/fwlink/?LinkID=135170" -ForegroundColor Yellow
    exit 1
}

# Function to check if Git is initialized
function Test-GitInitialized {
    return Test-Path -Path ".git" -PathType Container
}

# Function to create directory if it doesn't exist
function New-DirectoryIfNotExists {
    param (
        [string]$Path
    )
    if (-not (Test-Path -Path $Path -PathType Container)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $Path"
    }
}

# Function to create file if it doesn't exist
function New-FileIfNotExists {
    param (
        [string]$Path,
        [string]$Content = ""
    )
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        New-Item -Path $Path -ItemType File -Force | Out-Null
        if ($Content) {
            [System.IO.File]::WriteAllText($Path, $Content, [System.Text.Encoding]::UTF8)
        }
        Write-Host "Created file: $Path"
    }
}

# Function to configure Git commit template
function Set-GitCommitTemplate {
    $templatePath = ".commit-template.txt"
    $templateContent = @"
# <type>(<scope>): <short summary>
#
# Types: chore, feat, fix, docs, test, refactor, ci, perf
# Scope: module, script, init, git, ci, doc, etc.
# Example: feat(module): add execution policy enforcement
"@

    # Create template file if it doesn't exist
    New-FileIfNotExists -Path $templatePath -Content $templateContent

    # Check if global template is already configured
    $currentTemplate = git config --global commit.template
    if ($currentTemplate) {
        Write-Host "$INFO_SYMBOL Global Git commit template already configured." -ForegroundColor Cyan
    } else {
        git config --global commit.template $templatePath
        Write-Host "Configured global Git commit template" -ForegroundColor Green
    }
}

# Function to create initial commit
function New-InitialCommit {
    if (-not (git status --porcelain)) {
        Write-Host "No changes to commit" -ForegroundColor Yellow
        return
    }

    git add .
    git commit -m "chore(init): initialize secure project structure and git metadata"
    Write-Host "Created initial commit" -ForegroundColor Green
}

# Main script execution
Write-Host "Initializing Secure PowerShell Module project structure..." -ForegroundColor Cyan

# Handle Git initialization
if (Test-GitInitialized) {
    if ($Force) {
        Write-Host "Force flag detected. Removing existing Git repository..." -ForegroundColor Yellow
        Remove-Item -Path ".git" -Recurse -Force
        Write-Host "Initializing new Git repository..." -ForegroundColor Yellow
        git init | Out-Null
        Write-Host "Git repository reinitialized successfully." -ForegroundColor Green
    } else {
        Write-Host "Git repository already exists. Use -Force to reinitialize." -ForegroundColor Yellow
    }
} else {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init | Out-Null
    Write-Host "Git repository initialized successfully." -ForegroundColor Green
}

# Create required directories
$directories = @(
    "modules/SecureBootstrap",
    "tests",
    "certs"
)

foreach ($dir in $directories) {
    New-DirectoryIfNotExists -Path $dir
}

# Create cursor_prompt.log if it doesn't exist
New-FileIfNotExists -Path "cursor_prompt.log"

# Create .gitignore if it doesn't exist
$gitignorePath = ".gitignore"
$gitignoreContent = @"
.vscode/
certs/*.pfx
*.log
*.zip
*.tmp
*.bak
*.DS_Store
"@

if (-not (Test-Path -Path $gitignorePath -PathType Leaf)) {
    New-FileIfNotExists -Path $gitignorePath -Content $gitignoreContent
} else {
    # Normalize line endings and ensure UTF-8 encoding
    $currentContent = Get-Content -Path $gitignorePath -Raw
    if ($currentContent -ne $gitignoreContent) {
        [System.IO.File]::WriteAllText($gitignorePath, $gitignoreContent, [System.Text.Encoding]::UTF8)
        Write-Host "Updated .gitignore file with normalized line endings" -ForegroundColor Green
    }
}

# Configure Git commit template
Set-GitCommitTemplate

# Create initial commit if this is a new repository
if (-not (git rev-parse --verify HEAD 2>$null)) {
    New-InitialCommit
}

Write-Host "`n$SUCCESS_SYMBOL Secure project structure initialized. Ready for module development." -ForegroundColor Green 