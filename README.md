# Pterodactyl Docker Images

[![Build Docker Images](https://github.com/<username>/<repo>/actions/workflows/build.yml/badge.svg)](https://github.com/<username>/<repo>/actions/workflows/build.yml)
[![Release Docker Images](https://github.com/<username>/<repo>/actions/workflows/release.yml/badge.svg)](https://github.com/<username>/<repo>/actions/workflows/release.yml)

Docker images for [Pterodactyl Panel](https://github.com/pterodactyl/panel) and [Pterodactyl Wings](https://github.com/pterodactyl/wings).

## Features

- 🐳 Pre-built Docker images for Panel and Wings
- 🔄 Automated version updates via GitHub Actions
- 🏗️ Multi-platform support (amd64, arm64)
- 📦 Published to GitHub Container Registry and Docker Hub
- 🚀 Easy deployment with docker-compose

## Quick Start

### Using Docker Compose

```bash
# Clone the repository
git clone https://github.com/<username>/<repo>.git
cd <repo>

# Start the services
docker compose up -d
```

### Using Pre-built Images

#### From GitHub Container Registry (GHCR)

```bash
# Pull Panel image
docker pull ghcr.io/<username>/<repo>/panel:latest

# Pull Wings image
docker pull ghcr.io/<username>/<repo>/wings:latest
```

#### From Docker Hub (if published)

```bash
# Pull Panel image
docker pull <username>/panel:latest

# Pull Wings image
docker pull <username>/wings:latest
```

## Available Images

### Panel
- **Base**: PHP 8.1 FPM Alpine
- **Includes**: Nginx, Supervisor, Composer, PostgreSQL/MySQL clients
- **Ports**: 80

### Wings
- **Base**: Alpine Linux
- **Includes**: Docker CLI, Wings binary
- **Ports**: 8080 (API), 2022 (SFTP)

## Current Versions

- **Panel**: v1.11.6
- **Wings**: v1.11.8

## Documentation

- [Release Guide](docs/RELEASE_GUIDE.md) - How to build and release images
- [Pterodactyl Documentation](https://pterodactyl.io/project/introduction.html)

## Workflows

This repository includes automated GitHub Actions workflows:

### Build Workflow
- Triggers on push to main and pull requests
- Builds and tests Docker images
- Validates docker-compose configuration

### Release Workflow
- Triggers on version tags (e.g., `v1.0.0`)
- Builds multi-platform images
- Publishes to GitHub Container Registry
- Optionally publishes to Docker Hub
- Creates GitHub releases with notes

### Update Workflow
- Runs weekly to check for new Pterodactyl versions
- Automatically creates PRs for version updates
- Tests builds before merging

## Configuration

Environment variables are managed in `.env`:

```bash
# Pterodactyl Versions
PANEL_VERSION=1.11.6
WINGS_VERSION=1.11.8

# Database Configuration
DB_HOST=database
DB_DATABASE=pterodactyl
DB_USERNAME=pterodactyl
DB_PASSWORD=changeme

# Application Settings
APP_URL=http://localhost
```

## Development

### Building Images Locally

```bash
# Build Panel image
docker build -t pterodactyl-panel:latest ./panel

# Build Wings image
docker build -t pterodactyl-wings:latest ./wings
```

### Testing

```bash
# Validate docker-compose syntax
docker compose config

# Test the services
docker compose up -d
docker compose ps
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Acknowledgments

- [Pterodactyl Software](https://pterodactyl.io/) - The amazing game server management panel
- All contributors to this project