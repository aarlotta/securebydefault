# [2025-05-14] feat(helpers): add UTF-8 encoding enforcement and unified logging
function Set-Utf8Encoding {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $Global:OutputEncoding = [System.Text.Encoding]::UTF8
}

function Write-SbdLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error", "Debug", "Verbose")][string]$Level = "Info"
    )

    # Ensure UTF-8 encoding for emoji support
    Set-Utf8Encoding

    $prefix = switch ($Level) {
        "Info"    { "[SBD] [i] " }
        "Success" { "[SBD] [+] " }
        "Warning" { "[SBD] [!] " }
        "Error"   { "[SBD] [x] " }
        "Debug"   { "[SBD] [d] " }
        "Verbose" { "[SBD] [v] " }
    }

    $formattedMessage = "$prefix$Message"

    switch ($Level) {
        'Info'    { Write-Host $formattedMessage -ForegroundColor Cyan }
        'Success' { Write-Host $formattedMessage -ForegroundColor Green }
        'Warning' { Write-Warning $formattedMessage }
        'Error'   { Write-Error $formattedMessage }
        'Debug'   { Write-Debug $formattedMessage }
        'Verbose' { Write-Verbose $formattedMessage }
    }

    # Ensure log directory exists
    $logDir = Join-Path $PSScriptRoot "..\resources\logs"
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    $logPath = Join-Path $logDir "cursor_prompt.log"
    Add-Content -Path $logPath -Value "# $(Get-Date -Format 'u') $formattedMessage" -Encoding UTF8
}

function Write-InternalLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Verbose "[internal]: $Message"
}

# [2025-05-14] feat(helpers): add Test-DockerReady to check Docker availability and daemon status
function Test-DockerReady {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    # Check if Docker CLI is available
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-SbdLog -Message "Docker is not installed or not in PATH. Please install Docker Desktop or Docker CLI first." -Level Error
        return $false
    }

    # Check if Docker daemon is running
    try {
        $info = docker info --format "{{json .}}" 2>$null | ConvertFrom-Json
        if (-not $info.ServerVersion) {
            throw "Missing Docker server version"
        }
        Write-SbdLog -Message "Docker is installed and running. Version: $($info.ServerVersion)" -Level Success
        return $true
    }
    catch {
        Write-SbdLog -Message "Docker is installed but not running. Please start Docker Desktop or the Docker daemon." -Level Error
        return $false
    }
}

# [2025-05-14] feat(pester): add safe Pester test runner with version compatibility
function Invoke-PesterSafe {
    [CmdletBinding()]
    param (
        [string]$Path = "./tests"
    )

    Write-SbdLog -Message "Running Pester tests..." -Level Info
    try {
        if (Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version -ge '5.5.0' }) {
            Invoke-Pester -Script $Path
        } else {
            Write-SbdLog -Message "Old Pester version found. Falling back to basic run..." -Level Warning
            Invoke-Pester $Path
        }
        Write-SbdLog -Message "Pester tests completed successfully" -Level Success
    } catch {
        Write-SbdLog -Message "Pester test failure: $($_.Exception.Message)" -Level Error
        throw
    }
}



