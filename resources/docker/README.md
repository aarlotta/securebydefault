# Docker Environment

This folder contains all Docker-related assets for the SecureByDefault project.

## Structure

- `Dockerfile` – The main build definition
- `app/` – Optional build context (left empty by default)
- `tests/` – Optional test scripts

## Usage

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

## Design Principles

1. **Minimal Base**: Uses Alpine Linux for a small attack surface
2. **No PowerShell**: Container is designed for basic validation only
3. **Clear Structure**: All Docker assets are centralized here
4. **Security First**: Follows container security best practices 