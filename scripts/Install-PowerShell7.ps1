<#
.SYNOPSIS
    Installs PowerShell 7.4.1 from GitHub release ZIP for all users (machine scope).
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

$pwshVersion = Get-PwshVersion

if ($Force -or -not $pwshVersion -or [version]$pwshVersion -lt [version]'7.0.0') {
    Write-Host "[SBD] 🔍 Installing PowerShell 7.4.1 from GitHub..." -ForegroundColor Yellow

    # Define paths and URLs
    $installDir = "C:\Program Files\PowerShell\7"
    $zipPath = Join-Path $env:TEMP "PowerShell-7.4.1-win-x64.zip"
    $downloadUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.zip"

    try {
        # Create installation directory if it doesn't exist
        if (-not (Test-Path $installDir)) {
            New-Item -Path $installDir -ItemType Directory -Force | Out-Null
        }

        # Download PowerShell ZIP
        Write-Host "[SBD] 📥 Downloading PowerShell 7.4.1..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

        # Extract ZIP to installation directory
        Write-Host "[SBD] 📦 Extracting PowerShell 7.4.1..."
        Expand-Archive -Path $zipPath -DestinationPath $installDir -Force

        # Add to PATH if not already present
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if (-not $currentPath.Contains($installDir)) {
            $newPath = $currentPath + ";" + $installDir
            [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        }

        # Clean up
        Remove-Item -Path $zipPath -Force

        Write-Host "[SBD] ✅ PowerShell 7.4.1 installed successfully." -ForegroundColor Green
    } catch {
        Write-Error "[SBD] ❌ Failed to install PowerShell 7.4.1: $_"
        if (Test-Path $zipPath) {
            Remove-Item -Path $zipPath -Force
        }
        return
    }
} else {
    Write-Host "[SBD] ✅ PowerShell 7 already installed: v$pwshVersion" -ForegroundColor Green
}


















