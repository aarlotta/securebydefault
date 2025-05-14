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

        It "Should export the Test-ExecutionPolicy function" {
            Get-Command -Name Test-ExecutionPolicy -ErrorAction Stop | Should Not BeNullOrEmpty
        }

        It "Should not export private functions" {
            Get-Command -Name Write-InternalLog -ErrorAction SilentlyContinue | Should BeNullOrEmpty
        }
    }

    Context "Test-ExecutionPolicy" {
        It "Should return true for RemoteSigned policy" {
            $result = Test-ExecutionPolicy -GetPolicy { 'RemoteSigned' }
            $result | Should Be $true
        }

        It "Should return true for Unrestricted policy" {
            $result = Test-ExecutionPolicy -GetPolicy { 'Unrestricted' }
            $result | Should Be $true
        }

        It "Should return true for Bypass policy" {
            $result = Test-ExecutionPolicy -GetPolicy { 'Bypass' }
            $result | Should Be $true
        }

        It "Should return false for Restricted policy" {
            $result = Test-ExecutionPolicy -GetPolicy { 'Restricted' }
            $result | Should Be $false
        }

        It "Should return false for AllSigned policy" {
            $result = Test-ExecutionPolicy -GetPolicy { 'AllSigned' }
            $result | Should Be $false
        }

        It "Should show warning message for incompatible policy" {
            $WarningPreference = 'Continue'
            $warnings = @()
            $result = Test-ExecutionPolicy -GetPolicy { 'Restricted' } -WarningVariable warnings
            $warningText = $warnings -join "`n"
            $warningText | Should Match "Incompatible execution policy"
            $warningText | Should Match "Set-ExecutionPolicy.*RemoteSigned"
        }
    }
} 