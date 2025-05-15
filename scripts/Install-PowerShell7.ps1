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
        # First try direct command
        $pwsh = Get-Command pwsh -ErrorAction Stop
        $version = & $pwsh.Source -NoProfile -NoLogo -Command '$PSVersionTable.PSVersion.ToString()'
        if ($version) { return $version }

        # Fallback to common installation paths
        $commonPaths = @(
            'C:\Program Files\PowerShell\7\pwsh.exe',
            'C:\Program Files (x86)\PowerShell\7\pwsh.exe',
            '/usr/bin/pwsh',
            '/usr/local/bin/pwsh'
        )

        foreach ($path in $commonPaths) {
            if (Test-Path $path) {
                $version = & $path -NoProfile -NoLogo -Command '$PSVersionTable.PSVersion.ToString()'
                if ($version) { return $version }
            }
        }
        return $null
    } catch {
        Write-Verbose "[SBD] PowerShell 7 detection failed: $_"
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

    # Use full path to winget and proper argument formatting
    $wingetPath = (Get-Command winget).Source
    $arguments = @(
        'install',
        '--id', 'Microsoft.Powershell',
        '--source', 'winget',
        '--scope', 'machine',
        '--accept-package-agreements',
        '--accept-source-agreements',
        '--silent'
    )

    Start-Process -FilePath $wingetPath -ArgumentList $arguments -Wait -NoNewWindow
    Write-Host "[SBD] ✅ PowerShell 7 installed system-wide." -ForegroundColor Green
} else {
    Write-Host "[SBD] ✅ PowerShell 7 already installed: v$pesterVersion" -ForegroundColor Green
}



