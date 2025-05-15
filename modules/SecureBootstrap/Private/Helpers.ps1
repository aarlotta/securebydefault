# [2025-05-14] feat(helpers): add UTF-8 encoding enforcement and unified logging
function Set-Utf8Encoding {
    [CmdletBinding()]
    param()
    
    # Set console and output encoding to UTF-8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $Global:OutputEncoding = [System.Text.Encoding]::UTF8
    Write-Verbose "[SBD] 📝 UTF-8 encoding enforced for console and output"
}

function Write-SbdLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Debug')]
        [string]$Level = 'Info'
    )
    
    # Ensure UTF-8 encoding for emoji support
    Set-Utf8Encoding
    
    # Define emoji and color mappings
    $emojiMap = @{
        'Info'    = 'ℹ️'
        'Success' = '✅'
        'Warning' = '⚠️'
        'Error'   = '❌'
        'Debug'   = '🐞'
    }
    
    $colorMap = @{
        'Info'    = 'Cyan'
        'Success' = 'Green'
        'Warning' = 'Yellow'
        'Error'   = 'Red'
        'Debug'   = 'DarkGray'
    }
    
    # Format the message with emoji
    $formattedMessage = "[SBD] $($emojiMap[$Level]) $Message"
    
    # Write the message with appropriate color
    switch ($Level) {
        'Error'   { Write-Error $formattedMessage }
        'Warning' { Write-Warning $formattedMessage }
        'Debug'   { Write-Debug $formattedMessage }
        default   { Write-Host $formattedMessage -ForegroundColor $colorMap[$Level] }
    }
    
    # Log to file if needed
    $logPath = Join-Path $PSScriptRoot "..\resources\logs\cursor_prompt.log"
    if (Test-Path (Split-Path $logPath -Parent)) {
        Add-Content -Path $logPath -Value "# $(Get-Date -Format 'u') $formattedMessage" -Encoding UTF8
    }
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