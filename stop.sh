#!/bin/bash
# Stop script for FailSafe Dashboard

cd "$(dirname "$0")"

echo "🛑 Stopping FailSafe Dashboard services..."
docker-compose down

echo ""
echo "✅ All services stopped."
echo ""
echo "💡 To remove all data (including database):"
echo "   docker-compose down -v"
echo ""
