# Smart Campus Parking and Traffic Management System - User Manual

## System Overview
The Smart Campus Parking and Traffic Management System is a desktop application developed with Java AWT/Swing and MySQL JDBC. It manages campus parking facilities across six dedicated zones with automated check-in, real-time visual mapping, dynamic fee calculations, parking passes, violation enforcement, and analytical reports.

---

## 1. Quick Start & Execution

### Prerequisites:
- Java JDK 8 or higher (Java 17, 21, 25 fully supported)
- MySQL Server 8.0 (Optional - Automatic fallback in-memory engine runs if MySQL is not available)

### How to Run:
- **Option 1 (Windows Batch):** Double-click `build_and_run.bat` in the root folder.
- **Option 2 (PowerShell):** Open PowerShell in project directory and run:
  ```powershell
  .\compile.ps1
  .\run.ps1
  ```
- **Option 3 (Command Line):**
  ```bash
  javac -cp "lib/mysql-connector-j-9.3.0.jar" -d bin src/com/campus/parking/**/*.java
  java -cp "bin;lib/mysql-connector-j-9.3.0.jar" com.campus.parking.Main
  ```

---

## 2. Navigating the Graphical User Interface

### 📊 Tab 1: Live Dashboard
- **Top KPI Cards:** Displays total parking capacity, currently occupied spaces, ready available slots, lot occupancy rate, gross revenue, and active unpaid penalties.
- **Quick Operations:** Direct shortcuts to Entry Terminal, Exit Billing, and 2D Lot Map.
- **Real-Time Zone Occupancy Bars:** Visual progress meters for all 6 campus zones (Student, Faculty, Staff, Visitor, Service, EV Charging).
- **Recent Sessions Table:** Live feed of recent vehicle check-ins and check-outs.

### 🗺️ Tab 2: 2D Interactive Lot Map
- **Visual Slot Grid:** Interactive graphical matrix showing individual parking spaces with color codes:
  - 🟢 **Green:** Available (Open for parking)
  - 🔴 **Red:** Occupied (Currently parked vehicle plate displayed)
  - 🟡 **Amber:** Reserved (Advance booked space)
  - ⚫ **Slate Gray:** Maintenance (Temporarily offline)
  - 🔵 **Cyan Badge (⚡):** EV Fast-Charging Station
- **Filters:** Filter by Zone, Status, or Slot Type.
- **Slot Inspector:** Click any slot button to view details, vacate space, or change maintenance status.

### 🚗 Tab 3: Entry & Exit Terminal
- **Vehicle Entry Terminal (Left):**
  1. Enter Plate Number (e.g. `KA-01-MJ-2024`).
  2. Select Vehicle Type (`Car`, `2-Wheeler`, `EV`, `Bus`).
  3. Enter Driver / Owner Name and User Category (`Student`, `Faculty`, `Staff`, `Visitor`).
  4. Click **"Check-In & Issue Parking Ticket"**.
  5. A thermal-styled printable parking ticket dialog will pop up with entry timestamp and allocated slot.
- **Vehicle Exit Terminal (Right):**
  1. Enter Ticket Number or select a vehicle from the Active Sessions table below.
  2. The system automatically computes duration, hourly gross tariff, category discounts, and net payable fee.
  3. Select Payment Method (`UPI`, `Card`, `Cash`, `CampusCard`).
  4. Click **"Process Exit & Release Slot"** (Invokes MySQL Stored Procedure `sp_ProcessVehicleExit` via `CallableStatement`).
  5. Printable exit receipt dialog appears and the parking space is freed immediately!

### 📅 Tab 4: Advance Reservations
- Select registered User, Vehicle, target Parking Slot, Start Time, and Duration (hours).
- Built-in conflict checker alerts if the space is already booked during the selected interval.
- Confirm booking to lock the slot in Amber (Reserved) status.

### 👤 Tab 5: Users & Vehicles Directory
- **Campus Users Sub-Tab:** Register, edit, search, and delete students, faculty, staff, and visitors.
- **Vehicles Registry Sub-Tab:** Link vehicles with license plates to campus users.

### 🎟️ Tab 6: Parking Passes & Permits
- Issue long-term permits (Annual, Semester, Monthly, Daily) for authorized personnel.
- **Fast-Gate Verifier:** Type a pass number or vehicle plate to verify validity and access rights in real-time.

### 🚨 Tab 7: Traffic & Parking Violations
- Issue violation tickets for unauthorized zone parking, overstaying, missing permits, or speeding using `sp_IssueViolationTicket` (`CallableStatement`).
- Settle or waive penalty fines.

### 📈 Tab 8: Analytics & Reports
- View zone-wise utilization telemetry querying database view `view_zone_occupancy`.
- Vehicle distribution charts and payment method revenue breakdown.
- Export all reports directly to CSV files for Excel/administrative audit.

---

## 3. Keyboard Shortcuts & Menus

| Shortcut | Action |
|---|---|
| `Ctrl + N` | Quick Vehicle Check-In |
| `Ctrl + E` | Quick Vehicle Exit & Billing |
| `Ctrl + M` | Open 2D Interactive Lot Map |
| `Ctrl + R` | Open Reservations Scheduler |
| `Ctrl + P` | Open Parking Passes |
| `Ctrl + V` | Issue Violation Ticket |
| `F5` | Refresh All Telemetry & Panels |
| `F1` | About System & Course Info |
| `Ctrl + Q` | Exit Application |
