function Sign-Script {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([int])]
    param (
        [Parameter(Mandatory = $false)]
        [string]
        $Project = "SecureDevEnv",

        [Parameter(Mandatory = $false)]
        [string]
        $TargetPath = "."
    )

    # Find the code signing certificate with proper EKU
    $certSubject = "CN=$Project Code Signing Cert"
    $certs = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq $certSubject }
    
    # Filter for certificates with Code Signing EKU
    $cert = $certs | Where-Object {
        $_.Extensions | Where-Object {
            $_.Oid.FriendlyName -eq 'Enhanced Key Usage' -and
            $_.EnhancedKeyUsages | Where-Object { $_.FriendlyName -eq 'Code Signing' }
        }
    } | Select-Object -First 1

    if (-not $cert) {
        $errorMessage = "No valid code signing certificate found for $Project. "
        if ($certs) {
            $errorMessage += "Found certificates but none have Code Signing EKU. "
            $errorMessage += "Available certificates: $($certs.Thumbprint -join ', ')"
        } else {
            $errorMessage += "No certificates found with subject: $certSubject"
        }
        throw $errorMessage
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
    $failedCount = 0
    $failedScripts = @()

    foreach ($script in $scripts) {
        if ($PSCmdlet.ShouldProcess($script.FullName, "Sign script with certificate")) {
            try {
                $result = Set-AuthenticodeSignature -FilePath $script.FullName -Certificate $cert
                if ($result.Status -eq 'Valid') {
                    Write-Verbose "Signed: $($script.FullName)"
                    $signedCount++
                } else {
                    Write-Warning "Signature invalid for $($script.FullName): $($result.StatusMessage)"
                    $failedCount++
                    $failedScripts += $script.FullName
                }
            }
            catch {
                Write-Warning "Failed to sign $($script.FullName): $_"
                $failedCount++
                $failedScripts += $script.FullName
            }
        }
    }

    Write-Verbose "Signed $signedCount scripts with certificate: $certSubject"
    if ($failedCount -gt 0) {
        Write-Warning "Failed to sign $failedCount scripts:"
        $failedScripts | ForEach-Object { Write-Warning "  - $_" }
    }

    return $signedCount
} 