#!/bin/bash
# E2E Validation Script - Validates application health before/after builds

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

MODE="${1:-pre}"  # pre or post

echo "🔍 E2E Validation ($MODE-build check)..."
echo ""

ERRORS=0

# Check if containers are running
echo "1. Checking container status..."
if ! docker-compose ps | grep -q "Up"; then
    echo "   ❌ Containers are not running"
    ERRORS=$((ERRORS + 1))
else
    echo "   ✅ Containers are running"
fi

# Check database connection
echo "2. Checking database connection..."
if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "   ✅ Database is accepting connections"

    # Verify tables exist
    TABLE_COUNT=$(docker-compose exec -T postgres psql -U postgres -d stand_capacity -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
    if [ "$TABLE_COUNT" -gt 0 ]; then
        echo "   ✅ Database has $TABLE_COUNT tables"
    else
        echo "   ❌ No tables found in database"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "   ❌ Database is not ready"
    ERRORS=$((ERRORS + 1))
fi

# Check backend API
echo "3. Checking backend API..."
if curl -s http://localhost:3002/api/health > /dev/null 2>&1; then
    HEALTH=$(curl -s http://localhost:3002/api/health)
    DB_STATUS=$(echo "$HEALTH" | grep -o '"database":"[^"]*"' | cut -d'"' -f4)

    if [ "$DB_STATUS" = "connected" ]; then
        echo "   ✅ Backend API is healthy (database connected)"
    else
        echo "   ⚠️  Backend API running but database: $DB_STATUS"
    fi
else
    echo "   ❌ Backend API not responding"
    ERRORS=$((ERRORS + 1))
fi

# Check frontend
echo "4. Checking frontend..."
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "   ✅ Frontend is responding"
else
    echo "   ❌ Frontend not responding"
    ERRORS=$((ERRORS + 1))
fi

# Check API endpoints
echo "5. Checking API endpoints..."
for endpoint in "/api" "/api/health" "/api/stands"; do
    if curl -s "http://localhost:3002${endpoint}" > /dev/null 2>&1; then
        echo "   ✅ GET ${endpoint}"
    else
        echo "   ❌ GET ${endpoint}"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ E2E Validation PASSED - All systems operational"
    exit 0
else
    echo "❌ E2E Validation FAILED - $ERRORS error(s) found"
    exit 1
fi
