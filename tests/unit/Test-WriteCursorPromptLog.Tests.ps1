BeforeAll {
    $requiredVersion = [Version]'5.5.0'
    $pesterVersion = (Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1).Version
    if ($pesterVersion -lt $requiredVersion) {
        throw "âŒ Pester version $($requiredVersion) or higher is required. Current: $($pesterVersion)"
    }
}

Describe "Write-CursorPromptLog" {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot "../../modules/SecureBootstrap/Private/Write-CursorPromptLog.ps1"
        . $scriptPath
        $testLogPath = Join-Path $TestDrive "test_cursor_prompt.log"
    }

    Context "Function Loading" {
        It "Should load without Export-ModuleMember errors" {
            { . $scriptPath } | Should -Not -Throw
        }

        It "Should be available in the session" {
            Get-Command Write-CursorPromptLog | Should -Not -BeNullOrEmpty
        }
    }

    Context "Logging Behavior" {
        BeforeEach {
            if (Test-Path $testLogPath) {
                Remove-Item $testLogPath -Force
            }
        }

        It "Should create log file if it doesn't exist" {
            Write-CursorPromptLog -Message "Test message" -LogPath $testLogPath
            Test-Path $testLogPath | Should -BeTrue
        }

        It "Should append messages with timestamps" {
            $testMessage = "Test message $(Get-Random)"
            Write-CursorPromptLog -Message $testMessage -LogPath $testLogPath

            $content = Get-Content $testLogPath
            $content | Should -Match "# \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] $testMessage"
        }

        It "Should support positional parameters" {
            $testMessage = "Positional test message $(Get-Random)"
            Write-CursorPromptLog $testMessage -LogPath $testLogPath

            $content = Get-Content $testLogPath
            $content | Should -Match "# \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] $testMessage"
        }
    }
}











