#!/bin/bash
# Stop all Docker containers for Stand Capacity Planner

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "🛑 Stopping Stand Capacity Planner..."

docker-compose down

echo "✅ All services stopped."
