#!/bin/bash
# Start all Docker containers for Stand Capacity Planner

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "🚀 Starting Stand Capacity Planner..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Build and start containers
echo "📦 Building and starting containers..."
docker-compose up -d --build

echo ""
echo "⏳ Waiting for services to be ready..."

# Wait for postgres
echo "  - Waiting for PostgreSQL..."
until docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
    sleep 1
done
echo "  ✅ PostgreSQL is ready"

# Wait for backend
echo "  - Waiting for Backend API..."
until curl -s http://localhost:3001/api/health > /dev/null 2>&1; do
    sleep 1
done
echo "  ✅ Backend API is ready"

# Wait for frontend
echo "  - Waiting for Frontend..."
sleep 5  # Next.js takes a moment to compile
echo "  ✅ Frontend is ready"

echo ""
echo "✅ All services are running!"
echo ""
echo "📍 Access Points:"
echo "   Frontend:  http://localhost:3000"
echo "   Backend:   http://localhost:3001"
echo "   Database:  localhost:5432 (stand_capacity)"
echo ""
echo "📋 Useful Commands:"
echo "   View logs:     docker-compose logs -f"
echo "   Stop:          ./scripts/stop.sh"
echo "   Reset DB:      ./scripts/reset-db.sh"
echo "   Run tests:     ./scripts/test.sh"
