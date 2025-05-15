# syntax=docker/dockerfile:1.4

# Use Ubuntu as a clean base
FROM ubuntu:22.04

LABEL maintainer="anderson@baxitservices.com"
LABEL org.opencontainers.image.source="https://github.com/aarlotta/securebydefault"

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget apt-transport-https software-properties-common unzip curl less \
    && rm -rf /var/lib/apt/lists/*

# Install PowerShell Core 7.4.1 via GitHub
RUN wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-linux-x64.tar.gz -O /tmp/pwsh.tar.gz \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar -xzf /tmp/pwsh.tar.gz -C /opt/microsoft/powershell/7 \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Set workdir
WORKDIR /app

# Copy application content
COPY . /app

# Install Pester and verify PowerShell
RUN pwsh -Command "Install-Module -Name Pester -Force -Scope AllUsers -ErrorAction Stop" \
    && pwsh -Command '$PSVersionTable.PSVersion.ToString()'

# Default command
CMD ["pwsh"]
