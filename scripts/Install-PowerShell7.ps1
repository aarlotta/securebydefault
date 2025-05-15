<#
.SYNOPSIS
    Installs the latest stable PowerShell 7.x system-wide using winget.
    Only installs if pwsh is missing or outdated (< 7.0.0).
#>

[CmdletBinding()]
param (
    [switch]$Force
)

function Get-PwshVersion {
    try {
        $pwsh = Get-Command pwsh -ErrorAction Stop
        & $pwsh.Source -NoLogo -Command '$PSVersionTable.PSVersion.ToString()'
    } catch {
        return $null
    }
}

$pesterVersion = Get-PwshVersion

if ($Force -or -not $pesterVersion -or [version]$pesterVersion -lt [version]'7.0.0') {
    Write-Host "🔍 Installing PowerShell 7.x using winget..." -ForegroundColor Yellow

    $wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetInstalled) {
        Write-Error "❌ Winget is not available on this system. Please install it from the Microsoft Store."
        return
    }

    # Install system-wide
    Start-Process -FilePath "winget" -ArgumentList 'install --id Microsoft.Powershell --source winget --scope machine --accept-package-agreements --accept-source-agreements --silent' -NoNewWindow -Wait

    Write-Host "✅ PowerShell 7 installed system-wide." -ForegroundColor Green
} else {
    Write-Host "✅ PowerShell 7 already installed: v$pesterVersion" -ForegroundColor Green
} 