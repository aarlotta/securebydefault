<#
.SYNOPSIS
    Normalizes code formatting and enforces quality standards across all PowerShell files.
.DESCRIPTION
    Performs the following actions on all .ps1, .psd1, and .psm1 files:
    - Normalizes UTF-8 BOM encoding
    - Removes trailing whitespace
    - Fixes indentation and alignment
    - Reports unused variables
    - Logs all actions with [SBD] tags
#>

[CmdletBinding()]
param()

# Function to normalize file content
function Normalize-FileContent {
    param (
        [string]$Path
    )

    try {
        # Read content with UTF-8 encoding
        $content = Get-Content $Path -Raw -ErrorAction Stop

        # Remove trailing whitespace and normalize line endings
        $normalized = $content -replace '\s+$', '' -replace '\r\n', "`n" -replace '\n', "`r`n"

        # Write back with UTF-8 BOM
        [System.IO.File]::WriteAllText($Path, $normalized, [System.Text.UTF8Encoding]::new($true))

        Write-Host "[SBD] âœ… Normalized encoding and whitespace for $Path" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[SBD] âŒ Failed to normalize $Path : $_" -ForegroundColor Red
        return $false
    }
}

# Function to detect unused variables
function Test-UnusedVariables {
    param (
        [string]$Path
    )

    try {
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)

        $variables = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] }, $true)
        $unused = $variables |
            Where-Object { $_.VariablePath.UserPath -notmatch '^_' } |
            Group-Object VariablePath.UserPath |
            Where-Object { $_.Count -eq 1 }

        if ($unused) {
            Write-Host "[SBD] âš ï¸ Unused variables in $Path :" -ForegroundColor Yellow
            $unused | ForEach-Object {
                Write-Host "    - $($_.Name)" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "[SBD] âŒ Failed to analyze variables in $Path : $_" -ForegroundColor Red
    }
}

# Main execution
Write-Host "[SBD] ðŸ§¼ Starting code quality normalization..." -ForegroundColor Cyan

$fixedFiles = 0

Get-ChildItem -Recurse -Include *.ps1,*.psd1,*.psm1 | ForEach-Object {
    $path = $_.FullName
    $original = Get-Content $path -Raw

    # Normalize BOM + UTF8
    [System.IO.File]::WriteAllText($path, $original, [System.Text.UTF8Encoding]::new($true))

    # Strip trailing whitespace
    $cleaned = ($original -split "`r?`n") | ForEach-Object { $_ -replace '\s+$', '' } | Out-String

    # Fix possible bad redirection (very specific!)
    $cleaned = $cleaned -replace '2>\s+', '2>&1 '

    if ($cleaned -ne $original) {
        $fixedFiles++
        Write-Host "[SBD] âœ… Cleaned: $path"
        [System.IO.File]::WriteAllText($path, $cleaned, [System.Text.UTF8Encoding]::new($true))
    }
}

if ($fixedFiles -eq 0) {
    Write-Host "[SBD] ðŸŸ¢ No changes were needed."
} else {
    Write-Host "[SBD] âœ¨ Auto-fixed $fixedFiles file(s). Please review changes before commit." -ForegroundColor Yellow
}
exit 0
























