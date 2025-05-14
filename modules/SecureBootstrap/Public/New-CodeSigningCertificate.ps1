function New-CodeSigningCertificate {
    param (
        [string]$Project = "SecureDevEnv"
    )

    $subject = "CN=$Project Code Signing Cert"
    $storePath = "Cert:\CurrentUser\My"
    $pfxPath = "certs/dev-signing.pfx"

    $cert = Get-ChildItem $storePath | Where-Object { $_.Subject -eq $subject }

    if (-not $cert) {
        Write-Host "Created new self-signed code signing certificate for project: $subject"
        $cert = New-SelfSignedCertificate `
            -Subject $subject `
            -CertStoreLocation $storePath `
            -KeyExportPolicy Exportable `
            -KeySpec Signature `
            -NotAfter (Get-Date).AddYears(3)
    } else {
        Write-Host "Reusing existing certificate: $subject"
    }

    if (-not (Test-Path $pfxPath)) {
        Write-Host "Exported certificate to $pfxPath"
        $securePassword = ConvertTo-SecureString -String "dev-password" -AsPlainText -Force
        Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $securePassword | Out-Null
    } else {
        Write-Host "Certificate already exported to $pfxPath"
    }

    return $cert
}
