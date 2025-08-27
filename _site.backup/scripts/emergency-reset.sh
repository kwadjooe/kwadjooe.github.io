#!/bin/bash
# Emergency reset script for Jekyll Portfolio ONLY
# This script is PROJECT-SPECIFIC and will not affect other Docker containers

set -e

# Get the project directory name for safety
PROJECT_DIR=$(basename "$(pwd)")
COMPOSE_PROJECT_NAME="jekyll-portfolio"

echo "🚨 Emergency Docker Reset for Jekyll Portfolio"
echo "📁 Working in: $(pwd)"
echo "🔒 This will ONLY affect containers/images/volumes related to THIS project"
echo ""
echo "Will remove:"
echo "  - Containers with names containing: jekyll-portfolio, jekyll-dev, jekyll-prod, jekyll-utils"
echo "  - Images built by this project's docker-compose"
echo "  - Volumes: jekyll-portfolio_*"
echo ""
echo "✅ OTHER Docker projects will NOT be affected"

# Prompt for confirmation
read -p "Proceed with PROJECT-SPECIFIC reset? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo "🛑 Stopping THIS project's containers only..."
docker-compose --profile dev down --remove-orphans 2>/dev/null || true
docker-compose --profile prod down --remove-orphans 2>/dev/null || true
docker-compose --profile utils down --remove-orphans 2>/dev/null || true

echo "🗑️  Removing THIS project's containers only..."
# Remove only containers from this specific project
CONTAINERS_TO_REMOVE=$(docker ps -aq --filter "name=jekyll-portfolio" --filter "name=jekyll-dev" --filter "name=jekyll-prod" --filter "name=jekyll-utils" --filter "name=jekyll-build" --filter "name=jekyll-nginx" 2>/dev/null || true)

if [ -n "$CONTAINERS_TO_REMOVE" ]; then
    echo "Found containers to remove: $CONTAINERS_TO_REMOVE"
    docker rm -f $CONTAINERS_TO_REMOVE
else
    echo "No project-specific containers found to remove"
fi

echo "🖼️  Removing THIS project's images only..."
# Remove only images built by this project (using compose project name)
PROJECT_IMAGES=$(docker images --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}" -q 2>/dev/null || true)

if [ -n "$PROJECT_IMAGES" ]; then
    echo "Found project images to remove: $PROJECT_IMAGES"
    docker rmi -f $PROJECT_IMAGES
else
    echo "No project-specific images found to remove"
fi

# Also check for any images built from this directory
CURRENT_DIR_IMAGES=$(docker images --filter "reference=jekyll-portfolio*" -q 2>/dev/null || true)
if [ -n "$CURRENT_DIR_IMAGES" ]; then
    echo "Found directory-specific images to remove: $CURRENT_DIR_IMAGES"
    docker rmi -f $CURRENT_DIR_IMAGES
fi

echo "💾 Removing THIS project's volumes only..."
# Remove only project-specific volumes (using exact names)
PROJECT_VOLUMES=$(docker volume ls --filter "name=jekyll-portfolio_" -q 2>/dev/null || true)

if [ -n "$PROJECT_VOLUMES" ]; then
    echo "Found project volumes to remove: $PROJECT_VOLUMES"
    docker volume rm $PROJECT_VOLUMES 2>/dev/null || true
else
    echo "No project-specific volumes found to remove"
fi

# Remove individual volumes by exact name (safer)
docker volume rm jekyll-portfolio_jekyll-cache 2>/dev/null || true
docker volume rm jekyll-portfolio_jekyll-site 2>/dev/null || true
docker volume rm jekyll-portfolio_jekyll-site-prod 2>/dev/null || true
docker volume rm jekyll-portfolio_bundle-cache 2>/dev/null || true

echo "🔍 Checking Docker health..."
docker version >/dev/null && echo "✅ Docker daemon is healthy" || echo "❌ Docker daemon issues detected"

echo ""
echo "📊 Docker status after cleanup:"
echo "Total containers: $(docker ps -aq | wc -l)"
echo "Total images: $(docker images -q | wc -l)"
echo "Total volumes: $(docker volume ls -q | wc -l)"

echo ""
echo "🔨 Rebuilding THIS project from scratch..."
echo "This may take a few minutes..."

# Build fresh without any cache
if ! docker-compose --profile dev build --no-cache --pull; then
    echo "❌ Build failed. Check the error messages above."
    exit 1
fi

echo "🚀 Starting development environment..."
if ! docker-compose --profile dev up -d; then
    echo "❌ Failed to start containers. Check the error messages above."
    exit 1
fi

echo ""
echo "✅ PROJECT-SPECIFIC emergency reset completed!"
echo "🌐 Your site should be available at: http://localhost:4000"
echo "📊 Check status: docker-compose --profile dev ps"
echo "📋 View logs: docker-compose --profile dev logs -f"
echo ""
echo "🔒 Other Docker projects were NOT affected by this reset."