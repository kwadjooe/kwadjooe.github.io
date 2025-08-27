#!/bin/bash
# Debug script for Jekyll Portfolio development
# PROJECT-SPECIFIC: Only affects Jekyll Portfolio containers

set -e

echo "🐛 Jekyll Portfolio Debug Tool"
echo "📁 Working in: $(pwd)"
echo ""

# Function to show usage
show_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  logs        - View container logs"
    echo "  health      - Check container health"
    echo "  inspect     - Inspect container configuration"
    echo "  shell       - Open shell in running container"
    echo "  build-log   - View build logs"
    echo "  test-site   - Test site connectivity"
    echo "  clean       - Clean development environment"
    echo ""
    echo "Examples:"
    echo "  $0 logs"
    echo "  $0 health"
    echo "  $0 test-site"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Main script logic
case "$1" in
    "logs")
        check_docker
        echo "📋 Viewing container logs (last 50 lines)..."
        docker-compose --profile dev logs --tail=50 -f jekyll-dev
        ;;
    
    "health")
        check_docker
        echo "🏥 Checking container health..."
        
        # Check if container is running
        if docker ps --format "{{.Names}}" | grep -q "jekyll-portfolio-dev"; then
            echo "✅ Container is running"
            
            # Check health status
            HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' jekyll-portfolio-dev 2>/dev/null || echo "no-healthcheck")
            echo "🏥 Health status: $HEALTH_STATUS"
            
            # Test connectivity
            echo "🌐 Testing site connectivity..."
            if curl -f http://localhost:4000/ >/dev/null 2>&1; then
                echo "✅ Site is accessible at http://localhost:4000"
            else
                echo "❌ Site is not accessible"
            fi
            
            # Show port status
            echo "🔌 Port status:"
            docker port jekyll-portfolio-dev
            
        else
            echo "❌ Container is not running"
            echo "💡 Start it with: ./scripts/dev.sh"
        fi
        ;;
    
    "inspect")
        check_docker
        echo "🔍 Inspecting container configuration..."
        if docker ps --format "{{.Names}}" | grep -q "jekyll-portfolio-dev"; then
            docker inspect jekyll-portfolio-dev | jq '.[] | {
                Name: .Name,
                State: .State.Status,
                Ports: .NetworkSettings.Ports,
                Mounts: .Mounts
            }'
        else
            echo "❌ Container is not running"
        fi
        ;;
    
    "shell")
        check_docker
        if docker ps --format "{{.Names}}" | grep -q "jekyll-portfolio-dev"; then
            echo "🐚 Opening shell in running container..."
            docker exec -it jekyll-portfolio-dev sh
        else
            echo "❌ Container is not running"
            echo "💡 Start it with: ./scripts/dev.sh"
        fi
        ;;
    
    "build-log")
        check_docker
        echo "🔨 Viewing build logs..."
        docker-compose --profile dev build --no-cache
        ;;
    
    "test-site")
        check_docker
        echo "🧪 Testing site..."
        echo ""
        echo "1. Testing main site..."
        curl -I http://localhost:4000/ 2>/dev/null && echo "✅ Main site responsive" || echo "❌ Main site not responding"
        
        echo "2. Testing navigation pages..."
        for page in "categories" "tags" "archives" "about"; do
            curl -I http://localhost:4000/$page/ 2>/dev/null && echo "✅ /$page/ responsive" || echo "❌ /$page/ not responding"
        done
        
        echo "3. Testing assets..."
        curl -I http://localhost:4000/assets/img/avatar.png 2>/dev/null && echo "✅ Avatar loading" || echo "❌ Avatar not loading"
        ;;
    
    "clean")
        check_docker
        echo "🧹 Cleaning development environment..."
        echo "This will remove containers, images, and volumes for THIS project only"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose --profile dev down -v
            docker system prune -f
            echo "✅ Environment cleaned"
        else
            echo "Cancelled"
        fi
        ;;
    
    *)
        show_usage
        exit 1
        ;;
esac