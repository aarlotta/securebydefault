Describe "Sign-Scripts" {
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

        It "Should sign all .ps1 files in the target path" {
            # Mock Set-AuthenticodeSignature to avoid actual signing
            Mock Set-AuthenticodeSignature {
                return [PSCustomObject]@{
                    Status = 'Valid'
                    Path = $FilePath
                }
            }

            $result = Sign-Scripts -Project "TestSecureSign" -TargetPath $TestDrive

            # Verify all files were signed
            $signedFiles = Get-ChildItem -Path $TestDrive -Recurse -Filter "*.ps1"
            $result | Should -Be $signedFiles.Count

            # Verify each file was processed
            foreach ($file in $signedFiles) {
                Assert-MockCalled Set-AuthenticodeSignature -ParameterFilter {
                    $FilePath -eq $file.FullName
                }
            }
        }

        It "Should throw when certificate is not found" {
            { Sign-Scripts -Project "NonExistentProject" } | Should -Throw "❌ Signing certificate not found for NonExistentProject"
        }

        It "Should handle signing failures gracefully" {
            # Mock Set-AuthenticodeSignature to simulate a failure
            Mock Set-AuthenticodeSignature {
                throw "Simulated signing failure"
            }

            { Sign-Scripts -Project "TestSecureSign" -TargetPath $TestDrive } | Should -Not -Throw
        }

        # Clean up test certificate
        Remove-Item -Path "Cert:\CurrentUser\My\$($cert.Thumbprint)" -Force
    }
} 