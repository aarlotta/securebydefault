# SecureBootstrap.Tests.ps1
# Main test file for SecureBootstrap module

# TODO: Future security enhancements could include:
# - Certificate-based script validation tests
# - Code signing verification tests
# - Trust store management tests
# - Execution policy tests

Write-Host '--- DEBUG: Test file started ---'
# Pester 3.4.0 compatible tests
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Resolve-Path (Join-Path $here '..\modules\SecureBootstrap\SecureBootstrap.psd1')

Describe "SecureBootstrap Module" {
    Context "Module Loading" {
        It "Should import successfully" {
            Import-Module $modulePath -Force
            Get-Module -Name SecureBootstrap | Should Not BeNullOrEmpty
        }

        It "Should not export private functions" {
            Get-Command -Name Write-InternalLog -ErrorAction SilentlyContinue | Should BeNullOrEmpty
        }

        It "Should export Write-CursorPromptLog function" {
            Get-Command Write-CursorPromptLog -ErrorAction SilentlyContinue | Should Not BeNullOrEmpty
        }
    }
} 