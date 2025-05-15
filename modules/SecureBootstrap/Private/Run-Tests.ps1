# Run-Tests.ps1
# Supports both Pester v4 and v5 gracefully
Write-Host "[SBD] 🧪 Running Pester tests..." -ForegroundColor Cyan

try {
    if (Get-Command Invoke-Pester -ErrorAction SilentlyContinue | ForEach-Object { $_.Parameters["Configuration"] }) {
        # Newer Pester 5+
        Write-Verbose "[SBD] 📦 Using Pester 5+ configuration mode"
        Invoke-Pester -Configuration (Invoke-Expression -Command (Get-Content ./.pester.ps1 -Raw))
    } else {
        # Fallback for older Pester 4
        Write-Verbose "[SBD] 📦 Using Pester 4 compatibility mode"
        Invoke-Pester -Script "./tests" -Output Detailed
    }
    Write-Host "[SBD] ✅ Pester tests completed successfully" -ForegroundColor Green
}
catch {
    Write-Error "[SBD] ❌ Pester failed to execute: $($_.Exception.Message)"
    throw
} 