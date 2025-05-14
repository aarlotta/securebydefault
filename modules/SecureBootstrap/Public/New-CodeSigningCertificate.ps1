function New-CodeSigningCertificate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Project = "SecureDevEnv"
    )

    # Set certificate subject
    $Subject = "CN=$Project Code Signing Cert"
    
    # Check if certificate already exists
    $existingCert = Get-ChildItem -Path Cert:\CurrentUser\My | 
        Where-Object { $_.Subject -eq $Subject }
    
    if ($existingCert) {
        Write-Host "✅ Reusing existing certificate: $Subject"
        $certificate = $existingCert
    }
    else {
        # Create new certificate parameters
        $params = @{
            Subject = $Subject
            KeyExportPolicy = 'Exportable'
            KeySpec = 'Signature'
            KeyUsage = 'DigitalSignature'
            KeyAlgorithm = 'RSA'
            KeyLength = 2048
            HashAlgorithm = 'SHA256'
            TextExtension = @(
                "2.5.29.37={text}1.3.6.1.5.5.7.3.3" # Code Signing EKU
            )
            CertStoreLocation = 'Cert:\CurrentUser\My'
            NotAfter = (Get-Date).AddYears(3)
        }

        # Create the certificate
        $certificate = New-SelfSignedCertificate @params
        Write-Host "🔐 Created new self-signed code signing certificate for project: $Subject"
    }

    # Ensure certs directory exists
    $certPath = "certs"
    if (-not (Test-Path $certPath)) {
        New-Item -ItemType Directory -Path $certPath | Out-Null
    }

    # Export certificate if not already exported
    $pfxPath = Join-Path $certPath "dev-signing.pfx"
    if (Test-Path $pfxPath) {
        Write-Host "📁 Certificate already exported to $pfxPath"
    }
    else {
        $securePassword = ConvertTo-SecureString -String "dev-password" -Force -AsPlainText
        Export-PfxCertificate -Cert $certificate -FilePath $pfxPath -Password $securePassword
        Write-Host "📤 Exported certificate to $pfxPath"
    }

    return $certificate
} 