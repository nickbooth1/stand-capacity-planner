#!/bin/bash
# Check status of all services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "📊 Stand Capacity Planner - Service Status"
echo ""

# Docker container status
echo "🐳 Docker Containers:"
docker-compose ps
echo ""

# Health checks
echo "🏥 Health Checks:"

# Backend
if curl -s http://localhost:3002/api/health > /dev/null 2>&1; then
    HEALTH=$(curl -s http://localhost:3002/api/health)
    echo "  ✅ Backend: Running"
    echo "     Response: $HEALTH"
else
    echo "  ❌ Backend: Not responding"
fi

# Frontend
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "  ✅ Frontend: Running"
else
    echo "  ❌ Frontend: Not responding"
fi

# Database
if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "  ✅ Database: Ready"
else
    echo "  ❌ Database: Not ready"
fi

echo ""
echo "📍 Access Points:"
echo "   Frontend:  http://localhost:3000"
echo "   Backend:   http://localhost:3002"
echo "   Database:  localhost:5432"
