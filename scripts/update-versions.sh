#!/bin/bash
set -e

# Script to update Pterodactyl component versions in various files
# Usage: update-versions.sh <component> <version>
# Example: update-versions.sh panel 1.11.5

COMPONENT=$1
VERSION=$2

if [ -z "$COMPONENT" ] || [ -z "$VERSION" ]; then
    echo "Usage: $0 <component> <version>"
    echo "Components: panel, wings"
    exit 1
fi

# Remove 'v' prefix if present
VERSION="${VERSION#v}"

echo "📝 Updating ${COMPONENT} to version ${VERSION}..."

update_panel_version() {
    local version=$1
    
    # Update panel/Dockerfile
    if [ -f "panel/Dockerfile" ]; then
        echo "   Updating panel/Dockerfile..."
        sed -i "s/ARG PANEL_VERSION=.*/ARG PANEL_VERSION=${version}/" panel/Dockerfile
        sed -i "s/ENV PANEL_VERSION=.*/ENV PANEL_VERSION=${version}/" panel/Dockerfile
    fi
    
    # Update panel/.env
    if [ -f "panel/.env" ]; then
        echo "   Updating panel/.env..."
        sed -i "s/PANEL_VERSION=.*/PANEL_VERSION=${version}/" panel/.env
    fi
    
    # Update root .env
    if [ -f ".env" ]; then
        echo "   Updating .env..."
        sed -i "s/PANEL_VERSION=.*/PANEL_VERSION=${version}/" .env
    fi
    
    # Update docker-compose.yml
    if [ -f "docker-compose.yml" ]; then
        echo "   Updating docker-compose.yml..."
        sed -i "s/PANEL_VERSION: .*/PANEL_VERSION: \"${version}\"/" docker-compose.yml
    fi
    
    # Update README.md
    if [ -f "README.md" ]; then
        echo "   Updating README.md..."
        # Update version badges or references
        sed -i "s/panel-v[0-9]\+\.[0-9]\+\.[0-9]\+/panel-v${version}/g" README.md
        sed -i "s/Panel v[0-9]\+\.[0-9]\+\.[0-9]\+/Panel v${version}/g" README.md
        sed -i "s/Panel: [0-9]\+\.[0-9]\+\.[0-9]\+/Panel: ${version}/g" README.md
    fi
}

update_wings_version() {
    local version=$1
    
    # Update wings/Dockerfile
    if [ -f "wings/Dockerfile" ]; then
        echo "   Updating wings/Dockerfile..."
        sed -i "s/ARG WINGS_VERSION=.*/ARG WINGS_VERSION=${version}/" wings/Dockerfile
        sed -i "s/ENV WINGS_VERSION=.*/ENV WINGS_VERSION=${version}/" wings/Dockerfile
        # Update download URL
        sed -i "s|github.com/pterodactyl/wings/releases/download/v[0-9]\+\.[0-9]\+\.[0-9]\+/|github.com/pterodactyl/wings/releases/download/v${version}/|g" wings/Dockerfile
    fi
    
    # Update wings/.env
    if [ -f "wings/.env" ]; then
        echo "   Updating wings/.env..."
        sed -i "s/WINGS_VERSION=.*/WINGS_VERSION=${version}/" wings/.env
    fi
    
    # Update root .env
    if [ -f ".env" ]; then
        echo "   Updating .env..."
        sed -i "s/WINGS_VERSION=.*/WINGS_VERSION=${version}/" .env
    fi
    
    # Update docker-compose.yml
    if [ -f "docker-compose.yml" ]; then
        echo "   Updating docker-compose.yml..."
        sed -i "s/WINGS_VERSION: .*/WINGS_VERSION: \"${version}\"/" docker-compose.yml
    fi
    
    # Update README.md
    if [ -f "README.md" ]; then
        echo "   Updating README.md..."
        # Update version badges or references
        sed -i "s/wings-v[0-9]\+\.[0-9]\+\.[0-9]\+/wings-v${version}/g" README.md
        sed -i "s/Wings v[0-9]\+\.[0-9]\+\.[0-9]\+/Wings v${version}/g" README.md
        sed -i "s/Wings: [0-9]\+\.[0-9]\+\.[0-9]\+/Wings: ${version}/g" README.md
    fi
}

case $COMPONENT in
    panel)
        update_panel_version "$VERSION"
        echo "✅ Panel version updated to ${VERSION}"
        ;;
    wings)
        update_wings_version "$VERSION"
        echo "✅ Wings version updated to ${VERSION}"
        ;;
    *)
        echo "❌ Unknown component: ${COMPONENT}"
        echo "Valid components: panel, wings"
        exit 1
        ;;
esac

# Show what files were modified
echo ""
echo "📋 Modified files:"
git status --short 2>/dev/null || echo "   (git status unavailable)"
