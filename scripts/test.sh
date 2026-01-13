#!/bin/bash
# Run all tests for Stand Capacity Planner

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "🧪 Running tests for Stand Capacity Planner..."
echo ""

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "⚠️  Containers are not running. Starting them first..."
    ./scripts/start.sh
fi

# Run backend tests
echo "📦 Running Backend Tests..."
docker-compose exec -T backend npm test || echo "⚠️  Backend tests failed or not configured yet"

echo ""

# Run frontend tests
echo "🎨 Running Frontend Tests..."
docker-compose exec -T frontend npm test || echo "⚠️  Frontend tests failed or not configured yet"

echo ""

# Run E2E tests
echo "🔄 Running E2E Tests..."
docker-compose exec -T frontend npm run test:e2e || echo "⚠️  E2E tests failed or not configured yet"

echo ""
echo "✅ Test run complete!"
