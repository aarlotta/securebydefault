function Write-InternalLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    Write-Verbose "[internal]: $Message"
} 