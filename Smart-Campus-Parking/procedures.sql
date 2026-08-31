-- ============================================================================
-- Smart Campus Parking and Traffic Management System
-- Stored Procedures & Triggers (For JDBC CallableStatement Demonstration - CO5)
-- ============================================================================

USE campus_parking_db;

DELIMITER //

-- Procedure 1: sp_ProcessVehicleExit
-- Used by CallableStatement in ParkingSessionDAO
DROP PROCEDURE IF EXISTS sp_ProcessVehicleExit //
CREATE PROCEDURE sp_ProcessVehicleExit(
    IN  p_ticket_no VARCHAR(40),
    IN  p_payment_method VARCHAR(20),
    OUT p_duration_mins INT,
    OUT p_calculated_fee DECIMAL(8,2),
    OUT p_discount DECIMAL(8,2),
    OUT p_final_fee DECIMAL(8,2),
    OUT p_status_msg VARCHAR(100)
)
proc_label: BEGIN
    DECLARE v_session_id INT;
    DECLARE v_vehicle_id INT;
    DECLARE v_slot_id INT;
    DECLARE v_entry_time DATETIME;
    DECLARE v_exit_time DATETIME;
    DECLARE v_pass_id INT;
    DECLARE v_user_type VARCHAR(20);
    DECLARE v_vehicle_type VARCHAR(20);
    DECLARE v_base_rate DECIMAL(6,2);
    DECLARE v_hours DECIMAL(6,2);
    DECLARE v_gross_fee DECIMAL(8,2);
    DECLARE v_disc_amount DECIMAL(8,2) DEFAULT 0.00;
    DECLARE v_net_fee DECIMAL(8,2) DEFAULT 0.00;

    -- Find active session
    SELECT session_id, vehicle_id, slot_id, entry_time, pass_id
    INTO v_session_id, v_vehicle_id, v_slot_id, v_entry_time, v_pass_id
    FROM parking_sessions
    WHERE ticket_no = p_ticket_no AND status = 'Active'
    LIMIT 1;

    IF v_session_id IS NULL THEN
        SET p_duration_mins = 0;
        SET p_calculated_fee = 0.00;
        SET p_discount = 0.00;
        SET p_final_fee = 0.00;
        SET p_status_msg = 'ERROR: Active ticket not found or already closed.';
        LEAVE proc_label;
    END IF;

    SET v_exit_time = NOW();
    SET p_duration_mins = TIMESTAMPDIFF(MINUTE, v_entry_time, v_exit_time);
    IF p_duration_mins < 1 THEN
        SET p_duration_mins = 1;
    END IF;

    -- Look up vehicle and zone details
    SELECT v.vehicle_type, u.user_type, z.base_hourly_rate
    INTO v_vehicle_type, v_user_type, v_base_rate
    FROM vehicles v
    JOIN users u ON v.user_id = u.user_id
    JOIN parking_slots s ON s.slot_id = v_slot_id
    JOIN parking_zones z ON z.zone_id = s.zone_id
    WHERE v.vehicle_id = v_vehicle_id
    LIMIT 1;

    -- Calculate hours (minimum 1 hour, rounded up)
    SET v_hours = CEIL(p_duration_mins / 60.0);
    IF v_hours < 1.0 THEN
        SET v_hours = 1.0;
    END IF;

    SET v_gross_fee = v_hours * v_base_rate;

    -- Vehicle type multiplier
    IF v_vehicle_type = '2-Wheeler' THEN
        SET v_gross_fee = v_gross_fee * 0.5;
    ELSEIF v_vehicle_type = 'Bus' THEN
        SET v_gross_fee = v_gross_fee * 2.0;
    ELSEIF v_vehicle_type = 'EV' THEN
        SET v_gross_fee = v_gross_fee * 0.8; -- 20% Green discount (SDG 13)
    END IF;

    -- Active pass discount (100% covered if active valid pass exists)
    IF v_pass_id IS NOT NULL THEN
        SET v_disc_amount = v_gross_fee;
        SET v_net_fee = 0.00;
    ELSE
        -- User type discounts
        IF v_user_type = 'Faculty' THEN
            SET v_disc_amount = v_gross_fee * 0.40; -- 40% Faculty discount
        ELSEIF v_user_type = 'Student' THEN
            SET v_disc_amount = v_gross_fee * 0.25; -- 25% Student discount
        ELSEIF v_user_type = 'Staff' THEN
            SET v_disc_amount = v_gross_fee * 0.30; -- 30% Staff discount
        ELSE
            SET v_disc_amount = 0.00;
        END IF;
        SET v_net_fee = v_gross_fee - v_disc_amount;
    END IF;

    SET p_calculated_fee = v_gross_fee;
    SET p_discount = v_disc_amount;
    SET p_final_fee = v_net_fee;

    -- Update session record
    UPDATE parking_sessions
    SET exit_time = v_exit_time,
        total_duration_minutes = p_duration_mins,
        calculated_fee = p_calculated_fee,
        discount_applied = p_discount,
        final_amount = p_final_fee,
        status = 'Completed'
    WHERE session_id = v_session_id;

    -- Free up parking slot
    UPDATE parking_slots
    SET status = 'Available',
        current_vehicle_id = NULL
    WHERE slot_id = v_slot_id;

    -- Record payment if amount > 0
    IF p_final_fee > 0 THEN
        INSERT INTO payments (transaction_ref, session_id, amount, payment_method, payment_time, status)
        VALUES (CONCAT('TXN-', UNIX_TIMESTAMP(), '-', v_session_id), v_session_id, p_final_fee, p_payment_method, NOW(), 'Success');
    END IF;

    SET p_status_msg = 'SUCCESS: Vehicle exit processed and slot released.';
