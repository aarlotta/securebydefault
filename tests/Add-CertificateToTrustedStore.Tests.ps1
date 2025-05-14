# Pester 3.4.0 tests for Add-CertificateToTrustedStore
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Resolve-Path (Join-Path $here '..\modules\SecureBootstrap\SecureBootstrap.psd1')

# Import the module
Import-Module $modulePath -Force

Describe "Add-CertificateToTrustedStore" {
    Context "Certificate Trust Management" {
        # Test project name
        $TestProject = "TestTrustStore"
        $TestSubject = "CN=$TestProject Code Signing Cert"

        BeforeAll {
            # Reset test environment
            . $here\Reset-TestEnvironment.ps1
        }

        BeforeEach {
            # Clean up any existing test certificates
            Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { Remove-Item $_.PSPath -Force }

            # Clean up from TrustedPublisher
            $trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher', 'CurrentUser')
            $trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
            $trustedStore.Certificates | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { $trustedStore.Remove($_) }
            $trustedStore.Close()
        }

        It "Should add a valid certificate to TrustedPublisher" {
            # Create a test certificate and ensure we get a single X509Certificate2 object
            $cert = (New-CodeSigningCertificate -Project $TestProject) | Where-Object { $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] } | Select-Object -First 1

            # Add to trusted store
            $output = Add-CertificateToTrustedStore -Certificate $cert
            $outputText = $output | Where-Object { $_ -is [string] } | Out-String
            $outputText | Should Match "Certificate added to TrustedPublisher"

            # Verify it's in TrustedPublisher
            $trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher', 'CurrentUser')
            $trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
            $trustedCert = $trustedStore.Certificates.Find([System.Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint, $cert.Thumbprint, $false)
            $trustedStore.Close()

            $trustedCert | Should Not BeNullOrEmpty
        }

        It "Should not add certificate if already trusted" {
            # Create and add certificate
            $cert = (New-CodeSigningCertificate -Project $TestProject) | Where-Object { $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] } | Select-Object -First 1
            Add-CertificateToTrustedStore -Certificate $cert | Out-Null

            # Try to add again
            $output = Add-CertificateToTrustedStore -Certificate $cert
            $outputText = $output | Where-Object { $_ -is [string] } | Out-String
            $outputText | Should Match "Certificate already trusted"

            # Verify only one instance exists
            $trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher', 'CurrentUser')
            $trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
            $trustedCerts = $trustedStore.Certificates.Find([System.Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint, $cert.Thumbprint, $false)
            $trustedStore.Close()

            $trustedCerts.Count | Should Be 1
        }

        It "Should validate certificate trust status correctly" {
            # Create a new certificate
            $cert = (New-CodeSigningCertificate -Project $TestProject) | Where-Object { $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] } | Select-Object -First 1

            # Verify it exists in CurrentUser\My
            $myStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser")
            $myStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
            $certInMyStore = $myStore.Certificates.Find([System.Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint, $cert.Thumbprint, $false)
            $myStore.Close()
            $certInMyStore | Should Not BeNullOrEmpty

            # Add to trusted store
            $output = Add-CertificateToTrustedStore -Certificate $cert
            $outputText = $output | Where-Object { $_ -is [string] } | Out-String
            $outputText | Should Match "(Certificate added to TrustedPublisher|Certificate already trusted)"

            # Verify it exists in TrustedPublisher
            $trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher', 'CurrentUser')
            $trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
            $trustedCert = $trustedStore.Certificates.Find([System.Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint, $cert.Thumbprint, $false)
            $trustedStore.Close()
            $trustedCert | Should Not BeNullOrEmpty

            # Verify thumbprints match
            $trustedCert.Thumbprint | Should Be $cert.Thumbprint
        }

        It "Should throw if certificate does not have Code Signing EKU" {
            # Create a certificate with only basic key usage and no EKU
            $badCert = New-SelfSignedCertificate -DnsName "InvalidCert" -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsage DigitalSignature
            $badCertWithNoEku = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $badCert.Thumbprint }

            { Add-CertificateToTrustedStore -Certificate $badCertWithNoEku } | Should Throw "Code Signing Enhanced Key Usage"
        }

        AfterAll {
            # Clean up test certificates
            Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { Remove-Item $_.PSPath -Force }

            # Clean up InvalidCert
            Get-ChildItem -Path Cert:\CurrentUser\My |
                Where-Object { $_.Subject -like "*InvalidCert*" } |
                ForEach-Object { Remove-Item $_.PSPath -Force }

            # Clean up from TrustedPublisher
            $trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher', 'CurrentUser')
            $trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
            $trustedStore.Certificates | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { $trustedStore.Remove($_) }
            $trustedStore.Close()
        }
    }
} 