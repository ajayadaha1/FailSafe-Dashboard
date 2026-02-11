#!/bin/bash
# Startup script for FailSafe Dashboard multi-website hosting

set -e

echo "🚀 Starting FailSafe Dashboard..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose is not installed."
    exit 1
fi

# Navigate to project directory
cd "$(dirname "$0")"

echo "📦 Building and starting containers..."
docker-compose up -d --build

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "🔍 Checking service status..."
docker-compose ps

echo ""
echo "✅ Setup complete!"
echo ""
echo "🌐 Your websites are now accessible at:"
echo "   • http://localhost/                    - Static landing page"
echo "   • http://localhost/silicon-trace/      - Silicon Trace Dashboard"
echo "   • http://localhost/api/                - FastAPI Backend"
echo "   • http://localhost/api/docs            - API Documentation"
echo ""
echo "📋 Useful commands:"
echo "   • View logs:        docker-compose logs -f"
echo "   • Stop services:    docker-compose down"
echo "   • Restart:          docker-compose restart"
echo "   • Rebuild:          docker-compose up -d --build"
echo ""
echo "💡 To access via domain, configure DNS:"
echo "   failsafe.amd.com  A  $(hostname -I | awk '{print $1}')"
echo ""
