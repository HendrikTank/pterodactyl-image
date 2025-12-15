#!/bin/bash
set -e

# Script to check for Pterodactyl Panel and Wings updates
# Compares current versions with latest releases from GitHub

echo "🔍 Checking for Pterodactyl updates..."

# Function to get the latest release tag from GitHub
get_latest_release() {
    local repo=$1
    local latest=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name // empty')
    
    if [ -z "$latest" ]; then
        echo "Warning: Could not fetch latest release for ${repo}" >&2
        echo ""
    else
        # Remove 'v' prefix if present
        echo "${latest#v}"
    fi
}

# Function to get current version from files
get_current_version() {
    local component=$1
    local version=""
    
    case $component in
        panel)
            # Check panel/.env or .env for PANEL_VERSION
            if [ -f "panel/.env" ]; then
                version=$(grep -E "^PANEL_VERSION=" panel/.env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
            elif [ -f ".env" ]; then
                version=$(grep -E "^PANEL_VERSION=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
            fi
            
            # Check Dockerfile if .env not found
            if [ -z "$version" ] && [ -f "panel/Dockerfile" ]; then
                version=$(grep -E "ARG PANEL_VERSION=" panel/Dockerfile | cut -d'=' -f2 | tr -d '"' | tr -d "'")
            fi
            ;;
        wings)
            # Check wings/.env or .env for WINGS_VERSION
            if [ -f "wings/.env" ]; then
                version=$(grep -E "^WINGS_VERSION=" wings/.env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
            elif [ -f ".env" ]; then
                version=$(grep -E "^WINGS_VERSION=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
            fi
            
            # Check Dockerfile if .env not found
            if [ -z "$version" ] && [ -f "wings/Dockerfile" ]; then
                version=$(grep -E "ARG WINGS_VERSION=" wings/Dockerfile | cut -d'=' -f2 | tr -d '"' | tr -d "'")
            fi
            ;;
    esac
    
    echo "$version"
}

# Function to compare versions
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# Check Panel updates
echo "📦 Checking Pterodactyl Panel..."
PANEL_CURRENT=$(get_current_version "panel")
PANEL_LATEST=$(get_latest_release "pterodactyl/panel")

if [ -z "$PANEL_LATEST" ]; then
    echo "⚠️  Could not fetch Panel latest version"
    PANEL_UPDATE_AVAILABLE="false"
elif [ -z "$PANEL_CURRENT" ]; then
    echo "ℹ️  No current Panel version found (new installation)"
    echo "   Latest available: v${PANEL_LATEST}"
    PANEL_UPDATE_AVAILABLE="true"
elif version_gt "$PANEL_LATEST" "$PANEL_CURRENT"; then
    echo "✨ Panel update available: v${PANEL_CURRENT} → v${PANEL_LATEST}"
    PANEL_UPDATE_AVAILABLE="true"
else
    echo "✅ Panel is up to date (v${PANEL_CURRENT})"
    PANEL_UPDATE_AVAILABLE="false"
fi

# Check Wings updates
echo ""
echo "🪽 Checking Pterodactyl Wings..."
WINGS_CURRENT=$(get_current_version "wings")
WINGS_LATEST=$(get_latest_release "pterodactyl/wings")

if [ -z "$WINGS_LATEST" ]; then
    echo "⚠️  Could not fetch Wings latest version"
    WINGS_UPDATE_AVAILABLE="false"
elif [ -z "$WINGS_CURRENT" ]; then
    echo "ℹ️  No current Wings version found (new installation)"
    echo "   Latest available: v${WINGS_LATEST}"
    WINGS_UPDATE_AVAILABLE="true"
elif version_gt "$WINGS_LATEST" "$WINGS_CURRENT"; then
    echo "✨ Wings update available: v${WINGS_CURRENT} → v${WINGS_LATEST}"
    WINGS_UPDATE_AVAILABLE="true"
else
    echo "✅ Wings is up to date (v${WINGS_CURRENT})"
    WINGS_UPDATE_AVAILABLE="false"
fi

# Output results for GitHub Actions
echo ""
echo "📊 Summary:"
echo "   Panel: ${PANEL_UPDATE_AVAILABLE} (latest: ${PANEL_LATEST:-unknown})"
echo "   Wings: ${WINGS_UPDATE_AVAILABLE} (latest: ${WINGS_LATEST:-unknown})"

# Set GitHub Actions output variables
if [ -n "$GITHUB_OUTPUT" ]; then
    echo "panel-update-available=${PANEL_UPDATE_AVAILABLE}" >> $GITHUB_OUTPUT
    echo "wings-update-available=${WINGS_UPDATE_AVAILABLE}" >> $GITHUB_OUTPUT
    echo "panel-latest-version=${PANEL_LATEST}" >> $GITHUB_OUTPUT
    echo "wings-latest-version=${WINGS_LATEST}" >> $GITHUB_OUTPUT
fi
