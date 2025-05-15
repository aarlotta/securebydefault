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
        Write-Error "[SBD] ❌ Docker is not installed or not in PATH. Please install Docker Desktop or Docker CLI first."
        return $false
    }

    # Check if Docker daemon is running
    try {
        $info = docker info --format '{{json .}}' 2>$null | ConvertFrom-Json
        if (-not $info.ServerVersion) {
            throw "Missing Docker server version"
        }
        Write-Verbose "[SBD] 🐳 Docker is installed and running. Version: $($info.ServerVersion)"
        return $true
    }
    catch {
        Write-Error "[SBD] ❌ Docker is installed but not running. Please start Docker Desktop or the Docker daemon."
        return $false
    }
} 

# [2025-05-14] feat(helpers): add Write-SbdLog for consistent logging with emojis
function Write-SbdLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Verbose', 'Debug')]
        [string]$Level = 'Info',
        
        [Parameter(Mandatory = $false)]
        [switch]$NoEmoji
    )
    
    # Ensure UTF-8 encoding for emoji support
    if (-not $NoEmoji) {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $OutputEncoding = [System.Text.Encoding]::UTF8
    }
    
    # Define emoji and color mappings
    $emojiMap = @{
        'Info'    = 'ℹ️'
        'Success' = '✅'
        'Warning' = '⚠️'
        'Error'   = '❌'
        'Verbose' = '📝'
        'Debug'   = '🔍'
    }
    
    $colorMap = @{
        'Info'    = 'Cyan'
        'Success' = 'Green'
        'Warning' = 'Yellow'
        'Error'   = 'Red'
        'Verbose' = 'Gray'
        'Debug'   = 'DarkGray'
    }
    
    # Format the message with emoji if enabled
    $emoji = if (-not $NoEmoji) { "$($emojiMap[$Level]) " } else { "" }
    $formattedMessage = "[SBD] $emoji$Message"
    
    # Write the message with appropriate color
    switch ($Level) {
        'Error'   { Write-Error $formattedMessage }
        'Warning' { Write-Warning $formattedMessage }
        'Verbose' { Write-Verbose $formattedMessage }
        'Debug'   { Write-Debug $formattedMessage }
        default   { Write-Host $formattedMessage -ForegroundColor $colorMap[$Level] }
    }
} 