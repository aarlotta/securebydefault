function New-CodeSigningCertificate {
    param (
        [string]$Project = "SecureDevEnv"
    )

    $subject = "CN=$Project Code Signing Cert"
    $storePath = "Cert:\CurrentUser\My"
    $pfxPath = "certs/dev-signing.pfx"

    $cert = Get-ChildItem $storePath | Where-Object { $_.Subject -eq $subject }

    if (-not $cert) {
        Write-Host "Creating new self-signed certificate..."
        $cert = New-SelfSignedCertificate `
            -Subject $subject `
            -CertStoreLocation $storePath `
            -KeyExportPolicy Exportable `
            -KeySpec Signature `
            -NotAfter (Get-Date).AddYears(3)
        Write-Host "Created certificate: $($cert.Subject)"
    }
    else {
        Write-Host "Reusing existing certificate: $($cert.Subject)"
    }

    if (-not (Test-Path $pfxPath)) {
        Write-Host "Exporting certificate to $pfxPath"
        $securePassword = ConvertTo-SecureString -String "dev-password" -AsPlainText -Force
        Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $securePassword | Out-Null
    }
    else {
        Write-Host "Certificate already exported to $pfxPath"
    }

    return $cert
}
