#!/bin/bash

# WordPress + OpenHalo Demo Start Script
# This script helps you quickly start and verify the demo

set -e

echo "======================================"
echo "WordPress + OpenHalo Demo Setup"
echo "======================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Use appropriate docker-compose command
DOCKER_COMPOSE="docker-compose"
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Stop any existing containers
echo "🧹 Cleaning up any existing containers..."
$DOCKER_COMPOSE down 2>/dev/null || true
echo ""

# Start the services
echo "🚀 Starting services..."
echo "   This may take a few minutes on first run (building OpenHalo)..."
$DOCKER_COMPOSE up -d --build

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 5

# Wait for services to be healthy
MAX_WAIT=120
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if $DOCKER_COMPOSE ps | grep -q "healthy"; then
        echo "✅ Services are starting up..."
        break
    fi
    sleep 5
    ELAPSED=$((ELAPSED + 5))
    echo "   Still waiting... ($ELAPSED/$MAX_WAIT seconds)"
done

echo ""
echo "======================================"
echo "📊 Service Status"
echo "======================================"
$DOCKER_COMPOSE ps
echo ""

# Check PostgreSQL
echo "======================================"
echo "🔍 Verifying PostgreSQL..."
echo "======================================"
if $DOCKER_COMPOSE exec -T postgres pg_isready -U wordpress &> /dev/null; then
    echo "✅ PostgreSQL is ready"
    $DOCKER_COMPOSE exec -T postgres psql -U wordpress -d wordpress -c "SELECT version();" 2>/dev/null | head -n 3
else
    echo "⚠️  PostgreSQL is not ready yet. It may need more time."
fi
echo ""

# Check OpenHalo
echo "======================================"
echo "🔍 Verifying OpenHalo..."
echo "======================================"
if $DOCKER_COMPOSE ps | grep -q "openhalo.*healthy"; then
    echo "✅ OpenHalo is running"
    echo "   MySQL protocol available on port 3306"
else
    echo "⚠️  OpenHalo is starting up. Check logs with:"
    echo "   $DOCKER_COMPOSE logs openhalo"
fi
echo ""

# Check WordPress
echo "======================================"
echo "🔍 Verifying WordPress..."
echo "======================================"
if $DOCKER_COMPOSE ps | grep -q "wordpress.*Up"; then
    echo "✅ WordPress is running"
else
    echo "⚠️  WordPress is starting up..."
fi
echo ""

# Display access information
echo "======================================"
echo "🎉 Demo is Ready!"
echo "======================================"
echo ""
echo "📱 Access Points:"
echo "   WordPress:  http://localhost:8080"
echo "   PostgreSQL: localhost:5432"
echo "   OpenHalo:   localhost:3306 (MySQL protocol)"
echo ""
echo "📖 Next Steps:"
echo "   1. Open http://localhost:8080 in your browser"
echo "   2. Follow the WordPress installation wizard"
echo "   3. See DEMO.md for detailed demonstration steps"
echo "   4. See CONCLUSION.md for findings and conclusions"
echo ""
echo "🔧 Useful Commands:"
echo "   View logs:        $DOCKER_COMPOSE logs -f"
echo "   Stop services:    $DOCKER_COMPOSE stop"
echo "   Remove all:       $DOCKER_COMPOSE down -v"
echo "   Restart services: $DOCKER_COMPOSE restart"
echo ""
echo "📚 Documentation:"
echo "   README.md     - Complete setup guide"
echo "   DEMO.md       - Step-by-step demonstration"
echo "   CONCLUSION.md - Test results and findings"
echo ""
echo "======================================"

# Check if port 8080 is accessible
sleep 3
if command -v curl &> /dev/null; then
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|302"; then
        echo "✅ WordPress is accessible at http://localhost:8080"
    else
        echo "⏳ WordPress is still starting up. Please wait a moment and try accessing http://localhost:8080"
    fi
fi

echo ""
echo "Happy testing! 🚀"
