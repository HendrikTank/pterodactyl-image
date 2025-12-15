# Release Guide

This document explains how to build and release Pterodactyl Docker images using the automated workflows.

## Overview

This repository includes two main workflows:
1. **Build Workflow** - Builds and tests Docker images on PRs and pushes to main
2. **Release Workflow** - Builds multi-platform images and publishes to registries

## Setup

### GitHub Container Registry (GHCR)

GHCR is enabled by default and requires no additional setup. Images are automatically pushed to:
- `ghcr.io/<username>/<repo>/panel`
- `ghcr.io/<username>/<repo>/wings`

### Docker Hub (Optional)

To push images to Docker Hub, you need to configure secrets:

1. Create a Docker Hub access token:
   - Go to https://hub.docker.com/settings/security
   - Click "New Access Token"
   - Give it a description (e.g., "GitHub Actions")
   - Copy the generated token

2. Add secrets to your GitHub repository:
   - Go to your repository Settings → Secrets and variables → Actions
   - Add the following secrets:
     - `DOCKERHUB_USERNAME`: Your Docker Hub username
     - `DOCKERHUB_TOKEN`: Your Docker Hub access token

3. Create repositories on Docker Hub:
   - `<username>/panel`
   - `<username>/wings`

## Build Workflow

The build workflow runs automatically on:
- Push to `main` branch
- Pull requests to `main` branch
- Manual trigger via workflow_dispatch

### What it does:
- Builds Panel Docker image
- Builds Wings Docker image
- Validates docker-compose.yml syntax
- Does NOT push images to any registry

### Manual trigger:
```bash
gh workflow run build.yml
```

## Release Workflow

The release workflow publishes Docker images to registries.

### Automatic Release (with Docker Hub)

Triggered by pushing a version tag:

```bash
# Tag the release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

This will:
- Build multi-platform images (amd64, arm64)
- Push to GHCR (always)
- Push to Docker Hub (if secrets are configured)
- Create a GitHub Release with notes

### Manual Release

Trigger manually via GitHub Actions UI:

1. Go to Actions → Release Docker Images → Run workflow
2. Fill in the inputs:
   - **version**: Version tag (e.g., `v1.0.0`)
   - **push_to_dockerhub**: Check to push to Docker Hub

Or via CLI:

```bash
# Release to GHCR only
gh workflow run release.yml -f version=v1.0.0

# Release to both GHCR and Docker Hub
gh workflow run release.yml -f version=v1.0.0 -f push_to_dockerhub=true
```

## Image Tags

Each release creates multiple tags:

### Semantic Version Tags
- `1.0.0` - Specific version
- `1.0` - Major.minor version
- `1` - Major version only

### Special Tags
- `latest` - Latest release
- `1.11.6` - Pterodactyl component version (Panel or Wings)
- `20231215` - Date-based tag (YYYYMMDD)

### Examples:

```bash
# Pull specific version
docker pull ghcr.io/hendrictank/pterodactyl-image/panel:1.0.0

# Pull latest
docker pull ghcr.io/hendrictank/pterodactyl-image/panel:latest

# Pull by Pterodactyl version
docker pull ghcr.io/hendrictank/pterodactyl-image/panel:1.11.6

# From Docker Hub (if configured)
docker pull hendrictank/pterodactyl-image/panel:latest
```

## Multi-Platform Support

All release images are built for:
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM 64-bit, Apple Silicon, etc.)

Docker automatically pulls the correct architecture for your platform.

## Version Management

Pterodactyl component versions are managed in:
- `.env` file - Source of truth for versions
- `panel/Dockerfile` - Panel version
- `wings/Dockerfile` - Wings version

To update versions, use the update scripts:

```bash
# Update Panel version
bash scripts/update-versions.sh panel 1.11.7

# Update Wings version
bash scripts/update-versions.sh wings 1.11.9
```

## Troubleshooting

### Docker Hub push fails

**Error**: `denied: requested access to the resource is denied`

**Solution**: 
1. Verify `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets are set correctly
2. Ensure the repositories exist on Docker Hub
3. Check that the access token has write permissions

### Multi-platform build fails

**Error**: `failed to solve: failed to push`

**Solution**:
- This usually means the platform doesn't support the architecture
- Check if base images support both amd64 and arm64
- May need to adjust Dockerfiles for cross-platform compatibility

### Release notes don't show Docker Hub instructions

This is expected behavior when:
- Secrets are not configured
- Manual workflow without `push_to_dockerhub=true`

## Best Practices

1. **Test before releasing**: Always run the build workflow first
2. **Version consistency**: Keep release tags in sync with Pterodactyl versions
3. **Semantic versioning**: Follow semver (MAJOR.MINOR.PATCH)
4. **Security**: Regularly rotate Docker Hub access tokens
5. **Documentation**: Update CHANGELOG.md with each release

## GitHub Actions Secrets Reference

| Secret | Required | Description |
|--------|----------|-------------|
| `GITHUB_TOKEN` | Yes (auto) | Automatically provided by GitHub |
| `DOCKERHUB_USERNAME` | Optional | Docker Hub username for publishing |
| `DOCKERHUB_TOKEN` | Optional | Docker Hub access token |

## Example Release Process

Complete release workflow:

```bash
# 1. Ensure versions are up to date
grep PANEL_VERSION .env
grep WINGS_VERSION .env

# 2. Test the build
gh workflow run build.yml
# Wait for completion and verify success

# 3. Create and push release tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 4. Monitor the release workflow
gh run watch

# 5. Verify images are published
docker pull ghcr.io/hendrictank/pterodactyl-image/panel:latest
docker pull ghcr.io/hendrictank/pterodactyl-image/wings:latest

# 6. Test the images
docker compose up -d
docker compose ps
```

## Additional Resources

- [GitHub Container Registry Documentation](https://docs.github.com/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Docker Buildx Documentation](https://docs.docker.com/buildx/working-with-buildx/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
