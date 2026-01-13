-- Stand Capacity Planner - Database Initialization
-- This script runs automatically when PostgreSQL container starts

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create stands table
CREATE TABLE IF NOT EXISTS stands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    max_capacity INTEGER NOT NULL DEFAULT 0,
    current_capacity INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create capacity_plans table
CREATE TABLE IF NOT EXISTS capacity_plans (
    id SERIAL PRIMARY KEY,
    stand_id INTEGER REFERENCES stands(id) ON DELETE CASCADE,
    planned_date DATE NOT NULL,
    planned_capacity INTEGER NOT NULL,
    actual_capacity INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create events table for tracking capacity changes
CREATE TABLE IF NOT EXISTS capacity_events (
    id SERIAL PRIMARY KEY,
    stand_id INTEGER REFERENCES stands(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    capacity_change INTEGER NOT NULL,
    previous_capacity INTEGER,
    new_capacity INTEGER,
    event_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_stands_status ON stands(status);
CREATE INDEX IF NOT EXISTS idx_capacity_plans_stand_date ON capacity_plans(stand_id, planned_date);
CREATE INDEX IF NOT EXISTS idx_capacity_events_stand ON capacity_events(stand_id);
CREATE INDEX IF NOT EXISTS idx_capacity_events_timestamp ON capacity_events(event_timestamp);

-- Insert sample data for testing
INSERT INTO stands (name, location, max_capacity, current_capacity, status)
VALUES
    ('Stand A', 'North Section', 500, 0, 'active'),
    ('Stand B', 'South Section', 750, 0, 'active'),
    ('Stand C', 'East Section', 600, 0, 'active'),
    ('Stand D', 'West Section', 400, 0, 'maintenance')
ON CONFLICT DO NOTHING;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables
DROP TRIGGER IF EXISTS update_stands_updated_at ON stands;
CREATE TRIGGER update_stands_updated_at
    BEFORE UPDATE ON stands
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_capacity_plans_updated_at ON capacity_plans;
CREATE TRIGGER update_capacity_plans_updated_at
    BEFORE UPDATE ON capacity_plans
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Verify setup
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully!';
END $$;
