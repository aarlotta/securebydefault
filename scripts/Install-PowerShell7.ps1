<#
.SYNOPSIS
    Installs the latest stable PowerShell 7.x using winget for all users (machine scope).
#>

[CmdletBinding()]
param (
    [switch]$Force
)

function Get-PwshVersion {
    try {
        $pwsh = Get-Command pwsh -ErrorAction Stop
        return & $pwsh.Source -NoLogo -Command '$PSVersionTable.PSVersion.ToString()'
    } catch {
        return $null
    }
}

$pesterVersion = Get-PwshVersion

if ($Force -or -not $pesterVersion -or [version]$pesterVersion -lt [version]'7.0.0') {
    Write-Host "[SBD] 🔍 Installing PowerShell 7.x using winget..." -ForegroundColor Yellow

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "[SBD] ❌ Winget is not available. Install winget or run manually."
        return
    }

    Start-Process -FilePath "winget" -ArgumentList 'install --id Microsoft.Powershell --source winget --scope machine --accept-package-agreements --accept-source-agreements --silent' -Wait
    Write-Host "[SBD] ✅ PowerShell 7 installed system-wide." -ForegroundColor Green
} else {
    Write-Host "[SBD] ✅ PowerShell 7 already installed: v$pesterVersion" -ForegroundColor Green
}

