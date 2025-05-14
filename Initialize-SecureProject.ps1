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

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Force
)

# Set UTF-8 encoding for proper emoji support
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Check execution policy and provide guidance if needed
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -eq 'Restricted') {
    Write-Warning "PowerShell execution policy is currently set to 'Restricted'"
    Write-Information "To run this script, you need to change the execution policy. You have two options:"
    Write-Information "`nOption 1 - Temporary (Recommended for this script):"
    Write-Information "    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
    Write-Information "    Then run this script again."
    Write-Information "`nOption 2 - Permanent (Requires Administrator privileges):"
    Write-Information "    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned"
    Write-Information "    Then run this script again."
    Write-Information "`nFor more information, visit: https://go.microsoft.com/fwlink/?LinkID=135170"
    exit 1
}

# Function to check if Git is initialized
function Test-GitInitialized {
    [CmdletBinding()]
    param()
    return Test-Path -Path ".git" -PathType Container
}

# Function to create directory if it doesn't exist
function New-DirectoryIfMissing {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    if (-not (Test-Path -Path $Path -PathType Container)) {
        if ($PSCmdlet.ShouldProcess($Path, "Create directory")) {
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
            Write-Verbose "Created directory: $Path"
        }
    }
}

# Function to create file if it doesn't exist
function New-FileIfMissing {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$Content = ""
    )
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        if ($PSCmdlet.ShouldProcess($Path, "Create file")) {
            New-Item -Path $Path -ItemType File -Force | Out-Null
            if ($Content) {
                [System.IO.File]::WriteAllText($Path, $Content, [System.Text.Encoding]::UTF8)
            }
            Write-Verbose "Created file: $Path"
        }
    }
}

# Function to configure Git commit template
function Set-GitCommitTemplate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()
    $templatePath = ".commit-template.txt"
    $templateContent = @"
# <type>(<scope>): <short summary>
#
# Types: chore, feat, fix, docs, test, refactor, ci, perf
# Scope: module, script, init, git, ci, doc, etc.
# Example: feat(module): add execution policy enforcement
"@

    # Create template file if it doesn't exist
    New-FileIfMissing -Path $templatePath -Content $templateContent

    # Check if global template is already configured
    $currentTemplate = git config --global commit.template
    if ($currentTemplate) {
        Write-Verbose "Global Git commit template already configured."
    } else {
        if ($PSCmdlet.ShouldProcess("Global Git config", "Set commit template")) {
            git config --global commit.template $templatePath
            Write-Verbose "Configured global Git commit template"
        }
    }
}

# Function to create initial commit
function New-InitialCommit {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()
    if (-not (git status --porcelain)) {
        Write-Verbose "No changes to commit"
        return
    }

    if ($PSCmdlet.ShouldProcess("Git repository", "Create initial commit")) {
        git add .
        git commit -m "chore(init): initialize secure project structure and git metadata"
        Write-Verbose "Created initial commit"
    }
}

# Main script execution
Write-Verbose "Initializing Secure PowerShell Module project structure..."

# Handle Git initialization
if (Test-GitInitialized) {
    if ($Force) {
        Write-Warning "Force flag detected. Removing existing Git repository..."
        if ($PSCmdlet.ShouldProcess(".git", "Remove directory")) {
            Remove-Item -Path ".git" -Recurse -Force
            Write-Verbose "Initializing new Git repository..."
            git init | Out-Null
            Write-Verbose "Git repository reinitialized successfully."
        }
    } else {
        Write-Warning "Git repository already exists. Use -Force to reinitialize."
    }
} else {
    Write-Verbose "Initializing Git repository..."
    if ($PSCmdlet.ShouldProcess("Git repository", "Initialize")) {
        git init | Out-Null
        Write-Verbose "Git repository initialized successfully."
    }
}

# Create required directories
$directories = @(
    "modules/SecureBootstrap",
    "tests",
    "certs"
)

foreach ($dir in $directories) {
    New-DirectoryIfMissing -Path $dir
}

# Create cursor_prompt.log if it doesn't exist
New-FileIfMissing -Path "cursor_prompt.log"

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
    New-FileIfMissing -Path $gitignorePath -Content $gitignoreContent
} else {
    # Normalize line endings and ensure UTF-8 encoding
    $currentContent = Get-Content -Path $gitignorePath -Raw
    if ($currentContent -ne $gitignoreContent) {
        if ($PSCmdlet.ShouldProcess($gitignorePath, "Update content")) {
            [System.IO.File]::WriteAllText($gitignorePath, $gitignoreContent, [System.Text.Encoding]::UTF8)
            Write-Verbose "Updated .gitignore file with normalized line endings"
        }
    }
}

# Configure Git commit template
Set-GitCommitTemplate

# Create initial commit if this is a new repository
if (-not (git rev-parse --verify HEAD 2>$null)) {
    New-InitialCommit
}

Write-Verbose "Secure project structure initialized. Ready for module development." 