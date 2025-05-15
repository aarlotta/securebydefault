FROM mcr.microsoft.com/powershell:latest

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies
RUN pwsh -Command "Install-Module -Name Pester -Force -Scope AllUsers -MinimumVersion 5.5.0"

# Set entrypoint
ENTRYPOINT ["pwsh"]
