<#
.SYNOPSIS
    Ensures Pester 5.5.0+ is installed for testing compatibility.
#>
[CmdletBinding()]
param (
    [switch]$Force,
    [switch]$AllUsers
)

$MinimumVersion = [Version]'5.5.0'

try {
    $current = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
} catch {
    $current = $null
}

if ($null -eq $current -or $current.Version -lt $MinimumVersion -or $Force) {
    $installParams = @{
        Name               = 'Pester'
        MinimumVersion     = $MinimumVersion
        Force              = $true
        SkipPublisherCheck = $true
        Scope              = if ($AllUsers) { 'AllUsers' } else { 'CurrentUser' }
    }

    try {
        Install-Module @installParams -ErrorAction Stop
        Write-Host "[SBD] ✅ Pester $MinimumVersion+ installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "[SBD] ❌ Failed to install Pester: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
} else {
    Write-Host "[SBD] ℹ️ Pester $($current.Version) already installed." -ForegroundColor Cyan
}































