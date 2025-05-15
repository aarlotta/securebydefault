FROM mcr.microsoft.com/powershell:7.4.1-ubuntu-22.04

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Verify PowerShell version
RUN pwsh -Command '$PSVersionTable.PSVersion.ToString()'

# Install dependencies
RUN pwsh -Command "Install-Module -Name Pester -Force -Scope AllUsers"

# Set entrypoint
ENTRYPOINT ["pwsh"]
