# 🚗 Smart Campus Parking and Traffic Management System

[![Java Version](https://img.shields.io/badge/Java-JDK%208%20%7C%2017%20%7C%2021%20%7C%2025-orange.svg)](https://adoptium.net/)
[![Database](https://img.shields.io/badge/Database-MySQL%208.0%20%2B%20In--Memory%20Engine-blue.svg)](https://www.mysql.com/)
[![GUI](https://img.shields.io/badge/GUI-Java%20AWT%20%26%20Swing-green.svg)](https://docs.oracle.com/javase/8/docs/technotes/guides/swing/)
[![Course](https://img.shields.io/badge/Course-CSA09%20Programming%20in%20Java-purple.svg)](#)
[![SDG](https://img.shields.io/badge/SDG%20Mapping-SDG%209%20%7C%2011%20%7C%2013-teal.svg)](#)

A comprehensive, production-grade desktop application designed and implemented to automate parking and traffic facilities in a university campus environment. Developed for **Course CSA09 - Programming in Java**, fulfilling all rubrics for **CO4** (GUI Design, Layout Managers, AWT Controls, Menus, Event Handling) and **CO5** (JDBC Connectivity, SQL CRUD, Statement, PreparedStatement, CallableStatement).

---

## 🌟 Key Highlights & Unique Features

1. **🎨 High-Aesthetic Java Swing UI:**
   - Tailored Dark Modern Design System (`UITheme.java`) with slate palettes, rounded card containers, and typography hierarchy.
   - Comprehensive Menu Bar (`JMenuBar`) featuring **Mnemonics** (`Alt+F`, `Alt+O`, `Alt+R`) and **Accelerators** (`Ctrl+N`, `Ctrl+E`, `Ctrl+M`, `Ctrl+P`, `F5`, `F1`).
   - Live digital clock running on `javax.swing.Timer` and real-time DB status indicator.

2. **🗺️ 2D Interactive Visual Parking Lot Map:**
   - Custom-painted 2D slot buttons with live color badges: 🟢 Green (Available), 🔴 Red (Occupied + Plate No), 🟡 Amber (Reserved), ⚫ Slate (Maintenance), 🔵 Cyan (⚡ EV Fast-Charging).
   - Filter by Zone, Status, or Slot Type with one-click slot inspection and status override dialog.

3. **💾 3-Tier Statement JDBC Implementation (CO5):**
   - **`Statement`:** Used for schema creation and analytical queries over SQL Views (`view_zone_occupancy`, `view_daily_revenue_summary`).
   - **`PreparedStatement`:** Parameterized CRUD for users, vehicles, reservations, passes, sessions, and violations to guarantee SQL injection immunity.
   - **`CallableStatement`:** Invokes MySQL Stored Procedures with `IN` and `OUT` parameters:
     * `sp_ProcessVehicleExit`: Automates checkout, duration calculation, tiered tariffs, and slot freeing.
     * `sp_GetZoneOccupancySummary`: Real-time zone telemetry.
     * `sp_IssueViolationTicket`: Automated penalty generation.

4. **⚡ Smart Dual-Engine Database Connector:**
   - Connects to local MySQL 8.0 server with automated schema and procedure initialization.
   - Seamlessly switches to an embedded in-memory relational simulation engine (`MockDatabaseEngine.java`) if MySQL is offline, ensuring 100% crash-free evaluation on any computer!

5. **🌱 UN Sustainable Development Goals (SDGs) Integration:**
   - **SDG 9 (Industry & Infrastructure):** Automated parking allocation and traffic flow optimization.
   - **SDG 11 (Sustainable Cities):** Multi-zone classification and reduced vehicle idling time.
   - **SDG 13 (Climate Action):** Dedicated EV Charging Hubs with **20% Green Tariffs Subsidies**.

---

## 📁 Repository Structure

```
SmartCampusParking/
├── database/
│   ├── schema.sql                 # DDL Tables, Keys, Constraints, Indexes & Views
│   ├── procedures.sql             # Stored Procedures for CallableStatement
│   └── seed_data.sql              # Realistic University Campus Seed Data
├── docs/
│   ├── PSEUDOCODE.md              # Complete Pseudo-code for all modules
│   ├── TEAM_CONTRIBUTIONS.md      # 1-Page Individual Team Member Contribution Report
│   ├── SDG_ALIGNMENT.md           # Reflection on SDG 9, 11, 13 & Design Decisions
│   └── USER_MANUAL.md             # Detailed GUI Operating Guide & Shortcuts
├── lib/
│   └── mysql-connector-j-9.3.0.jar# JDBC Driver
├── src/com/campus/parking/
│   ├── Main.java                  # Application Entrypoint & Theme Bootstrapper
│   ├── config/                    # Configuration & Property Persistence
│   ├── database/                  # Connection Factory, Initializer, Mock Engine
│   ├── model/                     # Entity Data Models (POJOs)
│   ├── dao/                       # Data Access Layer (Statement/Prepared/Callable)
│   ├── service/                   # Business Services & Tariff Calculator
│   └── ui/                        # Presentation Layer (Theme, Components, Dialogs, Panels)
├── build_and_run.bat              # One-Click Windows Build & Run Script
├── compile.ps1                    # PowerShell Compilation Script
├── run.ps1                        # PowerShell Application Runner
└── README.md                      # Project Documentation
```

---

## 🚀 Quick Start & How to Run

### Method 1: Windows Batch File (Easiest)
Double-click `build_and_run.bat` in the root folder.

### Method 2: PowerShell Scripts
```powershell
# Compile all source files
.\compile.ps1

# Run Application
.\run.ps1
```

### Method 3: Standard Terminal
```bash
# 1. Compile with JDBC driver on classpath
javac -cp "lib/mysql-connector-j-9.3.0.jar" -d bin src/com/campus/parking/**/*.java

# 2. Run Main application
java -cp "bin;lib/mysql-connector-j-9.3.0.jar" com.campus.parking.Main
```

---

## 📋 Course Assessment Rubrics Alignment

| Rubric Criteria | CO | Marks | Implementation in Project |
|---|---|---|---|
| **GUI Design & Layout Managers** | CO4 | 15 | `BorderLayout`, `GridBagLayout`, `GridLayout`, `FlowLayout`, `CardLayout`, custom modern dark theme (`UITheme.java`), responsive cards. |
| **Event Handling & Menus** | CO4 | 15 | `JMenuBar` with Accelerators (`Ctrl+N`, `Ctrl+E`, `Ctrl+M`, `Ctrl+P`) & Mnemonics, `Timer` clock, mouse adapters, table selection listeners. |
| **Vehicle, User & Parking Management** | CO4/CO5 | 15 | Multi-role user directory (Student, Faculty, Staff, Visitor), vehicle registry, 6 campus zones, 52 slots, slot status inspector. |
| **Reservation, Entry/Exit & Fee Calculation** | CO4/CO5 | 15 | Ticket generator, time conflict checker, dynamic tiered tariff engine with EV green subsidies and category discounts, exit billing. |
| **JDBC Connectivity & Database Design** | CO5 | 15 | 9 normalized relational tables, foreign key constraints, indexes, connection management with automatic fallback. |
| **SQL Operations & Statement Types** | CO5 | 15 | Full demonstration of **`Statement`** (Views & DDL), **`PreparedStatement`** (CRUD), and **`CallableStatement`** (Stored Procedures with IN/OUT params). |
| **Parking Passes, Violations & Reports** | CO4/CO5 | 10 | Long-term permits, fast-gate RFID scanner, violation ticket issuer, CSV report exporters. |
| **Reflection & SDG Alignment** | All | 5 | Comprehensive documentation of SDG 9, 11, 13, design trade-offs, and Bloom's Taxonomy L3/L4 outcomes in `docs/`. |

---

## 👥 Authors
* **Team SmartCampus** (Dept. of Computer Science and Engineering)
* Course: CSA09 - Programming in Java
