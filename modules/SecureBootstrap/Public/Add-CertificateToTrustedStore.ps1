function Add-CertificateToTrustedStore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate
    )

    # Constants
    $CODE_SIGNING_OID = "1.3.6.1.5.5.7.3.3"
    $TRUSTED_PUBLISHER_STORE = "TrustedPublisher"
    $CURRENT_USER_STORE = "CurrentUser"

    try {
        # Validate certificate is from CurrentUser\My
        $myStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", $CURRENT_USER_STORE)
        $myStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        $certInMyStore = $myStore.Certificates.Find([System.Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint, $Certificate.Thumbprint, $false)
        $myStore.Close()

        if (-not $certInMyStore) {
            throw "Certificate must be from CurrentUser\My store"
        }

        # Validate certificate is self-signed
        if ($Certificate.Issuer -ne $Certificate.Subject) {
            throw "Certificate must be self-signed (Issuer must match Subject)"
        }

        # Validate certificate has Code Signing EKU
        $hasCodeSigningEKU = $false
        foreach ($extension in $Certificate.Extensions) {
            if ($extension -is [System.Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension]) {
                foreach ($oid in $extension.EnhancedKeyUsages) {
                    if ($oid.Value -eq $CODE_SIGNING_OID) {
                        $hasCodeSigningEKU = $true
                        break
                    }
                }
            }
        }

        if (-not $hasCodeSigningEKU) {
            throw "Certificate must have Code Signing Enhanced Key Usage"
        }

        # Check if certificate is already in TrustedPublisher
        $trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store($TRUSTED_PUBLISHER_STORE, $CURRENT_USER_STORE)
        $trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        $certInTrustedStore = $trustedStore.Certificates.Find([System.Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint, $Certificate.Thumbprint, $false)
        $trustedStore.Close()

        if ($certInTrustedStore) {
            Write-Verbose "Certificate already trusted: $($Certificate.Subject)"
            return
        }

        # Add certificate to TrustedPublisher
        $trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store($TRUSTED_PUBLISHER_STORE, $CURRENT_USER_STORE)
        $trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        $trustedStore.Add($Certificate)
        $trustedStore.Close()

        Write-Host "✔️ Trusted certificate added: $($Certificate.Subject)"
    }
    catch {
        $errorMsg = "Failed to add certificate to TrustedPublisher: " + $_.Exception.Message
        Write-Error $errorMsg
        throw
    }
} 