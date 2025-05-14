# SecureBootstrap.psm1
# Main module file for SecureBootstrap

# TODO: Future security enhancements could include:
# - Code signing with trusted certificates
# - Certificate-based script validation
# - Secure bootstrapping with certificate trust chains
# - Execution policy management with signed scripts

# Dot source each function file explicitly
. "$PSScriptRoot\Public\Write-CursorPromptLog.ps1"

# Export public functions
Export-ModuleMember -Function @(
    "Write-CursorPromptLog"
) 