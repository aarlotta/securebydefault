# SecureBootstrap.psm1
# Main module file for SecureBootstrap

# Dot source each function file explicitly
. "$PSScriptRoot\Public\New-CodeSigningCertificate.ps1"
. "$PSScriptRoot\Public\Sign-Scripts.ps1"
. "$PSScriptRoot\Public\Write-CursorPromptLog.ps1"

# Export public functions
Export-ModuleMember -Function @(
    "New-CodeSigningCertificate",
    "Sign-Scripts",
    "Write-CursorPromptLog"
) 