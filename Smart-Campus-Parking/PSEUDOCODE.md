# Pseudo-Code Specification: Smart Campus Parking and Traffic Management System

**Course Code & Name:** CSA09 - Programming in Java  
**Course Outcomes:** CO4 (GUI, AWT/Swing, Event Handling, Menus, Layouts) & CO5 (JDBC Connectivity, SQL CRUD, Statement, PreparedStatement, CallableStatement)  
**Bloom's Taxonomy:** Level 3 (Apply) & Level 4 (Analyse)  
**SDG Alignment:** SDG 9 (Infrastructure), SDG 11 (Sustainable Cities), SDG 13 (Climate Action)  

---

## 1. System Initialization & Database Handshake Pseudo-Code

```plaintext
ALGORITHM InitializeSystem
    INPUT: Configuration file 'db_config.properties'
    OUTPUT: GUI Main Frame and Active Database Connection

    START
        SET LookAndFeel TO CrossPlatformModernTheme
        INITIALIZE DatabaseConfig FROM 'db_config.properties'
        
        TRY
            LOAD Driver "com.mysql.cj.jdbc.Driver"
            CONNECT TO MySQL DATABASE (host, port, db_name, user, password)
            IF Connection is SUCCESSFUL THEN
                SET UsingMockFallback = FALSE
                EXECUTE "SHOW TABLES LIKE 'users'" via Statement
                IF tables do not exist THEN
                    EXECUTE DatabaseInitializer("schema.sql")
                    EXECUTE DatabaseInitializer("procedures.sql")
                    EXECUTE DatabaseInitializer("seed_data.sql")
                END IF
            ELSE
                SET UsingMockFallback = TRUE
                INITIALIZE MockDatabaseEngine with initial seed data
            END IF
        CATCH Exception e
            SET UsingMockFallback = TRUE
            INITIALIZE MockDatabaseEngine
        END TRY

        CREATE MainFrame()
        INITIALIZE JMenuBar, HeaderBanner (Live Clock Timer), and JTabbedPane
        DISPLAY MainFrame on Screen
    END
```

---

## 2. Vehicle Entry & Slot Allocation Workflow Pseudo-Code

```plaintext
ALGORITHM ProcessVehicleEntry(plateNumber, vehicleType, ownerName, userCategory, preferredZoneId)
    INPUT: Vehicle Registration String, Vehicle Type, Owner details, Zone Preference
    OUTPUT: Entry Result (Success / Rejection, Generated Ticket, Allocated Slot)

    START
        CLEAN plateNumber = UPPERCASE(TRIM(plateNumber))
        IF plateNumber is EMPTY THEN
            RETURN Error("Invalid Plate Number")
        END IF

        // Step 1: Prevent Duplicate Active Parking Sessions
        EXECUTE PreparedStatement:
            "SELECT * FROM parking_sessions ps JOIN vehicles v ON ps.vehicle_id = v.vehicle_id 
             WHERE v.plate_number = ? AND ps.status = 'Active'"
        IF existingActiveSession found THEN
            RETURN Error("Vehicle is already parked inside campus.")
        END IF

        // Step 2: Lookup or Auto-Register Vehicle & User
        vehicle = VehicleDAO.findByPlateNumber(plateNumber)
        IF vehicle is NULL THEN
            user = User(ownerName, plateNumber + "@guest.campus.edu", "+91 9900000000", userCategory, "Active")
            UserDAO.insert(user)
            vehicle = Vehicle(user.id, plateNumber, vehicleType, "Standard", "Black")
            VehicleDAO.insert(vehicle)
        END IF

        // Step 3: Check Active Long-Term Parking Pass
        activePass = ParkingPassDAO.findActivePassForVehicle(vehicle.id)
        IF activePass is NOT NULL THEN
            targetZoneId = activePass.zoneId
        ELSE IF vehicle.isEV THEN
            targetZoneId = 6 // Z-EVP Green EV Priority Hub
        ELSE IF preferredZoneId > 0 THEN
            targetZoneId = preferredZoneId
        ELSE
            targetZoneId = 4 // Z-VIS Visitor Zone
        END IF

        // Step 4: Slot Allocation Engine
        slot = ZoneSlotDAO.findAvailableSlot(targetZoneId, vehicle.isEV ? "EV" : "Standard")
        IF slot is NULL THEN
            slot = ZoneSlotDAO.findAnyAvailableSlotAcrossAllZones(vehicle.isEV ? "EV" : "Standard")
        END IF

        IF slot is NULL THEN
            RETURN Error("Campus Parking Lot is FULL. No slots available.")
        END IF

        // Step 5: Generate Ticket & Create Session
        ticketNo = "TCK-" + FORMAT(CURRENT_TIMESTAMP, "yyyyMMdd-HHmmss") + "-" + slot.slotNumber
        session = ParkingSession(ticketNo, vehicle.id, slot.id, CURRENT_TIMESTAMP, activePass ? activePass.id : NULL, 'Active')
        
        ParkingSessionDAO.createEntrySession(session)
        ZoneSlotDAO.updateSlotStatus(slot.id, 'Occupied', vehicle.id)

        PRINT PrintableEntryTicket(session)
        RETURN Success("Vehicle Entry Authorized. Allocated Slot: " + slot.slotNumber)
    END
```

