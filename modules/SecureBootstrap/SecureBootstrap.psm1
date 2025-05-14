# SecureBootstrap.psm1
# Main module file for SecureBootstrap

# Dot source each function file explicitly
. "$PSScriptRoot\Public\New-CodeSigningCertificate.ps1"
. "$PSScriptRoot\Public\Sign-Script.ps1"
. "$PSScriptRoot\Public\Write-CursorPromptLog.ps1"
. "$PSScriptRoot\Public\Add-CertificateToTrustedStore.ps1"

# Export public functions
Export-ModuleMember -Function @(
    "New-CodeSigningCertificate",
    "Sign-Script",
    "Write-CursorPromptLog",
    "Add-CertificateToTrustedStore"
) 