END //

-- Procedure 2: sp_GetZoneOccupancySummary
-- Used by CallableStatement in AnalyticsDAO
DROP PROCEDURE IF EXISTS sp_GetZoneOccupancySummary //
CREATE PROCEDURE sp_GetZoneOccupancySummary(
    IN  p_zone_code VARCHAR(10),
    OUT p_total_slots INT,
    OUT p_occupied_slots INT,
    OUT p_available_slots INT,
    OUT p_reserved_slots INT,
    OUT p_utilization_pct DECIMAL(5,2)
)
BEGIN
    DECLARE v_zone_id INT;

    SELECT zone_id, total_slots
    INTO v_zone_id, p_total_slots
    FROM parking_zones
    WHERE zone_code = p_zone_code
    LIMIT 1;

    IF v_zone_id IS NOT NULL THEN
        SELECT 
            COUNT(CASE WHEN status = 'Occupied' THEN 1 END),
            COUNT(CASE WHEN status = 'Available' THEN 1 END),
            COUNT(CASE WHEN status = 'Reserved' THEN 1 END)
        INTO p_occupied_slots, p_available_slots, p_reserved_slots
        FROM parking_slots
        WHERE zone_id = v_zone_id;

        IF p_total_slots > 0 THEN
            SET p_utilization_pct = ROUND((p_occupied_slots / p_total_slots) * 100.0, 2);
        ELSE
            SET p_utilization_pct = 0.00;
        END IF;
    ELSE
        SET p_total_slots = 0;
        SET p_occupied_slots = 0;
        SET p_available_slots = 0;
        SET p_reserved_slots = 0;
        SET p_utilization_pct = 0.00;
    END IF;
END //

-- Procedure 3: sp_IssueViolationTicket
-- Used by CallableStatement in ViolationDAO
DROP PROCEDURE IF EXISTS sp_IssueViolationTicket //
CREATE PROCEDURE sp_IssueViolationTicket(
    IN  p_plate_number VARCHAR(20),
    IN  p_slot_number VARCHAR(20),
    IN  p_violation_type VARCHAR(30),
    IN  p_fine_amount DECIMAL(8,2),
    IN  p_remarks TEXT,
    OUT p_ticket_number VARCHAR(40),
    OUT p_status_msg VARCHAR(100)
)
BEGIN
    DECLARE v_vehicle_id INT;
    DECLARE v_slot_id INT;

    SELECT vehicle_id INTO v_vehicle_id FROM vehicles WHERE plate_number = p_plate_number LIMIT 1;
    IF p_slot_number IS NOT NULL AND p_slot_number != '' THEN
        SELECT slot_id INTO v_slot_id FROM parking_slots WHERE slot_number = p_slot_number LIMIT 1;
    END IF;

    IF v_vehicle_id IS NULL THEN
        SET p_ticket_number = '';
        SET p_status_msg = 'ERROR: Vehicle with given plate number not found in registry.';
    ELSE
        SET p_ticket_number = CONCAT('VIO-', UNIX_TIMESTAMP(), '-', FLOOR(RAND() * 900 + 100));
        INSERT INTO violations (ticket_number, vehicle_id, slot_id, violation_type, fine_amount, issued_at, status, remarks)
        VALUES (p_ticket_number, v_vehicle_id, v_slot_id, p_violation_type, p_fine_amount, NOW(), 'Unpaid', p_remarks);

        SET p_status_msg = 'SUCCESS: Violation penalty issued successfully.';
    END IF;
END //

DELIMITER ;
