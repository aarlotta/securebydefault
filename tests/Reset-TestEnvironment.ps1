# Reset-TestEnvironment.ps1
# Resets the test environment to a clean state

# TODO: Future security enhancements could include:
# - Certificate store cleanup
# - Trusted publisher store management
# - Code signing certificate validation

# Reset any test-specific environment variables
$env:TestProject = $null
$env:TestPath = $null

# Clean up any test files
if (Test-Path $TestDrive) {
    Remove-Item -Path $TestDrive -Recurse -Force
}

Write-Verbose "Test environment reset complete"






