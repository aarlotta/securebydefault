Write-Host '--- DEBUG: Test file started ---'
# Pester 3.4.0 compatible tests
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Resolve-Path (Join-Path $here '..\modules\SecureBootstrap\SecureBootstrap.psd1')

Describe "SecureBootstrap Module" {
    Context "Module Loading" {
        It "Should be imported successfully" {
            Import-Module $modulePath -Force
            Get-Module -Name SecureBootstrap | Should Not BeNullOrEmpty
        }

        It "Should not export private functions" {
            Get-Command -Name Write-InternalLog -ErrorAction SilentlyContinue | Should BeNullOrEmpty
        }
    }
} 