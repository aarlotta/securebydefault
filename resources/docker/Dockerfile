# Use minimal Alpine base image
FROM alpine:latest

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Set environment variables
ENV CI=true

# Install basic tools for validation
RUN apk add --no-cache \
    bash \
    curl \
    grep \
    jq

# Add validation script
COPY modules/SecureBootstrap/resources/docker/tests/test_uid.sh /app/tests/
RUN chmod +x /app/tests/test_uid.sh

# Run basic validation
CMD ["/bin/bash", "-c", "/app/tests/test_uid.sh"]
