# syntax=docker/dockerfile:1.4
# SecureBootstrap Base Image
# Maintainer: Anderson Arlotta
FROM alpine

LABEL maintainer="anderson@baxitservices.com"
LABEL org.opencontainers.image.source="https://github.com/aarlotta/securebydefault"

# 🔐 Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 📁 App folder
WORKDIR /app
COPY --chown=appuser:appgroup ./app /app

# 🧼 Drop privileges
USER appuser
CMD ["echo", "Secure base container ready. Extend this image as needed."] 