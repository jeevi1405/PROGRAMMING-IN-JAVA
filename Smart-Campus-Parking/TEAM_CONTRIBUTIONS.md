# Team Member Contribution Report

**Course Code & Name:** CSA09 - Programming in Java  
**Assignment Title:** Smart Campus Parking and Traffic Management System using Java AWT/Swing and JDBC  
**Team Name:** Team SmartCampus (Max 3 Members)  
**Academic Term:** 2026 Academic Session  
**Evaluation Rubrics Alignment:** CO4 (GUI, Swing, Events), CO5 (JDBC, SQL Statements), SDG 9, 11, 13  

---

## 1. Executive Summary & Team Collaboration Overview
Our team architected and implemented an end-to-end Smart Campus Parking and Traffic Management Desktop Application using Java Swing/AWT and MySQL JDBC. The project is organized using a layered Model-View-Controller (MVC) and Data Access Object (DAO) architecture, ensuring high cohesion, modularity, and clean separation of concerns.

To achieve total uniqueness in design, database schema, and operational logic, each member took ownership of distinct functional modules while actively participating in database normalization, code reviews, and integration testing.

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                 TEAM RESPONSIBILITY MATRIX                              │
├─────────────────────────┬───────────────────────────────┬───────────────────────────────┤
│ Member 1 (Lead Dev & DB)│ Member 2 (GUI & Visualization)│ Member 3 (Business & Reports) │
├─────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ • Database Schema (DDL) │ • Master MainFrame & Menus    │ • Tariff & Pricing Engine     │
│ • Stored Procedures SQL │ • 2D Visual Slot Map Canvas   │ • Advance Reservation Module  │
│ • JDBC Connection Layer │ • Modern Table & KPI Cards    │ • Parking Passes & Violations │
│ • Statement/PreparedStatement• Dialogs & Thermal Receipts│ • Analytics & CSV Exporter    │
└─────────────────────────┴───────────────────────────────┴───────────────────────────────┘
```

---

## 2. Individual Member Contributions

### Member 1: Database Architecture, JDBC Layer & Core CRUD Operations
* **Primary Responsibility:** Relational Database Design, JDBC Connectivity, Stored Procedures, and Data Access Objects.
* **Key Components & Source Code Developed:**
  - **Database DDL & Procedures (`schema.sql`, `procedures.sql`, `seed_data.sql`):** Designed 9 relational tables with primary keys, foreign key constraints, indexes, and database views (`view_zone_occupancy`, `view_daily_revenue_summary`). Wrote MySQL stored procedures (`sp_ProcessVehicleExit`, `sp_GetZoneOccupancySummary`, `sp_IssueViolationTicket`).
  - **JDBC Infrastructure (`DatabaseConnection.java`, `DatabaseConfig.java`, `DatabaseInitializer.java`):** Configured dynamic connection pooling, automated script execution via `Statement`, and connection persistence.
  - **Dual-Engine Fallback (`MockDatabaseEngine.java`):** Built an in-memory relational store to ensure seamless evaluation even on machines without configured MySQL credentials.
  - **DAO Implementation (`UserDAO.java`, `VehicleDAO.java`, `ZoneSlotDAO.java`):** Implemented parameterized queries using `PreparedStatement` to prevent SQL injection and manage CRUD operations for users, vehicles, and zones.

### Member 2: GUI Design, Layout Management & Visual Interactive Canvas
* **Primary Responsibility:** Front-End Architecture, AWT/Swing Layouts, Custom Components, Menu Bar, and Event Handling.
* **Key Components & Source Code Developed:**
  - **Design System & Theme (`UITheme.java`):** Designed an eye-catching modern dark palette (Slate 900/800/700) with tailored font hierarchies, custom borders, and responsive button hover animations.
  - **Master Navigation (`MainFrame.java`):** Implemented multi-layout containers (`BorderLayout`, `GridBagLayout`, `GridLayout`, `FlowLayout`, `CardLayout`), `JTabbedPane`, and a complete `JMenuBar` with Mnemonics (`Alt+F`, `Alt+O`, `Alt+R`) and Accelerators (`Ctrl+N`, `Ctrl+E`, `Ctrl+M`, `Ctrl+P`, `F5`, `F1`).
  - **2D Visual Parking Lot Visualizer (`VisualParkingLotPanel.java`, `SlotButton.java`):** Developed custom-painted 2D slot buttons with dynamic status color badges (Green for Available, Red for Occupied, Amber for Reserved, Slate for Maintenance, Cyan for EV Fast-Charging) and live click-to-inspect handlers.
  - **Interactive Dialogs (`TicketReceiptDialog.java`, `SlotDetailDialog.java`, `DatabaseSetupDialog.java`, `AboutDialog.java`):** Created thermal ticket print simulators, slot status overrides, and system configuration modals.

### Member 3: Business Logic, Billing Calculations, Passes, Violations & Analytics
* **Primary Responsibility:** Workflow Automation, Dynamic Tariff Engine, Stored Procedure Invocations, and Analytical Reporting.
* **Key Components & Source Code Developed:**
  - **Entry & Exit Workflow (`VehicleEntryExitPanel.java`, `ParkingService.java`, `ParkingSessionDAO.java`):** Engineered the gate check-in workflow with plate validation and executed `sp_ProcessVehicleExit` via JDBC `CallableStatement` with `IN` and `OUT` parameter mappings (`Types.INTEGER`, `Types.DECIMAL`, `Types.VARCHAR`).
  - **Dynamic Tariff & Eco-Incentive Engine (`TariffCalculator.java`):** Built tiered hourly duration billing with vehicle multipliers (2-Wheeler 0.5x, Bus 2.0x, EV 0.8x for SDG 13 Green Subsidy) and user-role discounts (Faculty 40%, Staff 30%, Student 25%).
  - **Passes & Violations (`ParkingPassPanel.java`, `ViolationPanel.java`, `ViolationDAO.java`):** Built permit issuers, fast-gate tag verification, and violation penalty recorders using `sp_IssueViolationTicket`.
  - **Advance Reservation & Conflict Resolver (`ReservationPanel.java`, `ReservationDAO.java`):** Built overlap detection algorithms preventing double-booking of campus spaces.
  - **Analytics & Exporters (`AnalyticsReportPanel.java`, `AnalyticsDAO.java`, `ReportExporter.java`):** Developed real-time utilization tables, payment method charts, and CSV data export utilities.

---

## 3. Team Verification & Sign-Off
All three team members have verified the complete project execution, tested database operations under live MySQL 8.0 and fallback modes, and verified compliance with all assignment rubrics.
