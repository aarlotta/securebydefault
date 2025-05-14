# Initialize-SecureProject.ps1
# Script to initialize the PowerShell Module project structure

<#
.SYNOPSIS
    Initializes a PowerShell module project structure with Git repository and required directories.
.DESCRIPTION
    Creates a standardized project structure for PowerShell module development, including Git initialization,
    directory structure, and configuration files. The script is idempotent and can be run multiple times
    safely. It does not reinitialize Git or remove remotes even when -Force is used. Instead, it validates
    and supplements the repository configuration.
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

# TODO: Future security enhancements could include:
# - Execution policy management
# - Code signing with trusted certificates
# - Certificate-based script validation
# - Secure bootstrapping with certificate trust chains

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
# Example: feat(module): add new logging function
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
        git commit -m "chore(init): initialize project structure and git metadata"
        Write-Verbose "Created initial commit"
    }
}

# Main script execution
Write-Verbose "Initializing PowerShell Module project structure..."

# Handle Git initialization safely
if (-not (Test-GitInitialized)) {
    Write-Verbose "No Git repository found. Initializing..."
    if ($PSCmdlet.ShouldProcess("Git", "Initialize repository")) {
        git init | Out-Null
        Write-Verbose "Git repository initialized."

        # Optional: Add default remote if missing
        $origin = git remote get-url origin 2>$null
        if (-not $origin) {
            git remote add origin https://github.com/aarlotta/securebydefault
            Write-Verbose "Git remote 'origin' configured."
        }
    }
} else {
    Write-Verbose "Git repository already exists. Verifying remote..."

    $origin = git remote get-url origin 2>$null
    if (-not $origin) {
        if ($PSCmdlet.ShouldProcess("Git", "Add missing remote origin")) {
            git remote add origin https://github.com/aarlotta/securebydefault
            Write-Verbose "Git remote 'origin' added."
        }
    } else {
        Write-Verbose "Git remote 'origin' already set to: $origin"
    }

    if ($Force) {
        Write-Warning "Force flag detected, but .git will NOT be deleted to preserve history."
    }
}

# Create required directories
$directories = @(
    "modules/SecureBootstrap",
    "tests"
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

Write-Verbose "Project structure initialized. Ready for module development."