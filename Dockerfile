# Use minimal Alpine base image
FROM alpine:latest

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Set environment variables
ENV CI=true

# No need for an entrypoint or command since we're not running PowerShell tests
# The container can be used for other purposes or extended as needed 