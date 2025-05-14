Describe "Sign-Script" {
    Context "When signing scripts" {
        # Create test certificate
        $cert = New-CodeSigningCertificate -Project "TestSecureSign"

        BeforeEach {
            # Create test files in $TestDrive
            $testFiles = @(
                "script1.ps1",
                "subfolder/script2.ps1",
                "subfolder/deep/script3.ps1"
            )

            foreach ($file in $testFiles) {
                $path = Join-Path $TestDrive $file
                $directory = Split-Path $path -Parent
                if (-not (Test-Path $directory)) {
                    New-Item -ItemType Directory -Path $directory -Force | Out-Null
                }
                Set-Content -Path $path -Value "# Test script"
            }
        }

        It "Should have a trusted code signing certificate" {
            # Verify certificate exists and is trusted
            $cert | Should Not BeNullOrEmpty
            $cert.EnhancedKeyUsageList | Should Match "Code Signing"
            
            # Check if certificate is in TrustedPublisher store
            $trustedStore = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher', 'CurrentUser')
            $trustedStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
            $trustedCert = $trustedStore.Certificates.Find([System.Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint, $cert.Thumbprint, $false)
            $trustedStore.Close()
            
            $trustedCert | Should Not BeNullOrEmpty
        }

        It "Should sign all .ps1 files in the target path" {
            # Mock Set-AuthenticodeSignature to avoid actual signing
            Mock Set-AuthenticodeSignature {
                return [PSCustomObject]@{
                    Status = 'Valid'
                    Path = $FilePath
                }
            }

            $result = Sign-Script -Project "TestSecureSign" -TargetPath $TestDrive

            # Verify all files were signed
            $signedFiles = Get-ChildItem -Path $TestDrive -Recurse -Filter "*.ps1"
            $result | Should Be $signedFiles.Count

            # Verify each file was processed
            foreach ($file in $signedFiles) {
                Assert-MockCalled Set-AuthenticodeSignature -ParameterFilter {
                    $FilePath -eq $file.FullName
                }
            }
        }

        It "Should sign all .ps1 files in the target path with a valid certificate" {
            # Create a certificate without Code Signing EKU
            $badCert = New-SelfSignedCertificate -DnsName "InvalidCert" -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsage DigitalSignature
            $badCertWithNoEku = Get-ChildItem Cert:\CurrentUser\My | 
                Where-Object { $_.Thumbprint -eq $badCert.Thumbprint } |
                Select-Object -First 1

            { Sign-Script -Project "InvalidCert" -TargetPath $TestDrive } | Should Throw "Code Signing Enhanced Key Usage"
        }

        It "Should throw when certificate is not found" {
            { Sign-Script -Project "NonExistentProject" } | Should Throw "No certificates found with subject"
        }

        It "Should handle signing failures gracefully" {
            # Create a certificate without Code Signing EKU
            $badCert = New-SelfSignedCertificate -DnsName "InvalidCert" -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsage DigitalSignature
            $badCertWithNoEku = Get-ChildItem Cert:\CurrentUser\My | 
                Where-Object { $_.Thumbprint -eq $badCert.Thumbprint } |
                Select-Object -First 1

            { Sign-Script -Project "InvalidCert" -TargetPath $TestDrive } | Should Throw "Code Signing Enhanced Key Usage"
        }

        # Clean up test certificates
        AfterAll {
            # Clean up test certificate
            Remove-Item -Path "Cert:\CurrentUser\My\$($cert.Thumbprint)" -Force
            
            # Clean up InvalidCert
            Get-ChildItem -Path Cert:\CurrentUser\My |
                Where-Object { $_.Subject -like "*InvalidCert*" } |
                ForEach-Object { Remove-Item $_.PSPath -Force }
        }
    }
} 