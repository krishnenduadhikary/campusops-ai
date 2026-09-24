-- ================================================
-- CampusOps AI — Complete Database Schema
-- Day 3 | Version 1.0
-- ================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- 1. DEPARTMENTS
-- ================================================
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    contact_email VARCHAR(150),
    contact_phone VARCHAR(20),
    sla_hours_low INTEGER DEFAULT 48,
    sla_hours_medium INTEGER DEFAULT 24,
    sla_hours_high INTEGER DEFAULT 8,
    sla_hours_critical INTEGER DEFAULT 2,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 2. USERS
-- ================================================
CREATE TYPE user_role AS ENUM (
    'STUDENT',
    'TECHNICIAN',
    'SUPERVISOR',
    'ADMIN'
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'STUDENT',
    department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    phone VARCHAR(20),
    student_id VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 3. LOCATIONS
-- ================================================
CREATE TYPE location_type AS ENUM (
    'CLASSROOM',
    'LABORATORY',
    'HOSTEL',
    'OFFICE',
    'CANTEEN',
    'LIBRARY',
    'GARDEN',
    'PARKING',
    'CORRIDOR',
    'WASHROOM',
    'OTHER'
);

CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    building VARCHAR(100) NOT NULL,
    floor VARCHAR(20),
    room VARCHAR(50),
    location_type location_type DEFAULT 'OTHER',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 4. ASSETS
-- ================================================
CREATE TYPE asset_status AS ENUM (
    'WORKING',
    'UNDER_MAINTENANCE',
    'BROKEN',
    'REPLACED',
    'DISPOSED'
);

CREATE TABLE assets (
    id SERIAL PRIMARY KEY,
    asset_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    location_id INTEGER REFERENCES locations(id) ON DELETE SET NULL,
    department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    purchase_date DATE,
    warranty_end DATE,
    status asset_status DEFAULT 'WORKING',
    last_maintenance DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 5. TICKETS
-- ================================================
CREATE TYPE ticket_status AS ENUM (
    'OPEN',
    'AI_PROCESSED',
    'ASSIGNED',
    'ACCEPTED',
    'IN_PROGRESS',
    'RESOLVED',
    'CLOSED',
    'CANCELLED',
    'REJECTED',
    'ESCALATED'
);

CREATE TYPE ticket_priority AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);

CREATE TYPE ticket_category AS ENUM (
    'IT',
    'ELECTRICAL',
    'PLUMBING',
    'CIVIL',
    'HOUSEKEEPING',
    'SECURITY',
    'CANTEEN',
    'HORTICULTURE',
    'OTHER'
);

CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    ticket_number VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category ticket_category,
    priority ticket_priority DEFAULT 'MEDIUM',
    status ticket_status DEFAULT 'OPEN',

    -- Reporter
    reported_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

    -- Location & Asset
    location_id INTEGER REFERENCES locations(id) ON DELETE SET NULL,
    asset_id INTEGER REFERENCES assets(id) ON DELETE SET NULL,

    -- Assignment
    assigned_department INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    assigned_to INTEGER REFERENCES users(id) ON DELETE SET NULL,

    -- AI fields
    ai_category ticket_category,
    ai_category_confidence FLOAT,
    ai_priority ticket_priority,
    ai_priority_confidence FLOAT,
    ai_processed_at TIMESTAMP,

    -- Duplicate detection
    is_duplicate BOOLEAN DEFAULT FALSE,
    duplicate_of INTEGER REFERENCES tickets(id) ON DELETE SET NULL,
    duplicate_similarity FLOAT,

    -- Image
    image_path VARCHAR(500),

    -- SLA
    due_at TIMESTAMP,
    escalation_level INTEGER DEFAULT 0,

    -- Resolution
    resolution_notes TEXT,
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 6. TICKET HISTORY
-- ================================================
CREATE TABLE ticket_history (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    old_status ticket_status,
    new_status ticket_status NOT NULL,
    changed_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    comment TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 7. NOTIFICATIONS
-- ================================================
CREATE TYPE notification_channel AS ENUM (
    'EMAIL',
    'TELEGRAM',
    'WHATSAPP',
    'IN_APP'
);

CREATE TYPE notification_status AS ENUM (
    'PENDING',
    'SENT',
    'FAILED'
);

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    ticket_id INTEGER REFERENCES tickets(id) ON DELETE CASCADE,
    channel notification_channel NOT NULL,
    message TEXT NOT NULL,
    status notification_status DEFAULT 'PENDING',
    sent_at TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 8. FEEDBACK
-- ================================================
CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER NOT NULL UNIQUE REFERENCES tickets(id) ON DELETE CASCADE,
    given_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 9. AUDIT LOGS
-- ================================================
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id INTEGER,
    old_value JSONB,
    new_value JSONB,
    ip_address VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- INDEXES (for performance)
-- ================================================
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_priority ON tickets(priority);
CREATE INDEX idx_tickets_category ON tickets(category);
CREATE INDEX idx_tickets_reported_by ON tickets(reported_by);
CREATE INDEX idx_tickets_assigned_to ON tickets(assigned_to);
CREATE INDEX idx_tickets_assigned_department ON tickets(assigned_department);
CREATE INDEX idx_tickets_created_at ON tickets(created_at);
CREATE INDEX idx_ticket_history_ticket_id ON ticket_history(ticket_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity);

-- ================================================
-- SEED DATA — 8 Departments
-- ================================================
INSERT INTO departments 
    (name, description, contact_email, contact_phone, 
     sla_hours_low, sla_hours_medium, sla_hours_high, sla_hours_critical)
VALUES
    ('IT & Network', 
     'Handles WiFi, computers, projectors, servers and printers',
     'it@campus.edu', '9800000001',
     48, 24, 4, 2),

    ('Electrical', 
     'Handles lights, fans, AC, power sockets, generator and wiring',
     'electrical@campus.edu', '9800000002',
     48, 24, 4, 1),

    ('Plumbing', 
     'Handles water leaks, taps, toilets, drainage and water supply',
     'plumbing@campus.edu', '9800000003',
     48, 24, 6, 2),

    ('Civil & Infrastructure', 
     'Handles wall cracks, broken doors/windows, floor and roof damage',
     'civil@campus.edu', '9800000004',
     48, 24, 8, 4),

    ('Housekeeping', 
     'Handles cleaning, garbage, pest control and washroom hygiene',
     'housekeeping@campus.edu', '9800000005',
     48, 12, 4, 3),

    ('Security', 
     'Handles gate, CCTV, access control and suspicious activity',
     'security@campus.edu', '9800000006',
     24, 12, 2, 1),

    ('Canteen & Mess', 
     'Handles food quality, hygiene, equipment and water filters',
     'canteen@campus.edu', '9800000007',
     48, 24, 4, 2),

    ('Horticulture', 
     'Handles garden, plants, outdoor areas and fallen trees',
     'horticulture@campus.edu', '9800000008',
     48, 24, 8, 4);

-- ================================================
-- SEED DATA — Locations
-- ================================================
INSERT INTO locations (building, floor, room, location_type) VALUES
    ('Main Building', 'Ground Floor', 'Room 101', 'CLASSROOM'),
    ('Main Building', 'Ground Floor', 'Room 102', 'CLASSROOM'),
    ('Main Building', '1st Floor', 'Room 201', 'CLASSROOM'),
    ('Main Building', '1st Floor', 'Room 204', 'CLASSROOM'),
    ('Main Building', '2nd Floor', 'Room 301', 'CLASSROOM'),
    ('Computer Lab Block', 'Ground Floor', 'Lab 1', 'LABORATORY'),
    ('Computer Lab Block', 'Ground Floor', 'Lab 2', 'LABORATORY'),
    ('Computer Lab Block', '1st Floor', 'Lab 3', 'LABORATORY'),
    ('Science Block', 'Ground Floor', 'Physics Lab', 'LABORATORY'),
    ('Science Block', '1st Floor', 'Chemistry Lab', 'LABORATORY'),
    ('Hostel Block A', 'Ground Floor', 'Common Room', 'HOSTEL'),
    ('Hostel Block A', '1st Floor', 'Room A-101', 'HOSTEL'),
    ('Hostel Block B', 'Ground Floor', 'Common Room', 'HOSTEL'),
    ('Hostel Block B', '2nd Floor', 'Room B-201', 'HOSTEL'),
    ('Admin Block', 'Ground Floor', 'Principal Office', 'OFFICE'),
    ('Library', 'Ground Floor', 'Reading Hall', 'LIBRARY'),
    ('Canteen', 'Ground Floor', 'Main Canteen', 'CANTEEN'),
    ('Campus Ground', NULL, 'Main Gate', 'OTHER'),
    ('Campus Ground', NULL, 'Parking Area', 'PARKING'),
    ('Campus Ground', NULL, 'Garden Area', 'GARDEN');

-- ================================================
-- SEED DATA — Admin User
-- (password: Admin@123 — change in production)
-- ================================================
INSERT INTO users (name, email, password_hash, role, phone)
VALUES (
    'Campus Admin',
    'admin@campus.edu',
    '$2b$12$placeholder_hash_change_this',
    'ADMIN',
    '9800000000'
);

-- ================================================
-- Done!
-- ================================================
SELECT 'CampusOps AI Database Schema Created Successfully!' AS message;
SELECT COUNT(*) AS total_departments FROM departments;
SELECT COUNT(*) AS total_locations FROM locations;
