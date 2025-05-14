# Reset-TestEnvironment.ps1
# Resets the test environment by cleaning up certificates and PFX files

param(
    [Parameter(Mandatory = $false)]
    [string[]]
    $TestSubjects = @(
        "CN=TestProject Code Signing Cert",
        "CN=TestTrustStore Code Signing Cert"
    )
)

# Clean up certificates from CurrentUser\My
foreach ($subject in $TestSubjects) {
    Get-ChildItem -Path Cert:\CurrentUser\My | 
        Where-Object { $_.Subject -eq $subject } | 
        ForEach-Object { Remove-Item $_.PSPath -Force }
}

# Clean up from TrustedPublisher
$trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher', 'CurrentUser')
$trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
foreach ($subject in $TestSubjects) {
    $trustedStore.Certificates | 
        Where-Object { $_.Subject -eq $subject } | 
        ForEach-Object { $trustedStore.Remove($_) }
}
$trustedStore.Close()

# Clean up PFX files
if (Test-Path "certs") {
    Get-ChildItem -Path "certs" -Filter "*.pfx" | Remove-Item -Force
} 