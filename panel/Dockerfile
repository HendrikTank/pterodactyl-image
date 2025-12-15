# Pterodactyl Panel Dockerfile
FROM php:8.1-fpm-alpine

# Panel version
ARG PANEL_VERSION=1.11.6
ENV PANEL_VERSION=1.11.6

LABEL maintainer="your-email@example.com"
LABEL org.opencontainers.image.source="https://github.com/HendrikTank/pterodactyl-image"
LABEL org.opencontainers.image.description="Pterodactyl Panel Docker Image"
LABEL version="${PANEL_VERSION}"

# Install dependencies
RUN apk add --no-cache \
    curl \
    git \
    tar \
    unzip \
    nginx \
    supervisor \
    postgresql-client \
    mysql-client \
    && docker-php-ext-install \
        pdo_mysql \
        pdo_pgsql \
        bcmath \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /app

# Download and extract Pterodactyl Panel
RUN curl -Lo panel.tar.gz "https://github.com/pterodactyl/panel/releases/download/v${PANEL_VERSION}/panel.tar.gz" \
    && tar -xzf panel.tar.gz \
    && rm panel.tar.gz \
    && chmod -R 755 storage/* bootstrap/cache/

# Install composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy configuration files
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
