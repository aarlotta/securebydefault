$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Resolve-Path "$here\..\.."
$modulePath = Resolve-Path "$PSScriptRoot\..\modules\SecureBootstrap\SecureBootstrap.psd1" -ErrorAction SilentlyContinue

if (-not $modulePath) {
    throw "❌ Could not resolve module path for SecureBootstrap at expected location: $PSScriptRoot\..\modules\SecureBootstrap"
}

Import-Module $modulePath -Force -ErrorAction Stop

// ... existing code ...












