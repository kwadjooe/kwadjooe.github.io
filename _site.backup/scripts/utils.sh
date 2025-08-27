#!/bin/bash
# Utility script for Jekyll commands
# PROJECT-SPECIFIC: Only affects Jekyll Portfolio containers

set -e

# Function to show usage
show_usage() {
    echo "🛠️  Jekyll Portfolio Utility Script"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  shell     - Open interactive shell in container"
    echo "  install   - Install/update gems"
    echo "  clean     - Clean Jekyll cache and build files"
    echo "  new-post  - Create a new blog post"
    echo "  test      - Run site tests"
    echo "  deps      - Show dependency information"
    echo ""
    echo "Examples:"
    echo "  $0 shell"
    echo "  $0 new-post \"My New Post Title\""
    echo "  $0 clean"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Execute command in utils container
run_utils() {
    docker-compose --profile utils run --rm jekyll-utils "$@"
}

# Main script logic
case "$1" in
    "shell")
        check_docker
        echo "🐳 Opening interactive shell in Jekyll container..."
        run_utils sh
        ;;
    
    "install")
        check_docker
        echo "💎 Installing/updating gems..."
        run_utils bundle install
        echo "✅ Gems updated successfully!"
        ;;
    
    "clean")
        check_docker
        echo "🧹 Cleaning Jekyll cache and build files..."
        run_utils bundle exec jekyll clean
        run_utils rm -rf .jekyll-cache
        echo "✅ Clean completed!"
        ;;
    
    "new-post")
        if [ -z "$2" ]; then
            echo "❌ Please provide a post title"
            echo "Usage: $0 new-post \"Your Post Title\""
            exit 1
        fi
        
        check_docker
        POST_TITLE="$2"
        POST_DATE=$(date +%Y-%m-%d)
        POST_FILENAME="_posts/${POST_DATE}-$(echo "$POST_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g').md"
        
        echo "📝 Creating new post: $POST_FILENAME"
        
        cat > "$POST_FILENAME" << EOF
---
title: "$POST_TITLE"
date: $(date '+%Y-%m-%d %H:%M:%S %z')
categories: [Blog]
tags: [draft]
---

# $POST_TITLE

Write your post content here...

## Introduction

## Main Content

## Conclusion
EOF
        
        echo "✅ New post created: $POST_FILENAME"
        echo "📝 Edit the file to add your content"
        ;;
    
    "test")
        check_docker
        echo "🧪 Running site tests..."
        run_utils bundle exec jekyll build
        run_utils bundle exec htmlproofer ./_site --disable-external
        echo "✅ Tests completed!"
        ;;
    
    "deps")
        check_docker
        echo "💎 Dependency information:"
        run_utils bundle list
        ;;
    
    *)
        show_usage
        exit 1
        ;;
esac