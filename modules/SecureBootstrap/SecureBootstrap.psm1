# SecureBootstrap.psm1
# Main module file for SecureBootstrap

# TODO: Future security enhancements could include:
# - Code signing with trusted certificates
# - Certificate-based script validation
# - Secure bootstrapping with certificate trust chains
# - Execution policy management with signed scripts

# Helper function to safely dot-source scripts
function Import-Script {
    param (
        [string]$ScriptPath
    )

    if (Test-Path $ScriptPath) {
        . $ScriptPath
    } else {
        Write-Warning "[SBD] ⚠️ Script not found: $ScriptPath"
    }
}

# First load helpers since other scripts depend on them
Import-Script "$PSScriptRoot/Private/Helpers.ps1"

# Then load the rest of the scripts
Import-Script "$PSScriptRoot/Public/Write-CursorPromptLog.ps1"
Import-Script "$PSScriptRoot/Public/New-SecureDockerEnvironment.ps1"
Import-Script "$PSScriptRoot/Private/Install-Pester.ps1"
Import-Script "$PSScriptRoot/Private/Run-Tests.ps1"

# Export public functions
Export-ModuleMember -Function @(
    "Write-CursorPromptLog",
    "New-SecureDockerEnvironment",
    "Set-Utf8Encoding",
    "Write-SbdLog",
    "Test-DockerReady",
    "Invoke-PesterSafe",
    "Run-Tests"
)































