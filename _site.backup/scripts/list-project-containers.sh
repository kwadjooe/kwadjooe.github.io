#!/bin/bash
# List containers, images, and volumes for THIS PROJECT ONLY
# Safe diagnostic script that doesn't modify anything

echo "🔍 Jekyll Portfolio Project Docker Resources"
echo "📁 Working in: $(pwd)"
echo ""

echo "📦 PROJECT CONTAINERS:"
PROJECT_CONTAINERS=$(docker ps -a --filter "name=jekyll-portfolio" --filter "name=jekyll-dev" --filter "name=jekyll-prod" --filter "name=jekyll-utils" --filter "name=jekyll-build" --filter "name=jekyll-nginx" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null || true)

if [ -n "$PROJECT_CONTAINERS" ]; then
    echo "$PROJECT_CONTAINERS"
else
    echo "No project containers found"
fi

echo ""
echo "🖼️  PROJECT IMAGES:"
PROJECT_IMAGES=$(docker images --filter "label=com.docker.compose.project=jekyll-portfolio" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || true)
CURRENT_DIR_IMAGES=$(docker images --filter "reference=jekyll-portfolio*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || true)

if [ -n "$PROJECT_IMAGES" ]; then
    echo "Compose-built images:"
    echo "$PROJECT_IMAGES"
fi

if [ -n "$CURRENT_DIR_IMAGES" ]; then
    echo "Directory-specific images:"
    echo "$CURRENT_DIR_IMAGES"
fi

if [ -z "$PROJECT_IMAGES" ] && [ -z "$CURRENT_DIR_IMAGES" ]; then
    echo "No project images found"
fi

echo ""
echo "💾 PROJECT VOLUMES:"
PROJECT_VOLUMES=$(docker volume ls --filter "name=jekyll-portfolio_" --format "table {{.Name}}\t{{.Driver}}" 2>/dev/null || true)

if [ -n "$PROJECT_VOLUMES" ]; then
    echo "$PROJECT_VOLUMES"
else
    echo "No project volumes found"
fi

echo ""
echo "📊 TOTAL DOCKER RESOURCES ON SYSTEM:"
echo "All containers: $(docker ps -aq | wc -l)"
echo "All images: $(docker images -q | wc -l)"
echo "All volumes: $(docker volume ls -q | wc -l)"

echo ""
echo "✅ This diagnostic shows ONLY resources that would be affected by project scripts"
echo "🔒 Other Docker projects are completely separate and safe"