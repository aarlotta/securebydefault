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
.PARAMETER Force
    Forces reinitialization of certain components while preserving Git history.
.PARAMETER BuildDocker
    Generates a secure-by-default Docker environment using SecureBootstrap.
.PARAMETER Rebuild
    Rebuilds the Docker image from scratch using --no-cache.
.PARAMETER CleanUp
    Deletes the Docker environment folder (resources/docker).
.PARAMETER PruneDocker
    Cleans up unused Docker containers, images, and volumes using `docker system prune`.
.EXAMPLE
    .\Initialize-SecureProject.ps1 -BuildDocker -EnableTests
.EXAMPLE
    .\Initialize-SecureProject.ps1 -Rebuild -PruneDocker
.VERSION
    1.0.0
.PROMPT_ID
    Prompt 001
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Force,
    [switch]$BuildDocker,
    [switch]$Rebuild,
    [switch]$CleanUp,
    [switch]$PruneDocker
)

# Check for PowerShell 7 and install if needed
$installPwshScript = Join-Path $PSScriptRoot "scripts\Install-PowerShell7.ps1"
if (Test-Path $installPwshScript) {
    if (-not $CleanUp) {
        if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
            Write-Host "🔍 PowerShell 7 not found. Installing..." -ForegroundColor Yellow
            . $installPwshScript
        }
    } else {
        Write-SbdLog -Message "Skipping PowerShell installation during CleanUp" -Level Info
    }
} else {
    Write-Warning "Install-PowerShell7.ps1 not found at: $installPwshScript"
}

# Ensure helpers are available and encoding is set
$modulePath = Join-Path $PSScriptRoot "modules\SecureBootstrap\SecureBootstrap.psd1"
if (Test-Path $modulePath) {
    Import-Module $modulePath -Force
    Write-Host "[SBD] ✅ SecureBootstrap module loaded"
} else {
    Write-Error "[SBD] ❌ SecureBootstrap module not found at: $modulePath"
    return
}

# Now that the module is loaded, we can use its functions
Set-Utf8Encoding
Write-SbdLog -Message "Helpers loaded and UTF-8 encoding set" -Level Debug

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
            Write-SbdLog -Message "Created directory: $Path" -Level Verbose
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
            Write-SbdLog -Message "Created file: $Path" -Level Verbose
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
        Write-SbdLog -Message "Global Git commit template already configured" -Level Verbose
    } else {
        if ($PSCmdlet.ShouldProcess("Global Git config", "Set commit template")) {
            git config --global commit.template $templatePath
            Write-SbdLog -Message "Configured global Git commit template" -Level Success
        }
    }
}

# Function to create initial commit
function New-InitialCommit {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()
    if (-not (git status --porcelain)) {
        Write-SbdLog -Message "No changes to commit" -Level Verbose
        return
    }

    if ($PSCmdlet.ShouldProcess("Git repository", "Create initial commit")) {
        git add .
        git commit -m "chore(init): initialize project structure and git metadata"
        Write-SbdLog -Message "Created initial commit" -Level Success
    }
}

# Main script execution
Write-SbdLog -Message "Initializing PowerShell Module project structure..." -Level Info

