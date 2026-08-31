-- ============================================================================
-- Smart Campus Parking and Traffic Management System
-- Database Schema (DDL)
-- Course: CSA09 - Programming in Java
-- SDG Mapping: SDG 9 (Infrastructure), SDG 11 (Sustainable Cities), SDG 13 (Climate Action)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS campus_parking_db;
USE campus_parking_db;

-- 1. Table: users
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    user_type ENUM('Student', 'Faculty', 'Staff', 'Visitor', 'Vendor') NOT NULL DEFAULT 'Student',
    department VARCHAR(80) DEFAULT 'General',
    status ENUM('Active', 'Suspended', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_type (user_type),
    INDEX idx_email (email)
) ENGINE=InnoDB;

-- 2. Table: vehicles
CREATE TABLE IF NOT EXISTS vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plate_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type ENUM('2-Wheeler', 'Car', 'EV', 'Bus') NOT NULL DEFAULT 'Car',
    make_model VARCHAR(100) DEFAULT 'Standard',
    color VARCHAR(30) DEFAULT 'Black',
    is_ev BOOLEAN GENERATED ALWAYS AS (vehicle_type = 'EV') STORED,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_plate_number (plate_number),
    INDEX idx_vehicle_type (vehicle_type)
) ENGINE=InnoDB;

-- 3. Table: parking_zones
CREATE TABLE IF NOT EXISTS parking_zones (
    zone_id INT AUTO_INCREMENT PRIMARY KEY,
    zone_code VARCHAR(10) NOT NULL UNIQUE,
    zone_name VARCHAR(80) NOT NULL,
    allowed_user_type VARCHAR(100) NOT NULL DEFAULT 'All',
    total_slots INT NOT NULL DEFAULT 20,
    base_hourly_rate DECIMAL(6,2) NOT NULL DEFAULT 20.00,
    is_ev_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. Table: parking_slots
CREATE TABLE IF NOT EXISTS parking_slots (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    zone_id INT NOT NULL,
    slot_number VARCHAR(20) NOT NULL UNIQUE,
    slot_type ENUM('Standard', 'EV', 'Accessible', 'Reserved') NOT NULL DEFAULT 'Standard',
    status ENUM('Available', 'Occupied', 'Reserved', 'Maintenance') NOT NULL DEFAULT 'Available',
    floor_level INT DEFAULT 1,
    current_vehicle_id INT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (zone_id) REFERENCES parking_zones(zone_id) ON DELETE CASCADE,
    FOREIGN KEY (current_vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE SET NULL,
    INDEX idx_zone_status (zone_id, status),
    INDEX idx_slot_status (status)
) ENGINE=InnoDB;

-- 5. Table: parking_passes
CREATE TABLE IF NOT EXISTS parking_passes (
    pass_id INT AUTO_INCREMENT PRIMARY KEY,
    pass_number VARCHAR(30) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    zone_id INT NOT NULL,
    pass_type ENUM('Daily', 'Monthly', 'Semester', 'Annual') NOT NULL,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    pass_fee DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    status ENUM('Active', 'Expired', 'Suspended') DEFAULT 'Active',
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (zone_id) REFERENCES parking_zones(zone_id) ON DELETE CASCADE,
    INDEX idx_pass_number (pass_number),
    INDEX idx_pass_status (status)
) ENGINE=InnoDB;

-- 6. Table: reservations
CREATE TABLE IF NOT EXISTS reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_ref VARCHAR(30) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    slot_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status ENUM('Pending', 'Active', 'Completed', 'Cancelled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (slot_id) REFERENCES parking_slots(slot_id) ON DELETE CASCADE,
    INDEX idx_booking_ref (booking_ref),
    INDEX idx_res_status (status)
) ENGINE=InnoDB;

-- 7. Table: parking_sessions
CREATE TABLE IF NOT EXISTS parking_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_no VARCHAR(40) NOT NULL UNIQUE,
    vehicle_id INT NOT NULL,
    slot_id INT NOT NULL,
    entry_time DATETIME NOT NULL,
    exit_time DATETIME NULL,
    total_duration_minutes INT DEFAULT 0,
    calculated_fee DECIMAL(8,2) DEFAULT 0.00,
    discount_applied DECIMAL(8,2) DEFAULT 0.00,
    final_amount DECIMAL(8,2) DEFAULT 0.00,
    pass_id INT NULL,
    status ENUM('Active', 'Completed') DEFAULT 'Active',
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (slot_id) REFERENCES parking_slots(slot_id) ON DELETE CASCADE,
    FOREIGN KEY (pass_id) REFERENCES parking_passes(pass_id) ON DELETE SET NULL,
    INDEX idx_ticket_no (ticket_no),
    INDEX idx_session_status (status),
    INDEX idx_entry_time (entry_time)
) ENGINE=InnoDB;

-- 8. Table: payments
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_ref VARCHAR(40) NOT NULL UNIQUE,
    session_id INT NULL,
    pass_id INT NULL,
    amount DECIMAL(8,2) NOT NULL,
    payment_method ENUM('Cash', 'Card', 'UPI', 'CampusCard') NOT NULL DEFAULT 'UPI',
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Success', 'Failed', 'Refunded') DEFAULT 'Success',
    FOREIGN KEY (session_id) REFERENCES parking_sessions(session_id) ON DELETE SET NULL,
    FOREIGN KEY (pass_id) REFERENCES parking_passes(pass_id) ON DELETE SET NULL,
    INDEX idx_payment_time (payment_time)
) ENGINE=InnoDB;

-- 9. Table: violations
CREATE TABLE IF NOT EXISTS violations (
    violation_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(40) NOT NULL UNIQUE,
    vehicle_id INT NOT NULL,
    slot_id INT NULL,
    violation_type ENUM('Overstay', 'Unauthorized_Zone', 'No_Pass', 'Illegal_Parking', 'Speeding') NOT NULL,
    fine_amount DECIMAL(8,2) NOT NULL DEFAULT 500.00,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Unpaid', 'Paid', 'Waived') DEFAULT 'Unpaid',
    remarks TEXT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (slot_id) REFERENCES parking_slots(slot_id) ON DELETE SET NULL,
    INDEX idx_violation_status (status)
) ENGINE=InnoDB;

-- ============================================================================
-- SQL Views for Analytics and Statement Queries (CO5)
-- ============================================================================

CREATE OR REPLACE VIEW view_zone_occupancy AS
SELECT 
    z.zone_id,
    z.zone_code,
    z.zone_name,
    z.allowed_user_type,
    z.total_slots,
    COUNT(CASE WHEN s.status = 'Occupied' THEN 1 END) AS occupied_slots,
    COUNT(CASE WHEN s.status = 'Reserved' THEN 1 END) AS reserved_slots,
    COUNT(CASE WHEN s.status = 'Available' THEN 1 END) AS available_slots,
    COUNT(CASE WHEN s.status = 'Maintenance' THEN 1 END) AS maintenance_slots,
    ROUND((COUNT(CASE WHEN s.status = 'Occupied' THEN 1 END) / z.total_slots) * 100, 1) AS occupancy_rate_pct
FROM parking_zones z
LEFT JOIN parking_slots s ON z.zone_id = s.zone_id
GROUP BY z.zone_id, z.zone_code, z.zone_name, z.allowed_user_type, z.total_slots;

CREATE OR REPLACE VIEW view_daily_revenue_summary AS
SELECT 
    DATE(payment_time) AS payment_date,
    payment_method,
    COUNT(payment_id) AS total_transactions,
    SUM(amount) AS total_revenue
FROM payments
WHERE status = 'Success'
GROUP BY DATE(payment_time), payment_method;
