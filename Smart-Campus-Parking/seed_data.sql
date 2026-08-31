-- ============================================================================
-- Smart Campus Parking and Traffic Management System
-- Seed Data (Realistic University Campus Environment)
-- ============================================================================

USE campus_parking_db;

-- 1. Insert Zones
INSERT INTO parking_zones (zone_id, zone_code, zone_name, allowed_user_type, total_slots, base_hourly_rate, is_ev_enabled) VALUES
(1, 'Z-STU', 'Student Parking Zone A', 'Student', 12, 15.00, FALSE),
(2, 'Z-FAC', 'Faculty Reserved Zone B', 'Faculty', 10, 25.00, TRUE),
(3, 'Z-STF', 'Staff Administrative Zone C', 'Staff', 8, 20.00, FALSE),
(4, 'Z-VIS', 'Campus Visitor Gate 1 Zone', 'Visitor', 8, 30.00, FALSE),
(5, 'Z-SRV', 'Service & Delivery Logistics Zone', 'Vendor', 6, 20.00, FALSE),
(6, 'Z-EVP', 'Green EV Fast-Charging Station', 'All', 8, 18.00, TRUE)
ON DUPLICATE KEY UPDATE zone_name=VALUES(zone_name);

-- 2. Insert Users
INSERT INTO users (user_id, full_name, email, phone, user_type, department, status) VALUES
(1, 'Dr. Aris Thorne', 'a.thorne@campus.edu', '+91 98451 22341', 'Faculty', 'Computer Science & Eng', 'Active'),
(2, 'Prof. Elena Rostova', 'e.rostova@campus.edu', '+91 98452 33452', 'Faculty', 'Electronics & Comm', 'Active'),
(3, 'Rohan Kumar Verma', 'rohan.v@student.campus.edu', '+91 91234 56789', 'Student', 'B.Tech Information Tech', 'Active'),
(4, 'Ananya Sen', 'ananya.s@student.campus.edu', '+91 91234 98765', 'Student', 'B.Tech Mechanical Eng', 'Active'),
(5, 'Venkatesh Iyer', 'v.iyer@campus.edu', '+91 97890 12345', 'Staff', 'Campus Administration', 'Active'),
(6, 'Sumanth Patel', 's.patel@campus.edu', '+91 97890 67890', 'Staff', 'Library & Research Center', 'Active'),
(7, 'David Miller', 'david.miller@guest.com', '+91 99988 77665', 'Visitor', 'External Auditor', 'Active'),
(8, 'Vikram Malhotra', 'vikram@campus.edu', '+91 98877 66554', 'Faculty', 'Civil Engineering', 'Active'),
(9, 'Pooja Hegde', 'p.hegde@student.campus.edu', '+91 94433 22110', 'Student', 'B.Tech Computer Science', 'Active'),
(10, 'Campus Express Logistics', 'logistics@speedcourier.in', '+91 90011 22334', 'Vendor', 'University Facilities', 'Active')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name);

-- 3. Insert Vehicles
INSERT INTO vehicles (vehicle_id, user_id, plate_number, vehicle_type, make_model, color) VALUES
(1, 1, 'KA-01-MJ-2024', 'Car', 'Honda City i-VTEC', 'Silver Metallic'),
(2, 2, 'KA-03-EV-8899', 'EV', 'Tata Nexon EV Max', 'Teal Blue'),
(3, 3, 'KA-05-AB-1234', '2-Wheeler', 'Yamaha FZ-S', 'Midnight Black'),
(4, 4, 'KA-51-CD-5678', 'Car', 'Hyundai i20 Asta', 'Polar White'),
(5, 5, 'KA-04-XY-9012', 'Car', 'Maruti Suzuki Dzire', 'Magma Grey'),
(6, 6, 'KA-02-KL-3456', '2-Wheeler', 'Honda Activa 6G', 'Pearl White'),
(7, 7, 'MH-12-PQ-7788', 'Car', 'Toyota Innova Crysta', 'Super White'),
(8, 8, 'KA-01-EV-4411', 'EV', 'MG ZS EV Excite', 'Caspian Blue'),
(9, 9, 'KA-05-ZT-9900', '2-Wheeler', 'Royal Enfield Hunter 350', 'Rebel Red'),
(10, 10, 'KA-01-LG-1122', 'Bus', 'Ashok Leyland Logistics', 'Canary Yellow')
ON DUPLICATE KEY UPDATE plate_number=VALUES(plate_number);

