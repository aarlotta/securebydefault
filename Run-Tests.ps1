# Run-Tests.ps1
# Script to run all tests for the SecureBootstrap module

# Ensure PSScriptAnalyzer is installed
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Warning "PSScriptAnalyzer module not found. Installing..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -Confirm:$false
}

# Run ScriptAnalyzer first
Write-Verbose "Running PSScriptAnalyzer..."
$analyzerResults = Invoke-ScriptAnalyzer -Path .\modules,.\tests -Recurse -Severity Error
if ($analyzerResults) {
    Write-Warning "PSScriptAnalyzer found issues:"
    $analyzerResults | Format-Table -AutoSize
    exit 1
}
Write-Verbose "PSScriptAnalyzer passed."

# Run Pester tests
Write-Verbose "Running Pester tests..."
$testResults = Invoke-Pester -Path .\tests -PassThru
if ($testResults.FailedCount -gt 0) {
    Write-Warning "Tests failed: $($testResults.FailedCount) failed, $($testResults.PassedCount) passed"
    exit 1
}
Write-Verbose "All tests passed: $($testResults.PassedCount) passed" 