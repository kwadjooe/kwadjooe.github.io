#!/bin/bash
# Production build script

set -e

echo "🐳 Building Jekyll site for production..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build production container and site
echo "📦 Building production container..."
docker-compose --profile prod build

echo "🏗️  Building site..."
docker-compose --profile prod run --rm jekyll-prod bundle exec jekyll build

echo "✅ Production build completed!"
echo "📁 Site built in _site/ directory"
echo "🌐 You can serve the _site directory with any static file server"