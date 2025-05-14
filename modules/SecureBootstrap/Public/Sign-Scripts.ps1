function Sign-Scripts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Project = "SecureDevEnv",

        [Parameter(Mandatory = $false)]
        [string]$TargetPath = "."
    )

    # Find the code signing certificate
    $certSubject = "CN=$Project Code Signing Cert"
    $cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq $certSubject }

    if (-not $cert) {
        throw "❌ Signing certificate not found for $Project"
    }

    # Ensure certificate is trusted
    try {
        Add-CertificateToTrustedStore -Certificate $cert
    }
    catch {
        Write-Warning "Certificate trust check failed: $_"
        Write-Warning "Script signing may fail if certificate is not trusted"
    }

    # Get all .ps1 files recursively
    $scripts = Get-ChildItem -Path $TargetPath -Recurse -Filter "*.ps1"
    $signedCount = 0

    foreach ($script in $scripts) {
        try {
            $result = Set-AuthenticodeSignature -FilePath $script.FullName -Certificate $cert
            if ($result.Status -eq 'Valid') {
                Write-Host "✍️ Signed: $($script.FullName)"
                $signedCount++
            }
        }
        catch {
            Write-Warning "Failed to sign $($script.FullName): $_"
        }
    }

    Write-Host "✅ Signed $signedCount scripts with certificate: $certSubject"
    return $signedCount
} 