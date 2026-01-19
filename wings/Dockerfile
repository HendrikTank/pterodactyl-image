# Pterodactyl Wings Dockerfile
FROM alpine:latest

# Wings version
ARG WINGS_VERSION=1.12.1
ENV WINGS_VERSION=1.12.1

LABEL maintainer="your-email@example.com"
LABEL org.opencontainers.image.source="https://github.com/HendrikTank/pterodactyl-image"
LABEL org.opencontainers.image.description="Pterodactyl Wings Docker Image"
LABEL version="${WINGS_VERSION}"

# Install dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    docker \
    tar \
    tzdata

# Download Wings binary
RUN curl -Lo /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/download/v${WINGS_VERSION}/wings_linux_amd64" \
    && chmod +x /usr/local/bin/wings

# Create necessary directories
RUN mkdir -p /etc/pterodactyl /var/lib/pterodactyl /var/log/pterodactyl

# Set working directory
WORKDIR /etc/pterodactyl

# Expose ports
EXPOSE 8080 2022

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/api/system || exit 1

# Run Wings
CMD ["/usr/local/bin/wings", "--config", "/etc/pterodactyl/config.yml"]
