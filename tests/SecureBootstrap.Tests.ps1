$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Resolve-Path "$here\..\.."
$modulePath = Join-Path $root "modules\SecureBootstrap\SecureBootstrap.psd1"

if (-not (Test-Path $modulePath)) {
    throw "❌ Could not resolve module path for SecureBootstrap."
}

Import-Module $modulePath -Force -ErrorAction Stop

// ... existing code ...








