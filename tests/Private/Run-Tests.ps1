# Run-Tests.ps1
# Internal test entry point (not exposed to users)

Write-Host "[SBD] 🧪 Running Pester tests via .pester.ps1..." -ForegroundColor Cyan
Invoke-Pester -Configuration (Invoke-Expression -Command (Get-Content ./.pester.ps1 -Raw)) 