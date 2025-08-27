#!/bin/bash
# Development server script

set -e

echo "🐳 Starting Jekyll development server with Docker..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Function to handle Docker errors (PROJECT-SPECIFIC)
handle_docker_error() {
    echo "❌ Docker error detected. Attempting to fix..."
    echo "🧹 Cleaning up corrupted containers (THIS PROJECT ONLY)..."
    
    # Stop any running containers for this project
    docker-compose --profile dev down --remove-orphans 2>/dev/null || true
    
    # Remove stale containers ONLY from this project
    PROJECT_CONTAINERS=$(docker ps -aq --filter "name=jekyll-portfolio" --filter "name=jekyll-dev" 2>/dev/null || true)
    if [ -n "$PROJECT_CONTAINERS" ]; then
        echo "Removing project containers: $PROJECT_CONTAINERS"
        docker rm -f $PROJECT_CONTAINERS
    fi
    
    echo "🔨 Rebuilding with clean slate (project-specific)..."
    docker-compose --profile dev build --no-cache --pull
}

# Attempt to build and start development container
echo "📦 Building development container..."

if ! docker-compose --profile dev up --build; then
    echo ""
    echo "🚨 Build failed! This might be due to corrupted Docker state."
    echo "🔧 Attempting automatic fix..."
    
    handle_docker_error
    
    echo "🔄 Retrying with clean build..."
    if ! docker-compose --profile dev up; then
        echo ""
        echo "❌ Automatic fix failed. Manual intervention required."
        echo "🆘 Try running: ./scripts/emergency-reset.sh"
        exit 1
    fi
fi

echo ""
echo "🚀 Jekyll development server is running at:"
echo "   📱 Local:   http://localhost:4000"
echo "   🔄 LiveReload: Enabled"
echo ""
echo "📝 Your site content is mounted as volumes - changes will be reflected immediately!"
echo "⏹️  Press Ctrl+C to stop the server"