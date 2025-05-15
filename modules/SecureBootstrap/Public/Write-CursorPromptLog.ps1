function Write-CursorPromptLog {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ScriptPath,

        [Parameter(Mandatory = $false)]
        [string]
        $LogPath = "cursor_prompt.log"
    )

    try {
        $content = Get-Content -Path $ScriptPath -Raw
        $promptBlock = ($content -split "(?m)^# \[CURSOR_PROMPT_LOG\]")[-1]
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "# [CURSOR_PROMPT_LOG]$promptBlock`n# [RESPONSE LOGGED @ $timestamp]`n`n$content`n"

        if ($PSCmdlet.ShouldProcess($LogPath, "Add log entry")) {
            Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
            Write-Verbose "Logged prompt block from $ScriptPath to $LogPath"
        }
    }
    catch {
        Write-Error "Failed to write to log file: $($_.Exception.Message)"
    }
}















