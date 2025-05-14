function Write-CursorPromptLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter(Mandatory = $false)]
        [string]$LogPath = "cursor_prompt.log"
    )

    # Read the script file
    $scriptContent = Get-Content -Path $ScriptPath -Raw -Encoding UTF8

    # Extract the last CURSOR_PROMPT_LOG block
    $promptPattern = '(?ms)# \[CURSOR_PROMPT_LOG\].*?(?=# \[CURSOR_PROMPT_LOG\]|$)'
    $promptBlocks = [regex]::Matches($scriptContent, $promptPattern)
    
    if ($promptBlocks.Count -eq 0) {
        Write-Warning "No CURSOR_PROMPT_LOG blocks found in $ScriptPath"
        return
    }

    # Get the last block
    $lastBlock = $promptBlocks[-1].Value

    # Extract prompt number
    $promptNumber = if ($lastBlock -match 'Prompt (\d+)') { $matches[1] } else { "UNKNOWN" }

    # Create log entry
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @"
$lastBlock
# [RESPONSE LOGGED @ $timestamp]
$scriptContent
"@

    # Append to log file
    try {
        $logEntry | Out-File -FilePath $LogPath -Append -Encoding UTF8
        Write-Host "📝 Logged Prompt $promptNumber from $ScriptPath to $LogPath"
    }
    catch {
        Write-Error "Failed to write to log file: $_"
    }
} 