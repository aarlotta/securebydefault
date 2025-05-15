# SecureBootstrap.Tests.ps1
# Main test file for SecureBootstrap module

# TODO: Future security enhancements could include:
# - Certificate-based script validation tests
# - Code signing verification tests
# - Trust store management tests
# - Execution policy tests

# Resolve the absolute path to the SecureBootstrap module manifest
$testRoot    = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path -Path "$testRoot\.." | ForEach-Object { $_.Path }
$modulePath  = Join-Path -Path $projectRoot -ChildPath "modules\SecureBootstrap\SecureBootstrap.psd1"

if (-not (Test-Path $modulePath)) {
    throw "❌ Could not resolve SecureBootstrap module path. Expected at: $modulePath"
}

try {
    Import-Module $modulePath -Force -ErrorAction Stop
} catch {
    throw "❌ Failed to import SecureBootstrap module: $($_.Exception.Message)"
}

BeforeAll {
    $requiredVersion = [Version]'5.5.0'
    $pesterVersion = (Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1).Version
    if ($pesterVersion -lt $requiredVersion) {
        throw "❌ Pester version $($requiredVersion) or higher is required. Current: $($pesterVersion)"
    }
}

Describe "SecureBootstrap Module" {
    Context "Module Path Resolution" {
        It "Should resolve module path correctly" {
            Test-Path $modulePath | Should -Be $true
        }

        It "Should have valid module manifest" {
            $manifest = Import-PowerShellDataFile -Path $modulePath
            $manifest | Should -Not -BeNullOrEmpty
            $manifest.ModuleVersion | Should -Not -BeNullOrEmpty
        }
    }

    Context "Module Loading" {
        BeforeAll {
            Remove-Module -Name SecureBootstrap -Force -ErrorAction SilentlyContinue
        }

        It "Should import successfully" {
            Write-Host "[Test] Attempting to import module from: $modulePath" -ForegroundColor Cyan
            { Import-Module $modulePath -Force -ErrorAction Stop } | Should -Not -Throw
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

# Skip interactive prompts in CI environments
if ($env:GITHUB_ACTIONS -eq "true" -or $env:CI -eq "true" -or $Host.UI.RawUI.WindowTitle -like "*CI*") {
    # do nothing, skip Read-Host
}


























