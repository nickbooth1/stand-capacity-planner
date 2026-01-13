#!/bin/bash
# View logs for all or specific services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

SERVICE="${1:-}"

if [ -z "$SERVICE" ]; then
    echo "📋 Viewing all logs (Ctrl+C to exit)..."
    docker-compose logs -f
else
    echo "📋 Viewing logs for $SERVICE (Ctrl+C to exit)..."
    docker-compose logs -f "$SERVICE"
fi
