#!/bin/bash

# WPPConnect Local Development Startup Script
# Usage: ./start-local.sh

set -e

echo "🚀 Starting WPPConnect Local Development..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "Please start Docker Desktop and try again"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found"
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo "✅ Created .env file"
    echo "⚠️  IMPORTANT: Edit .env and set a strong SECRET_KEY"
    echo ""
fi

# Create tokens directory if it doesn't exist
if [ ! -d "tokens" ]; then
    echo "📁 Creating tokens directory..."
    mkdir -p tokens
    echo "✅ Created tokens directory"
fi

# Pull latest image
echo "📥 Pulling latest luizeof/wppconnect image..."
docker pull luizeof/wppconnect:latest

# Stop existing container if running
if [ "$(docker ps -q -f name=wppconnect-local)" ]; then
    echo "🛑 Stopping existing container..."
    docker stop wppconnect-local
fi

# Remove old container
if [ "$(docker ps -aq -f name=wppconnect-local)" ]; then
    echo "🗑️  Removing old container..."
    docker rm wppconnect-local
fi

# Start services
echo "🐳 Starting WPPConnect container..."
docker-compose -f docker-compose.local.yml up -d

echo ""
echo "✅ WPPConnect is starting up!"
echo ""
echo "📊 View logs:"
echo "   docker-compose -f docker-compose.local.yml logs -f"
echo ""
echo "🌐 Access API Documentation:"
echo "   http://localhost:21465/api-docs"
echo ""
echo "❤️  Health Check:"
echo "   http://localhost:21465/api/health"
echo ""
echo "🛑 Stop server:"
echo "   docker-compose -f docker-compose.local.yml down"
echo ""
echo "⏳ Waiting for server to be ready..."

# Wait for health check
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:21465/api/health > /dev/null 2>&1; then
        echo ""
        echo "✅ Server is ready!"
        echo "🎉 Open http://localhost:21465/api-docs in your browser"
        exit 0
    fi
    attempt=$((attempt + 1))
    echo -n "."
    sleep 2
done

echo ""
echo "⚠️  Server health check timeout after 60 seconds"
echo "Check logs with: docker-compose -f docker-compose.local.yml logs"
