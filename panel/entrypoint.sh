#!/bin/sh
set -e

# Pterodactyl Panel Entrypoint Script

echo "Starting Pterodactyl Panel v${PANEL_VERSION}..."

# Wait for database to be ready
if [ ! -z "$DB_HOST" ]; then
    echo "Waiting for database..."
    while ! nc -z $DB_HOST ${DB_PORT:-3306}; do
        sleep 1
    done
    echo "Database is ready!"
fi

# Run migrations if needed
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Running database migrations..."
    php artisan migrate --force --seed
fi

# Clear and cache config
php artisan config:clear
php artisan config:cache

# Start PHP-FPM
exec "$@"
