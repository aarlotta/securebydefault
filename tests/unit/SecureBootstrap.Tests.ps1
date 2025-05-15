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
        throw "âŒ Pester version $($requiredVersion) or higher is required. Current: $($pesterVersion)"
    }
}

# Resolve module path using $MyInvocation for reliable path resolution
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Join-Path $here "../../modules/SecureBootstrap/SecureBootstrap.psd1"

# Try to resolve the module path with fallbacks
if (Test-Path $modulePath) {
    $modulePath = Resolve-Path $modulePath
} elseif (Test-Path "E:\securebydefault\modules\SecureBootstrap\SecureBootstrap.psd1") {
    $modulePath = "E:\securebydefault\modules\SecureBootstrap\SecureBootstrap.psd1"
} else {
    throw "Module manifest not found. Searched in: $modulePath and E:\securebydefault\modules\SecureBootstrap\SecureBootstrap.psd1"
}

# Import module once with error handling
try {
    Import-Module $modulePath -Force -ErrorAction Stop
} catch {
    throw "Failed to import module: $_"
}

Describe "SecureBootstrap Module" {
    Context "Module Loading" {
        BeforeAll {
            Remove-Module -Name SecureBootstrap -Force -ErrorAction SilentlyContinue
        }

        It "Should import successfully" {
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