---

## 3. Vehicle Exit & Dynamic Tariff Calculation (`CallableStatement`)

```plaintext
ALGORITHM ProcessVehicleExit(ticketNumber, paymentMethod)
    INPUT: Ticket Number String, Payment Method (UPI / Card / Cash / CampusCard)
    OUTPUT: Duration, Gross Fee, Discount, Final Payable, Status Message

    START
        // Demonstrating JDBC CallableStatement (CO5)
        INITIALIZE CallableStatement cstmt = conn.prepareCall("{CALL sp_ProcessVehicleExit(?, ?, ?, ?, ?, ?, ?)}")
        
        SET cstmt.IN_PARAM(1, ticketNumber)
        SET cstmt.IN_PARAM(2, paymentMethod)
        
        REGISTER cstmt.OUT_PARAM(3, Types.INTEGER)  // p_duration_mins
        REGISTER cstmt.OUT_PARAM(4, Types.DECIMAL)  // p_calculated_fee
        REGISTER cstmt.OUT_PARAM(5, Types.DECIMAL)  // p_discount
        REGISTER cstmt.OUT_PARAM(6, Types.DECIMAL)  // p_final_fee
        REGISTER cstmt.OUT_PARAM(7, Types.VARCHAR)  // p_status_msg

        EXECUTE cstmt

        durationMinutes = cstmt.getInt(3)
        grossTariff     = cstmt.getDouble(4)
        discountApplied = cstmt.getDouble(5)
        finalAmountPaid = cstmt.getDouble(6)
        statusMessage   = cstmt.getString(7)

        IF statusMessage STARTS WITH "SUCCESS" THEN
            PRINT PrintableExitReceipt(ticketNumber, durationMinutes, grossTariff, discountApplied, finalAmountPaid)
            REFRESH VisualLotGrid()
            REFRESH DashboardKPIs()
            RETURN Success(statusMessage)
        ELSE
            RETURN Error(statusMessage)
        END IF
    END

// Stored Procedure Business Logic Inside MySQL:
PROCEDURE sp_ProcessVehicleExit_Logic:
    durationHours = CEIL(durationMinutes / 60.0)
    grossFee = durationHours * zoneBaseRate

    IF vehicleType == '2-Wheeler' THEN grossFee = grossFee * 0.5
    ELSE IF vehicleType == 'Bus' THEN grossFee = grossFee * 2.0
    ELSE IF vehicleType == 'EV' THEN grossFee = grossFee * 0.8 // 20% SDG 13 Green Subsidy

    IF passId IS NOT NULL THEN
        discount = grossFee
        finalFee = 0.00
    ELSE IF userType == 'Faculty' THEN
        discount = grossFee * 0.40 // 40% Faculty Benefit
        finalFee = grossFee - discount
    ELSE IF userType == 'Student' THEN
        discount = grossFee * 0.25 // 25% Student Concession
        finalFee = grossFee - discount
    ELSE IF userType == 'Staff' THEN
        discount = grossFee * 0.30 // 30% Staff Subsidy
        finalFee = grossFee - discount
    ELSE
        discount = 0.00
        finalFee = grossFee
    END IF

    UPDATE parking_sessions SET exit_time = NOW(), final_amount = finalFee, status = 'Completed'
    UPDATE parking_slots SET status = 'Available', current_vehicle_id = NULL
    IF finalFee > 0 THEN
        INSERT INTO payments (transaction_ref, session_id, amount, payment_method, status)
    END IF
```

