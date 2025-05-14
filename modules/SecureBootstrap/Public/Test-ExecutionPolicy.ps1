function Test-ExecutionPolicy {
    [CmdletBinding()]
    param(
        [Parameter(DontShow)]
        [ScriptBlock]$GetPolicy = { Get-ExecutionPolicy -Scope CurrentUser }
    )

    # Get current policy using injected or default command
    $currentPolicy = & $GetPolicy
    Write-Host "DEBUG: CurrentPolicy = $currentPolicy"
    
    # Define compatible policies
    $compatiblePolicies = @('RemoteSigned', 'Bypass', 'Unrestricted')

    # Check if current policy is compatible
    if ($currentPolicy -in $compatiblePolicies) {
        Write-Host "DEBUG: Policy is compatible"
        Write-Verbose "Current execution policy ($currentPolicy) is compatible."
        return $true
    }

    # Policy is incompatible - show warning and guidance
    Write-Host "DEBUG: Policy is incompatible"
    Write-Warning "⚠️ Incompatible execution policy: '$currentPolicy'. Please run:"
    Write-Host "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned" -ForegroundColor Yellow
    return $false
} 