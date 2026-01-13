-- Stand Capacity Planner - Proper Stands Schema (REQ-1.6)
-- This migration creates the stands table according to requirements

-- Drop existing stands table (since it has incompatible schema)
DROP TABLE IF EXISTS capacity_events CASCADE;
DROP TABLE IF EXISTS capacity_plans CASCADE;
DROP TABLE IF EXISTS stands CASCADE;

-- Create enum types for stands
CREATE TYPE aircraft_code AS ENUM ('C', 'E', 'F');
CREATE TYPE contact_type AS ENUM ('Contact', 'Remote');
CREATE TYPE stand_designation AS ENUM ('Domestic', 'International', 'Swing');

-- Create stands table with REQ-1.6 compliant schema
CREATE TABLE stands (
    -- Primary identifier (not auto-increment, user-provided)
    stand_id VARCHAR(20) PRIMARY KEY,

    -- Required aircraft and dimensions
    max_aircraft_code aircraft_code NOT NULL,
    max_wingspan DECIMAL(10,2) NOT NULL CHECK (max_wingspan > 0),
    max_length DECIMAL(10,2) NOT NULL CHECK (max_length > 0),

    -- Required operational attributes
    contact_remote contact_type NOT NULL,
    terminal VARCHAR(50) NOT NULL,
    domestic_international stand_designation NOT NULL,

    -- Required operating hours (stored as TIME)
    operating_hours_start TIME NOT NULL,
    operating_hours_end TIME NOT NULL,
    CHECK (operating_hours_end > operating_hours_start),

    -- Required equipment boolean flags
    avdgs BOOLEAN NOT NULL DEFAULT false,
    fegp BOOLEAN NOT NULL DEFAULT false,
    pca BOOLEAN NOT NULL DEFAULT false,
    fuel_hydrant BOOLEAN NOT NULL DEFAULT false,

    -- Optional fields
    pier VARCHAR(50),
    jet_bridge_count INTEGER CHECK (jet_bridge_count >= 0),
    jet_bridge_type VARCHAR(50),
    notes TEXT CHECK (LENGTH(notes) <= 500),

    -- System fields
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for common queries
CREATE INDEX idx_stands_terminal ON stands(terminal);
CREATE INDEX idx_stands_max_aircraft_code ON stands(max_aircraft_code);
CREATE INDEX idx_stands_status ON stands(status);
CREATE INDEX idx_stands_contact_remote ON stands(contact_remote);

-- Create updated_at trigger for stands
CREATE TRIGGER update_stands_updated_at
    BEFORE UPDATE ON stands
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for testing (matches REQ-1.6 schema)
INSERT INTO stands (
    stand_id,
    max_aircraft_code,
    max_wingspan,
    max_length,
    contact_remote,
    terminal,
    domestic_international,
    operating_hours_start,
    operating_hours_end,
    avdgs,
    fegp,
    pca,
    fuel_hydrant,
    pier,
    jet_bridge_count,
    notes,
    status
)
VALUES
    ('01', 'F', 79.80, 76.30, 'Contact', 'Terminal 1', 'International', '06:00', '23:00', true, true, true, true, 'Pier A', 2, 'Wide-body capable stand', 'active'),
    ('02', 'E', 65.00, 63.70, 'Contact', 'Terminal 1', 'International', '06:00', '23:00', true, true, true, true, 'Pier A', 2, NULL, 'active'),
    ('03', 'E', 65.00, 63.70, 'Remote', 'Terminal 2', 'Domestic', '06:00', '23:00', true, false, true, false, NULL, 0, 'Remote stand - bus gate', 'active'),
    ('04', 'C', 39.50, 44.50, 'Contact', 'Terminal 2', 'Swing', '06:00', '23:00', true, false, false, true, 'Pier B', 1, 'Narrow-body only', 'active'),
    ('05', 'C', 39.50, 44.50, 'Contact', 'Terminal 2', 'Domestic', '06:00', '23:00', false, false, false, false, 'Pier B', 1, NULL, 'maintenance')
ON CONFLICT (stand_id) DO NOTHING;

-- Verify setup
DO $$
BEGIN
    RAISE NOTICE 'Stands schema migration (02) completed successfully!';
    RAISE NOTICE 'Total stands created: %', (SELECT COUNT(*) FROM stands);
END $$;