-- 4. Insert Parking Slots for each Zone
INSERT INTO parking_slots (slot_id, zone_id, slot_number, slot_type, status, floor_level, current_vehicle_id) VALUES
-- Student Zone (Z-STU)
(1, 1, 'STU-101', 'Standard', 'Occupied', 1, 3),
(2, 1, 'STU-102', 'Standard', 'Available', 1, NULL),
(3, 1, 'STU-103', 'Standard', 'Available', 1, NULL),
(4, 1, 'STU-104', 'Standard', 'Occupied', 1, 4),
(5, 1, 'STU-105', 'Standard', 'Reserved', 1, NULL),
(6, 1, 'STU-106', 'Standard', 'Available', 1, NULL),
(7, 1, 'STU-107', 'Standard', 'Available', 1, NULL),
(8, 1, 'STU-108', 'Standard', 'Available', 1, NULL),
(9, 1, 'STU-109', 'Standard', 'Maintenance', 1, NULL),
(10, 1, 'STU-110', 'Standard', 'Available', 1, NULL),
(11, 1, 'STU-111', 'Standard', 'Available', 1, NULL),
(12, 1, 'STU-112', 'Standard', 'Occupied', 1, 9),

-- Faculty Zone (Z-FAC)
(13, 2, 'FAC-201', 'Reserved', 'Occupied', 2, 1),
(14, 2, 'FAC-202', 'EV', 'Occupied', 2, 2),
(15, 2, 'FAC-203', 'Reserved', 'Available', 2, NULL),
(16, 2, 'FAC-204', 'Standard', 'Available', 2, NULL),
(17, 2, 'FAC-205', 'Accessible', 'Available', 2, NULL),
(18, 2, 'FAC-206', 'Standard', 'Available', 2, NULL),
(19, 2, 'FAC-207', 'Standard', 'Available', 2, NULL),
(20, 2, 'FAC-208', 'Standard', 'Reserved', 2, NULL),
(21, 2, 'FAC-209', 'Standard', 'Available', 2, NULL),
(22, 2, 'FAC-210', 'Standard', 'Available', 2, NULL),

-- Staff Zone (Z-STF)
(23, 3, 'STF-301', 'Standard', 'Occupied', 1, 5),
(24, 3, 'STF-302', 'Standard', 'Occupied', 1, 6),
(25, 3, 'STF-303', 'Standard', 'Available', 1, NULL),
(26, 3, 'STF-304', 'Accessible', 'Available', 1, NULL),
(27, 3, 'STF-305', 'Standard', 'Available', 1, NULL),
(28, 3, 'STF-306', 'Standard', 'Available', 1, NULL),
(29, 3, 'STF-307', 'Standard', 'Available', 1, NULL),
(30, 3, 'STF-308', 'Standard', 'Available', 1, NULL),

-- Visitor Zone (Z-VIS)
(31, 4, 'VIS-401', 'Standard', 'Occupied', 1, 7),
(32, 4, 'VIS-402', 'Standard', 'Available', 1, NULL),
(33, 4, 'VIS-403', 'Standard', 'Available', 1, NULL),
(34, 4, 'VIS-404', 'Standard', 'Available', 1, NULL),
(35, 4, 'VIS-405', 'Accessible', 'Available', 1, NULL),
(36, 4, 'VIS-406', 'Standard', 'Available', 1, NULL),
(37, 4, 'VIS-407', 'Standard', 'Available', 1, NULL),
(38, 4, 'VIS-408', 'Standard', 'Available', 1, NULL),

