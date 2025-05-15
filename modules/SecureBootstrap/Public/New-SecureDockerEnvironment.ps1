# [2025-05-14] Add New-SecureDockerEnvironment command to deploy a secure-by-default Docker environment.

function New-SecureDockerEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$ImageName = "securebootstrap/base",
        [string]$BaseTag = "alpine",
        [switch]$EnableTests,
        [switch]$NoPull
    )

    begin {
        Write-Host "[SB] ðŸ›  Creating secure Docker environment at: $Path" -ForegroundColor Cyan

        if (-Not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }

        $modulePath = Split-Path (Get-Module SecureBootstrap).Path -Parent
        $resourcesPath = Join-Path $modulePath "resources"
        $dockerfilePath = Join-Path $Path "Dockerfile"
        $testDir = Join-Path $Path "tests"
        $appDir = Join-Path $Path "app"
    }

    process {
        # 1. Create app directory
        New-Item -ItemType Directory -Path $appDir -Force | Out-Null

        # 2. Copy the secure Dockerfile
        Copy-Item -Path (Join-Path $resourcesPath "docker/Dockerfile") -Destination $dockerfilePath -Force

        # 3. Create test scaffold (if requested)
        if ($EnableTests) {
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
            Copy-Item -Path (Join-Path $resourcesPath "docker/tests/test_uid.sh") -Destination (Join-Path $testDir "test_uid.sh") -Force
        }

        # 4. Final output
        Write-Host "[SB] âœ… Dockerfile created: $dockerfilePath" -ForegroundColor Green
        if ($EnableTests) {
            Write-Host "[SB] âœ… Tests folder created: $testDir" -ForegroundColor Green
        }
        Write-Host "[SB] â„¹ï¸  Run: docker build -t $ImageName `"$Path`"" -ForegroundColor Yellow
    }

    end {
        Write-Host "[SB] ðŸ§ª Secure Docker environment initialized." -ForegroundColor Cyan
    }
}

<#
.SYNOPSIS
    Creates a secure-by-default Docker container scaffold.

.DESCRIPTION
    This function generates a base Docker project that includes a hardened Dockerfile and optional security test scripts.
    Designed for use in dev/test/prod environments where consistency, auditability, and isolation are critical.

.PARAMETER Path
    The target directory where the Docker project should be created.

.PARAMETER ImageName
    Docker image name to use for the base (default: securebootstrap/base)

.PARAMETER BaseTag
    Docker base tag, typically "alpine" or "distroless" (default: alpine)

.PARAMETER EnableTests
    If specified, generates test scripts inside /tests for container validation.

.PARAMETER NoPull
    Skips pulling the base image, useful for airgapped environments.

.EXAMPLE
    New-SecureDockerEnvironment -Path "./resources/SecureDocker" -EnableTests

.NOTES
    Author: Anderson Arlotta (anderson@baxitservices.com)
    Module: SecureBootstrap
    Version: 1.0.0
#>




























