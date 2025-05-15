# SecureBootstrap.Tests.ps1
# Main test file for SecureBootstrap module

# TODO: Future security enhancements could include:
# - Certificate-based script validation tests
# - Code signing verification tests
# - Trust store management tests
# - Execution policy tests

BeforeAll {
    $requiredVersion = [Version]'5.5.0'
    $pesterVersion = (Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1).Version
    if ($pesterVersion -lt $requiredVersion) {
        throw "❌ Pester version $($requiredVersion) or higher is required. Current: $($pesterVersion)"
    }
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Join-Path $here '../../modules/SecureBootstrap/SecureBootstrap.psd1'
if (-not (Test-Path $modulePath)) {
    throw "Module manifest not found at: $modulePath"
}

Describe "SecureBootstrap Module" {
    Context "Module Loading" {
        BeforeAll {
            Remove-Module -Name SecureBootstrap -Force -ErrorAction SilentlyContinue
        }

        It "Should import successfully" {
            { 
                Import-Module $modulePath -Force -ErrorAction Stop
                Import-Module SecureBootstrap -Force -ErrorAction Stop
            } | Should -Not -Throw
            $module = Get-Module -Name SecureBootstrap
            $module | Should -Not -BeNullOrEmpty
            $module.Version | Should -Be '0.1.0'
        }

        It "Should not export private functions" {
            Get-Command -Name Write-InternalLog -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It "Should export Write-CursorPromptLog function" {
            Get-Command Write-CursorPromptLog -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
}

# Only show interactive prompt in non-CI environments
if (-not $env:GITHUB_ACTIONS -and $Host.Name -notmatch 'VSCode|Visual Studio') {
    Write-Host "`nPress Enter to continue..."
    Read-Host
} 