-- Service Logistics Zone (Z-SRV)
(39, 5, 'SRV-501', 'Standard', 'Occupied', 1, 10),
(40, 5, 'SRV-502', 'Standard', 'Available', 1, NULL),
(41, 5, 'SRV-503', 'Standard', 'Available', 1, NULL),
(42, 5, 'SRV-504', 'Standard', 'Available', 1, NULL),
(43, 5, 'SRV-505', 'Standard', 'Available', 1, NULL),
(44, 5, 'SRV-506', 'Standard', 'Maintenance', 1, NULL),

-- EV Charging Hub (Z-EVP)
(45, 6, 'EVP-601', 'EV', 'Occupied', 1, 8),
(46, 6, 'EVP-602', 'EV', 'Available', 1, NULL),
(47, 6, 'EVP-603', 'EV', 'Available', 1, NULL),
(48, 6, 'EVP-604', 'EV', 'Available', 1, NULL),
(49, 6, 'EVP-605', 'EV', 'Available', 1, NULL),
(50, 6, 'EVP-606', 'EV', 'Available', 1, NULL),
(51, 6, 'EVP-607', 'EV', 'Available', 1, NULL),
(52, 6, 'EVP-608', 'EV', 'Available', 1, NULL)
ON DUPLICATE KEY UPDATE slot_number=VALUES(slot_number);

-- 5. Parking Passes
INSERT INTO parking_passes (pass_id, pass_number, user_id, vehicle_id, zone_id, pass_type, valid_from, valid_until, pass_fee, status) VALUES
(1, 'PASS-FAC-2026-001', 1, 1, 2, 'Annual', '2026-01-01', '2026-12-31', 2500.00, 'Active'),
(2, 'PASS-FAC-2026-002', 2, 2, 2, 'Annual', '2026-01-01', '2026-12-31', 2000.00, 'Active'),
(3, 'PASS-STU-2026-101', 3, 3, 1, 'Semester', '2026-07-01', '2026-12-31', 600.00, 'Active'),
(4, 'PASS-STF-2026-301', 5, 5, 3, 'Annual', '2026-01-01', '2026-12-31', 1800.00, 'Active')
ON DUPLICATE KEY UPDATE pass_number=VALUES(pass_number);

-- 6. Reservations
INSERT INTO reservations (reservation_id, booking_ref, user_id, vehicle_id, slot_id, start_time, end_time, status) VALUES
(1, 'RES-20260831-01', 1, 1, 13, '2026-08-31 08:30:00', '2026-08-31 17:30:00', 'Active'),
(2, 'RES-20260831-02', 8, 8, 20, '2026-08-31 10:00:00', '2026-08-31 16:00:00', 'Pending'),
(3, 'RES-20260831-03', 4, 4, 5, '2026-08-31 09:00:00', '2026-08-31 14:00:00', 'Pending')
ON DUPLICATE KEY UPDATE booking_ref=VALUES(booking_ref);