# Handle Git initialization safely
if (-not (Test-GitInitialized)) {
    Write-SbdLog -Message "No Git repository found. Initializing..." -Level Info
    if ($PSCmdlet.ShouldProcess("Git", "Initialize repository")) {
        git init | Out-Null
        Write-SbdLog -Message "Git repository initialized" -Level Success

        # Optional: Add default remote if missing
        git remote get-url origin 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            git remote add origin https://github.com/aarlotta/securebydefault
            Write-SbdLog -Message "Git remote 'origin' configured" -Level Success
        }
    }
} else {
    Write-SbdLog -Message "Git repository already exists. Verifying remote..." -Level Info

    git remote get-url origin 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        if ($PSCmdlet.ShouldProcess("Git", "Add missing remote origin")) {
            git remote add origin https://github.com/aarlotta/securebydefault
            Write-SbdLog -Message "Git remote 'origin' added" -Level Success
        }
    } else {
        Write-SbdLog -Message "Git remote 'origin' already set" -Level Success
    }

    if ($Force) {
        Write-SbdLog -Message "Force flag detected, but .git will NOT be deleted to preserve history" -Level Warning
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

# Initialize cursor prompt logging
$writeCursorPromptLogPath = Join-Path $PSScriptRoot "modules/SecureBootstrap/Private/Write-CursorPromptLog.ps1"
if (Test-Path $writeCursorPromptLogPath) {
    . $writeCursorPromptLogPath
    Write-SbdLog -Message "Project structure initialized" -Level Success
} else {
    Write-SbdLog -Message "Write-CursorPromptLog.ps1 not found at: $writeCursorPromptLogPath" -Level Warning
}

# Create .gitignore if it doesn't exist
$gitignorePath = ".gitignore"
$entriesToAdd = @(
    ".vscode/",
    "*.log",
    "*.zip",
    "*.tmp",
    "*.bak",
    "*.DS_Store"
)

# Create .gitignore if it doesn't exist
New-FileIfMissing -Path $gitignorePath

$currentGitignore = @()
if (Test-Path $gitignorePath) {
    $currentGitignore = Get-Content -Path $gitignorePath -ErrorAction SilentlyContinue
}

$updated = $false

foreach ($entry in $entriesToAdd) {
    if (-not ($currentGitignore -contains $entry)) {
        if ($PSCmdlet.ShouldProcess($gitignorePath, "Append missing .gitignore entry: $entry")) {
            Add-Content -Path $gitignorePath -Value $entry -Encoding UTF8
            Write-SbdLog -Message "Appended .gitignore entry: $entry" -Level Verbose
            $updated = $true
        }
    }
}

if ($updated) {
    Write-SbdLog -Message ".gitignore updated (entries added without overwriting)" -Level Success
} else {
    Write-SbdLog -Message ".gitignore is already up to date" -Level Info
}

# Configure Git commit template
Set-GitCommitTemplate

# Create initial commit if this is a new repository
if (-not (git rev-parse --verify HEAD 2>$null)) {
    New-InitialCommit
}

# Docker environment operations
$dockerPath = "resources/docker"

# Cleanup option (deletes Docker environment)
if ($CleanUp) {
    if (Test-Path $dockerPath) {
        if ($PSCmdlet.ShouldProcess($dockerPath, "Remove Docker environment folder")) {
            Remove-Item -Path $dockerPath -Recurse -Force
            Write-SbdLog -Message "Docker environment folder removed: $dockerPath" -Level Success
        }
    } else {
        Write-SbdLog -Message "Docker environment folder not found (already clean)" -Level Warning
    }
}

# Docker prune option (clears unused images, containers, volumes)
if ($PruneDocker) {
    if (-not (Test-DockerReady)) {
        return
    }
    if ($PSCmdlet.ShouldProcess("Docker system", "Prune unused resources")) {
        docker system prune -f
        Write-SbdLog -Message "Docker system pruned successfully" -Level Success
    }
}

# Run tests after Docker build or rebuild
if ($BuildDocker -or $Rebuild) {
    $runTestsPath = Join-Path $PSScriptRoot "modules/SecureBootstrap/Private/Run-Tests.ps1"
    if (Test-Path $runTestsPath) {
        Write-SbdLog -Message "Running environment validation tests..." -Level Info

        # Skip Pester installation during cleanup
        if (-not $CleanUp) {
            $pesterInstaller = Join-Path $PSScriptRoot "modules/SecureBootstrap/Private/Install-Pester.ps1"
            if (Test-Path $pesterInstaller) {
                . $pesterInstaller -AllUsers
            } else {
                Write-SbdLog -Message "Install-Pester.ps1 not found at: $pesterInstaller" -Level Warning
            }
        } else {
            Write-SbdLog -Message "Skipping Pester installation during CleanUp" -Level Info
        }

        # Run tests using the safe runner
        Invoke-PesterSafe -Path "./tests"
    } else {
        Write-SbdLog -Message "Skipping tests: Run-Tests.ps1 not found in module Private folder" -Level Warning
    }
}

# Build or Rebuild Docker environment
if ($BuildDocker -or $Rebuild) {
    if (-not (Test-DockerReady)) {
        return
    }
    $dockerParams = @{
        Path        = $dockerPath
        ImageName   = "securebydefault/base"
        EnableTests = $true
    }
    if ($Rebuild) {
        $null = docker build --no-cache -t securebydefault/base $dockerPath
        Write-SbdLog -Message "Docker image rebuilt (no cache)" -Level Success
    } else {
        # Safely import SecureBootstrap module
        if (-not (Get-Command New-SbdDockerEnvironment -ErrorAction SilentlyContinue)) {
            $modulePath = Join-Path $PSScriptRoot "modules/SecureBootstrap/SecureBootstrap.psd1"
            if (Test-Path $modulePath) {
                Import-Module $modulePath -Force
                Write-SbdLog -Message "SecureBootstrap module loaded" -Level Success
            } else {
                Write-SbdLog -Message "SecureBootstrap module not found at: $modulePath" -Level Error
                return
            }
        }
        New-SbdDockerEnvironment @dockerParams
    }
}

Write-SbdLog -Message "Project structure initialized. Ready for module development" -Level Success





