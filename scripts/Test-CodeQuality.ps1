<#
.SYNOPSIS
    Runs PSScriptAnalyzer with project settings and fails if errors are found.
.DESCRIPTION
    Analyzes all PowerShell scripts in the project using the .psscriptanalyzer.psd1 settings.
    Exits with code 1 if any Error-level issues are found.
#>

[CmdletBinding()]
param()

# Ensure PSScriptAnalyzer is installed
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Host "Installing PSScriptAnalyzer..." -ForegroundColor Yellow
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
}

# Import the module
Import-Module PSScriptAnalyzer

# Run the analysis
$issues = Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\.psscriptanalyzer.psd1

# Check for errors
$errors = $issues.Where({ $_.Severity -eq 'Error' })
if ($errors) {
    Write-Error "âŒ PSScriptAnalyzer found $($errors.Count) error(s). Please fix these issues before committing."
    $issues | Format-Table -AutoSize
    exit 1
}

# Show warnings if any
$warnings = $issues.Where({ $_.Severity -eq 'Warning' })
if ($warnings) {
    Write-Warning "âš ï¸ PSScriptAnalyzer found $($warnings.Count) warning(s)."
    $warnings | Format-Table -AutoSize
}

Write-Host "âœ… Code quality check passed." -ForegroundColor Green



