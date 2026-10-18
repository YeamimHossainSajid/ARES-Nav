-- ============================================================================
-- NASA Space Apps Challenge: Interplanetary Survival Guide (Martian Map)
-- Database Initialization: PostGIS 16 Setup for Mars 2000 Coordinate System
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- ----------------------------------------------------------------------------
-- Simulation Mode Schema: Player Deployed Infrastructure & Assets
-- Coordinate System: Mars IAU-2000 Sphere (Equator radius 3396190m)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS deployed_infrastructure (
    id VARCHAR(64) PRIMARY KEY,
    owner_id VARCHAR(64) NOT NULL,
    structure_type VARCHAR(32) NOT NULL, -- 'HABITAT_DOME', 'SOLAR_ARRAY', 'COMM_TOWER', 'REFINERY'
    name VARCHAR(128) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    elevation DOUBLE PRECISION NOT NULL, -- Elevation in meters relative to MOLA datum
    measured_slope DOUBLE PRECISION NOT NULL, -- Terrain slope angle at deployment site (deg)
    status VARCHAR(32) NOT NULL, -- 'NOMINAL', 'MAINTENANCE_REQUIRED', 'OFFLINE'
    health_percentage DOUBLE PRECISION DEFAULT 100.0,
    power_output_kw DOUBLE PRECISION DEFAULT 0.0,
    power_consumption_kw DOUBLE PRECISION DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spatial index on coordinates (using PostGIS geometry point)
ALTER TABLE deployed_infrastructure 
    ADD COLUMN IF NOT EXISTS geom geometry(Point, 4326);

UPDATE deployed_infrastructure 
    SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326) 
    WHERE geom IS NULL;

CREATE INDEX IF NOT EXISTS idx_infrastructure_geom 
    ON deployed_infrastructure USING GIST (geom);

-- ----------------------------------------------------------------------------
-- Simulation Mode: Mobile Rover Units
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS simulation_rovers (
    id VARCHAR(64) PRIMARY KEY,
    owner_id VARCHAR(64) NOT NULL,
    callsign VARCHAR(64) NOT NULL,
    rover_model VARCHAR(32) NOT NULL, -- 'CHARIOT_EX', 'SCOUT_MK2', 'HEAVY_HAULER'
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    heading_degrees DOUBLE PRECISION NOT NULL,
    speed_mps DOUBLE PRECISION NOT NULL,
    battery_percentage DOUBLE PRECISION DEFAULT 100.0,
    status VARCHAR(32) NOT NULL,
    geom geometry(Point, 4326),
    last_ping TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_simulation_rovers_geom 
    ON simulation_rovers USING GIST (geom);

-- ----------------------------------------------------------------------------
-- Observation Mode (Read-Only Cache): Real Marsquake Events (InSight SEIS)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS marsquake_events (
    event_id VARCHAR(64) PRIMARY KEY,
    sol INTEGER NOT NULL,
    utc_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    magnitude DOUBLE PRECISION NOT NULL,
    quality_class VARCHAR(4) NOT NULL, -- 'A', 'B', 'C', 'D'
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    depth_km DOUBLE PRECISION,
    description TEXT,
    geom geometry(Point, 4326)
);

CREATE INDEX IF NOT EXISTS idx_marsquake_geom 
    ON marsquake_events USING GIST (geom);
