# Run-Tests.ps1
# Internal test entry point for SecureByDefault (not exposed to users)

Write-Host "[SBD] 🧪 Running Pester tests using .pester.ps1 configuration..." -ForegroundColor Cyan
Invoke-Pester -Configuration (Invoke-Expression -Command (Get-Content ./.pester.ps1 -Raw)) 