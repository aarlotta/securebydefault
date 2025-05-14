# Run-Tests.ps1
# Script to run all tests for the SecureBootstrap module

# Ensure PSScriptAnalyzer is installed
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Warning "PSScriptAnalyzer module not found. Installing..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -Confirm:$false
}

# Run ScriptAnalyzer first
Write-Host "Running PSScriptAnalyzer..." -ForegroundColor Cyan
$analyzerResults = Invoke-ScriptAnalyzer -Path .\modules,.\tests -Recurse -Severity Error
if ($analyzerResults) {
    Write-Warning "PSScriptAnalyzer found issues:"
    $analyzerResults | Format-Table -AutoSize
    exit 1
}
Write-Host "PSScriptAnalyzer passed." -ForegroundColor Green

# Run Pester tests
Write-Host "Running Pester tests..." -ForegroundColor Cyan
$testResults = Invoke-Pester -Path .\tests -PassThru
if ($testResults.FailedCount -gt 0) {
    Write-Warning "Tests failed: $($testResults.FailedCount) failed, $($testResults.PassedCount) passed"
    exit 1
}
Write-Host "All tests passed: $($testResults.PassedCount) passed" -ForegroundColor Green 