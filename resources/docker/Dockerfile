FROM mcr.microsoft.com/powershell:latest

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies
RUN /usr/bin/pwsh -Command "Install-Module -Name Pester -Force -Scope AllUsers -ErrorAction Stop"

# Set entrypoint
ENTRYPOINT ["/usr/bin/pwsh"]
