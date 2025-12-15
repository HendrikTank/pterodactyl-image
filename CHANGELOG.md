# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Build workflow for automated Docker image building on push and PRs
- Release workflow for multi-platform image publishing
- Docker Hub support with optional publishing
- Comprehensive release documentation
- GitHub Actions secrets setup guide
- Multi-platform support (linux/amd64, linux/arm64)

### Changed
- Updated README with workflow badges and usage instructions

## Release Guidelines

When creating a new release, update this file with:

### Version Format
```
## [X.Y.Z] - YYYY-MM-DD
```

### Categories

Use these sections as appropriate:

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security-related changes

### Example Entry

```markdown
## [1.0.0] - 2023-12-15

### Added
- Initial release with Pterodactyl Panel v1.11.6
- Initial release with Pterodactyl Wings v1.11.8
- Docker Compose configuration
- Automated version update workflow

### Fixed
- Fixed database connection issues in Panel image

### Security
- Updated PHP to 8.1 to address CVE-2023-XXXXX
```

## Version History

Releases are tagged and published at: https://github.com/HendrikTank/pterodactyl-image/releases

[Unreleased]: https://github.com/HendrikTank/pterodactyl-image/compare/v1.0.0...HEAD
