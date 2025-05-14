# Run-Tests.ps1
# Script to run all tests and analysis checks

# Stop on any error
$ErrorActionPreference = "Stop"

# Define paths to analyze
$scriptPaths = @(
    '.\modules\SecureBootstrap',
    '.\tests'
)

# Track overall status
$hasErrors = $false

# Run ScriptAnalyzer on each path
foreach ($path in $scriptPaths) {
    Write-Host "`nAnalyzing $path..." -ForegroundColor Cyan
    $results = Invoke-ScriptAnalyzer -Path $path -Recurse -Severity Error

    if ($results) {
        Write-Host "Found $($results.Count) issues:" -ForegroundColor Yellow
        $results | Format-Table -AutoSize
        $hasErrors = $true
    } else {
        Write-Host "No issues found." -ForegroundColor Green
    }
}

# Run Pester tests
Write-Host "`nRunning Pester tests..." -ForegroundColor Cyan
Invoke-Pester -Path .\tests -EnableExit

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nPester tests failed." -ForegroundColor Red
    $hasErrors = $true
} else {
    Write-Host "`nAll tests passed." -ForegroundColor Green
}

# Final status
if ($hasErrors) {
    Write-Host "`n❌ Some checks failed. Please fix the issues above." -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n✅ All checks passed successfully!" -ForegroundColor Green
    exit 0
}