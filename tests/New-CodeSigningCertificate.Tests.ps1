# Pester 3.4.0 tests for New-CodeSigningCertificate
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Resolve-Path (Join-Path $here '..\modules\SecureBootstrap\SecureBootstrap.psd1')

# Import the module
Import-Module $modulePath -Force

Describe "New-CodeSigningCertificate" {
    Context "Certificate Creation and Reuse" {
        # Define test project name
        $TestProject = "TestProject"
        $TestSubject = "CN=$TestProject Code Signing Cert"

        # Ensure certs directory exists
        if (-not (Test-Path "certs")) {
            New-Item -ItemType Directory -Path "certs" | Out-Null
        }

        It "Should create a new certificate on first call" {
            # Clean up any existing test certificates
            Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { Remove-Item $_.PSPath -Force }

            # First call should create a new certificate
            $output = New-CodeSigningCertificate -Project $TestProject 4>&1
            $output | Should Match "Created new self-signed code signing certificate"
            
            # Verify certificate exists in store
            $cert = Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject }
            $cert | Should Not BeNullOrEmpty
            $cert.Subject | Should Be $TestSubject
        }

        It "Should reuse existing certificate on second call" {
            # Clean up any existing test certificates
            Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { Remove-Item $_.PSPath -Force }

            # Create initial certificate
            New-CodeSigningCertificate -Project $TestProject | Out-Null

            # Get initial certificate count
            $initialCount = (Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject }).Count

            # Second call should reuse the certificate
            $output = New-CodeSigningCertificate -Project $TestProject 4>&1
            $output | Should Match "Reusing existing certificate"

            # Verify no new certificate was created
            $finalCount = (Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject }).Count
            $finalCount | Should Be $initialCount
        }

        It "Should return a valid X509Certificate2 object" {
            # Clean up any existing test certificates
            Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { Remove-Item $_.PSPath -Force }

            $cert = New-CodeSigningCertificate -Project $TestProject
            $cert | Should Not BeNullOrEmpty
            $cert.GetType().FullName | Should Be "System.Security.Cryptography.X509Certificates.X509Certificate2"
        }

        It "Should not throw exceptions when invoked" {
            # Clean up any existing test certificates
            Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { Remove-Item $_.PSPath -Force }

            { New-CodeSigningCertificate -Project $TestProject } | Should Not Throw
        }
    }

    Context "Certificate Export" {
        # Define test project name
        $TestProject = "TestProject"
        $TestSubject = "CN=$TestProject Code Signing Cert"

        # Ensure certs directory exists
        if (-not (Test-Path "certs")) {
            New-Item -ItemType Directory -Path "certs" | Out-Null
        }

        It "Should export certificate to PFX file on first run" {
            # Clean up any existing test certificates
            Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { Remove-Item $_.PSPath -Force }

            # Clean up any existing export
            if (Test-Path "certs/dev-signing.pfx") {
                Remove-Item "certs/dev-signing.pfx" -Force
            }

            # Call function and capture output
            $output = New-CodeSigningCertificate -Project $TestProject 4>&1
            $output | Should Match "Exported certificate to"

            # Verify file exists
            Test-Path "certs/dev-signing.pfx" | Should Be $true
        }

        It "Should skip export if PFX file already exists" {
            # Clean up any existing test certificates
            Get-ChildItem -Path Cert:\CurrentUser\My | 
                Where-Object { $_.Subject -eq $TestSubject } | 
                ForEach-Object { Remove-Item $_.PSPath -Force }

            # Ensure file exists
            if (-not (Test-Path "certs/dev-signing.pfx")) {
                New-CodeSigningCertificate -Project $TestProject | Out-Null
            }

            # Get file timestamp before second call
            $beforeTime = (Get-Item "certs/dev-signing.pfx").LastWriteTime

            # Call function again and capture output
            $output = New-CodeSigningCertificate -Project $TestProject 4>&1
            $output | Should Match "Certificate already exported"

            # Verify file wasn't modified
            $afterTime = (Get-Item "certs/dev-signing.pfx").LastWriteTime
            $afterTime | Should Be $beforeTime
        }
    }
} 