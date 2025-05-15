# SecureByDefault Docker Resources

This directory contains Docker-related resources for the SecureByDefault project.

## Dockerfile

The `Dockerfile` provides a minimal Alpine-based container for running basic validation tests. It is designed to be lightweight and secure, without any PowerShell dependencies.

### Features

- Uses Alpine Linux as the base image
- Includes essential tools for validation (bash, curl, grep, jq)
- Runs basic UID/GID validation tests
- Sets CI environment for non-interactive operation

### Building the Image

```bash
# From the project root
docker build -t securebydefault/base -f resources/docker/Dockerfile .
```

### Running Tests

```bash
# Run the container with validation tests
docker run --rm securebydefault/base
```

## Directory Structure

```
resources/docker/
├── Dockerfile          # Main Docker build file
├── app/               # Application-specific files (if needed)
└── tests/             # Test scripts
    └── test_uid.sh    # UID/GID validation script
```

## Best Practices

1. Keep the image minimal and focused
2. Use shell scripts for validation when possible
3. Avoid installing unnecessary packages
4. Follow security best practices for container builds

## Notes

- The container is designed for basic validation only
- PowerShell tests are run outside the container
- The image is intentionally minimal to reduce attack surface 