-- 7. Parking Sessions (Active and Past)
INSERT INTO parking_sessions (session_id, ticket_no, vehicle_id, slot_id, entry_time, exit_time, total_duration_minutes, calculated_fee, discount_applied, final_amount, pass_id, status) VALUES
(1, 'TCK-20260831-1001', 1, 13, '2026-08-31 08:45:00', NULL, 0, 0.00, 0.00, 0.00, 1, 'Active'),
(2, 'TCK-20260831-1002', 2, 14, '2026-08-31 09:00:00', NULL, 0, 0.00, 0.00, 0.00, 2, 'Active'),
(3, 'TCK-20260831-1003', 3, 1, '2026-08-31 09:15:00', NULL, 0, 0.00, 0.00, 0.00, 3, 'Active'),
(4, 'TCK-20260831-1004', 4, 4, '2026-08-31 09:30:00', NULL, 0, 0.00, 0.00, 0.00, NULL, 'Active'),
(5, 'TCK-20260831-1005', 5, 23, '2026-08-31 08:00:00', NULL, 0, 0.00, 0.00, 0.00, 4, 'Active'),
(6, 'TCK-20260831-1006', 6, 24, '2026-08-31 08:15:00', NULL, 0, 0.00, 0.00, 0.00, NULL, 'Active'),
(7, 'TCK-20260831-1007', 7, 31, '2026-08-31 10:00:00', NULL, 0, 0.00, 0.00, 0.00, NULL, 'Active'),
(8, 'TCK-20260831-1008', 8, 45, '2026-08-31 09:45:00', NULL, 0, 0.00, 0.00, 0.00, NULL, 'Active'),
(9, 'TCK-20260831-1009', 9, 12, '2026-08-31 10:30:00', NULL, 0, 0.00, 0.00, 0.00, NULL, 'Active'),
(10, 'TCK-20260831-1010', 10, 39, '2026-08-31 07:30:00', NULL, 0, 0.00, 0.00, 0.00, NULL, 'Active'),
-- Past completed sessions for analytics
(11, 'TCK-20260830-0901', 4, 4, '2026-08-30 09:00:00', '2026-08-30 13:30:00', 270, 75.00, 18.75, 56.25, NULL, 'Completed'),
(12, 'TCK-20260830-0902', 7, 31, '2026-08-30 10:15:00', '2026-08-30 14:45:00', 270, 150.00, 0.00, 150.00, NULL, 'Completed'),
(13, 'TCK-20260830-0903', 8, 45, '2026-08-30 08:30:00', '2026-08-30 11:30:00', 180, 43.20, 0.00, 43.20, NULL, 'Completed')
ON DUPLICATE KEY UPDATE ticket_no=VALUES(ticket_no);

-- 8. Payments
INSERT INTO payments (payment_id, transaction_ref, session_id, pass_id, amount, payment_method, payment_time, status) VALUES
(1, 'TXN-PASS-001', NULL, 1, 2500.00, 'UPI', '2026-01-01 10:00:00', 'Success'),
(2, 'TXN-PASS-002', NULL, 2, 2000.00, 'Card', '2026-01-01 10:30:00', 'Success'),
(3, 'TXN-PASS-003', NULL, 3, 600.00, 'CampusCard', '2026-07-01 11:00:00', 'Success'),
(4, 'TXN-PASS-004', NULL, 4, 1800.00, 'UPI', '2026-01-01 12:00:00', 'Success'),
(5, 'TXN-SES-11', 11, NULL, 56.25, 'UPI', '2026-08-30 13:30:00', 'Success'),
(6, 'TXN-SES-12', 12, NULL, 150.00, 'Card', '2026-08-30 14:45:00', 'Success'),
(7, 'TXN-SES-13', 13, NULL, 43.20, 'UPI', '2026-08-30 11:30:00', 'Success')
ON DUPLICATE KEY UPDATE transaction_ref=VALUES(transaction_ref);

-- 9. Violations
INSERT INTO violations (violation_id, ticket_number, vehicle_id, slot_id, violation_type, fine_amount, issued_at, status, remarks) VALUES
(1, 'VIO-20260829-01', 7, 15, 'Unauthorized_Zone', 500.00, '2026-08-29 11:15:00', 'Paid', 'Visitor parked in Faculty Reserved Zone B without permit.'),
(2, 'VIO-20260830-02', 3, 46, 'Illegal_Parking', 300.00, '2026-08-30 14:20:00', 'Unpaid', 'Non-EV 2-wheeler parked obstructing EV Fast-Charging spot.'),
(3, 'VIO-20260831-03', 4, 4, 'Overstay', 250.00, '2026-08-31 16:30:00', 'Unpaid', 'Vehicle parked beyond scheduled reservation window.')
ON DUPLICATE KEY UPDATE ticket_number=VALUES(ticket_number);
