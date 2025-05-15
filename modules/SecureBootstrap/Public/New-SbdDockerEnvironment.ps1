function New-SbdDockerEnvironment {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$ImageName,

        [Parameter(Mandatory = $false)]
        [switch]$EnableTests
    )

    # Ensure Docker is ready
    if (-not (Test-DockerReady)) {
        return
    }

    # Create Docker environment directory if it doesn't exist
    if (-not (Test-Path $Path)) {
        if ($PSCmdlet.ShouldProcess($Path, "Create Docker environment directory")) {
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
            Write-SbdLog -Message "Created Docker environment directory: $Path" -Level Success
        }
    }

    # Create Dockerfile
    $dockerfilePath = Join-Path $Path "Dockerfile"
    $dockerfileContent = @"
FROM mcr.microsoft.com/powershell:latest

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies
RUN pwsh -Command "Install-Module -Name Pester -Force -Scope AllUsers"

# Set entrypoint
ENTRYPOINT ["pwsh"]
"@

    if ($PSCmdlet.ShouldProcess($dockerfilePath, "Create Dockerfile")) {
        Set-Content -Path $dockerfilePath -Value $dockerfileContent -Encoding UTF8
        Write-SbdLog -Message "Created Dockerfile at: $dockerfilePath" -Level Success
    }

    # Build Docker image
    if ($PSCmdlet.ShouldProcess($ImageName, "Build Docker image")) {
        try {
            docker build -t $ImageName $Path
            Write-SbdLog -Message "Successfully built Docker image: $ImageName" -Level Success
        }
        catch {
            Write-SbdLog -Message "Failed to build Docker image: $_" -Level Error
            return
        }
    }

    # Run tests if enabled
    if ($EnableTests) {
        if ($PSCmdlet.ShouldProcess("Docker container", "Run tests")) {
            try {
                docker run --rm $ImageName pwsh -Command "Invoke-Pester"
                Write-SbdLog -Message "Tests completed successfully" -Level Success
            }
            catch {
                Write-SbdLog -Message "Tests failed: $_" -Level Error
            }
        }
    }
}











