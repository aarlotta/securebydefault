function Write-CursorPromptLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$LogPath = "$(Join-Path $PSScriptRoot '../resources/logs/cursor_prompt.log')"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "# [$timestamp] $Message"

    if (-not (Test-Path $LogPath)) {
        New-Item -Path $LogPath -ItemType File -Force | Out-Null
    }

    Add-Content -Path $LogPath -Value $entry
    Write-Verbose "[SBD] Logged cursor prompt: $Message"
}

























