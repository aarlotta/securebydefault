function Write-CursorPromptLog {
    param (
        [string]$ScriptPath,
        [string]$LogPath = "cursor_prompt.log"
    )

    try {
        $content = Get-Content -Path $ScriptPath -Raw
        $promptBlock = ($content -split "(?m)^# \[CURSOR_PROMPT_LOG\]")[-1]
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "# [CURSOR_PROMPT_LOG]$promptBlock`n# [RESPONSE LOGGED @ $timestamp]`n`n$content`n"

        Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
        Write-Host "Logged prompt block from $ScriptPath to $LogPath"
    }
    catch {
        Write-Error "Failed to write to log file: $($_.Exception.Message)"
    }
} 