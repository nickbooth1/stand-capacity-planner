#!/bin/bash
# Reset the database - drops all data and re-initializes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "⚠️  This will delete all database data!"
read -p "Are you sure? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Resetting database..."

    # Stop containers
    docker-compose down -v

    # Remove postgres volume
    docker volume rm stand-capacity-planner_postgres_data 2>/dev/null || true

    # Restart
    docker-compose up -d --build

    echo "⏳ Waiting for database to initialize..."
    sleep 5

    echo "✅ Database reset complete!"
else
    echo "❌ Cancelled."
fi
