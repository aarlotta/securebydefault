# Run-Tests.ps1
# Unified entry point for running all tests in the SecureByDefault project

Write-Host "[SBD] 🧪 Running all tests using Pester config..." -ForegroundColor Cyan

Invoke-Pester -Configuration (Invoke-Expression -Command (Get-Content ./.pester.ps1 -Raw))