---

## 4. Advance Slot Reservation & Conflict Resolution

```plaintext
ALGORITHM CreateAdvanceReservation(userId, vehicleId, slotId, startTime, endTime)
    INPUT: User ID, Vehicle ID, Slot ID, Booking Window (Start & End Timestamps)
    OUTPUT: Booking Confirmation or Conflict Alert

    START
        IF startTime >= endTime OR startTime < CURRENT_TIMESTAMP THEN
            RETURN Error("Invalid time window. Start time must be in future and before end time.")
        END IF

        // Check Overlapping Conflicting Reservations using PreparedStatement
        EXECUTE PreparedStatement:
            "SELECT COUNT(*) FROM reservations 
             WHERE slot_id = ? AND status IN ('Pending', 'Active') 
             AND (start_time < ? AND end_time > ?)" with (slotId, endTime, startTime)
             
        IF count > 0 THEN
            RETURN Error("Slot Conflict Detected! The selected space is already booked during this time interval.")
        END IF

        bookingRef = "RES-" + FORMAT(CURRENT_TIMESTAMP, "yyyyMMdd-HHmmss")
        EXECUTE PreparedStatement:
            "INSERT INTO reservations (booking_ref, user_id, vehicle_id, slot_id, start_time, end_time, status) 
             VALUES (?, ?, ?, ?, ?, ?, 'Pending')"
             
        ZoneSlotDAO.updateSlotStatus(slotId, 'Reserved', NULL)
        RETURN Success("Reservation Confirmed! Reference: " + bookingRef)
    END
```

---

## 5. Violation Ticket Issuance (`CallableStatement`)

```plaintext
ALGORITHM IssueViolationPenalty(plateNumber, slotNumber, violationType, fineAmount, remarks)
    INPUT: Vehicle Plate, Slot, Violation Category, Fine Amount, Remarks
    OUTPUT: Violation Ticket Number & Status Message

    START
        INITIALIZE CallableStatement cstmt = conn.prepareCall("{CALL sp_IssueViolationTicket(?, ?, ?, ?, ?, ?, ?)}")
        
        SET cstmt.IN_PARAM(1, plateNumber)
        SET cstmt.IN_PARAM(2, slotNumber)
        SET cstmt.IN_PARAM(3, violationType)
        SET cstmt.IN_PARAM(4, fineAmount)
        SET cstmt.IN_PARAM(5, remarks)
        
        REGISTER cstmt.OUT_PARAM(6, Types.VARCHAR) // ticketNumber
        REGISTER cstmt.OUT_PARAM(7, Types.VARCHAR) // statusMessage

        EXECUTE cstmt
        
        ticketNo = cstmt.getString(6)
        statusMsg = cstmt.getString(7)
        
        IF statusMsg STARTS WITH "SUCCESS" THEN
            RETURN Success("Violation Recorded: " + ticketNo)
        ELSE
            RETURN Error(statusMsg)
        END IF
    END
```

---

## 6. Analytical Aggregations & Reports (`Statement` & Views)

```plaintext
ALGORITHM GenerateZoneUtilizationAndRevenueReport
    OUTPUT: Zone-wise Occupancy Table, Revenue Totals, Vehicle Distribution

    START
        // Querying Database View using JDBC Statement (CO5)
        EXECUTE Statement: "SELECT * FROM view_zone_occupancy ORDER BY zone_id ASC"
        FOR EACH row IN ResultSet:
            zoneCode       = row.getString("zone_code")
            totalSlots     = row.getInt("total_slots")
            occupiedSlots  = row.getInt("occupied_slots")
            utilizationPct = (occupiedSlots / totalSlots) * 100.0
            DISPLAY in ZoneAnalyticsTable(zoneCode, totalSlots, occupiedSlots, utilizationPct)
        END FOR

        EXECUTE Statement: "SELECT payment_method, SUM(amount) FROM payments WHERE status='Success' GROUP BY payment_method"
        FOR EACH row IN ResultSet:
            DISPLAY in RevenueBreakdownChart(row.getString(1), row.getDouble(2))
        END FOR
    END
```
