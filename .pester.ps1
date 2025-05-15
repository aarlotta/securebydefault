# .pester.ps1
# Pester v5+ test configuration for SecureByDefault

@{
    Run = @{
        Path = "./tests"
        Exit = $true
    }
    Output = @{
        Verbosity = "Detailed"
    }
    TestResult = @{
        Enabled = $true
        OutputPath = "TestResults.xml"
    }
}









