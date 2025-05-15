# Use PowerShell 7 base image
FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies
RUN pwsh -Command "Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser"

# Set environment variables
ENV CI=true
ENV POWERSHELL_TELEMETRY_OPTOUT=1

# Run tests
CMD ["pwsh", "-Command", "Invoke-Pester -Path ./tests -Output Detailed"] 