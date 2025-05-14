function New-CodeSigningCertificate {
    param (
        [string]$Project = "SecureDevEnv"
    )

    $subject = "CN=$Project Code Signing Cert"
    $storePath = "Cert:\CurrentUser\My"
    $pfxPath = "certs/dev-signing.pfx"

    $cert = Get-ChildItem $storePath | Where-Object { $_.Subject -eq $subject }

    if (-not $cert) {
        Write-Output "Created new self-signed code signing certificate"
        $cert = New-SelfSignedCertificate `
            -Subject $subject `
            -CertStoreLocation $storePath `
            -KeyExportPolicy Exportable `
            -KeySpec Signature `
            -Type CodeSigningCert `
            -NotAfter (Get-Date).AddYears(3)
    } else {
        Write-Output "Reusing existing certificate"
    }

    if (-not (Test-Path $pfxPath)) {
        Write-Output "Exported certificate to $pfxPath"
        $securePassword = ConvertTo-SecureString -String "dev-password" -AsPlainText -Force
        Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $securePassword | Out-Null
    } else {
        Write-Output "Certificate already exported to $pfxPath"
    }

    Write-Output $cert
}
