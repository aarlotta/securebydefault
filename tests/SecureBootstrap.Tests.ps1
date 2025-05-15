$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Join-Path $here "..\..\modules\SecureBootstrap\SecureBootstrap.psd1"

if (-not (Test-Path $modulePath)) {
    throw "âŒ Could not resolve module path for SecureBootstrap."
}

Import-Module $modulePath -Force

// ... existing code ...

