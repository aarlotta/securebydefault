# Run-Tests.ps1
# Supports both Pester v4 and v5 gracefully

# Ensure UTF-8 encoding for emoji and Unicode compatibility
. "$PSScriptRoot\Helpers.ps1"
Set-Utf8Encoding

Write-SbdLog -Message "Running Pester tests..." -Level Info

try {
    if (Get-Command Invoke-Pester -ErrorAction SilentlyContinue | ForEach-Object { $_.Parameters["Configuration"] }) {
        # Newer Pester 5+
        Write-SbdLog -Message "Using Pester 5+ configuration mode" -Level Verbose
        Invoke-Pester -Configuration (Invoke-Expression -Command (Get-Content ./.pester.ps1 -Raw))
    } else {
        # Fallback for older Pester 4
        Write-SbdLog -Message "Using Pester 4 compatibility mode" -Level Verbose
        Invoke-Pester -Script "./tests"
    }
    Write-SbdLog -Message "Pester tests completed successfully" -Level Success
}
catch {
    Write-SbdLog -Message "Pester failed to execute: $($_.Exception.Message)" -Level Error
    throw
}














