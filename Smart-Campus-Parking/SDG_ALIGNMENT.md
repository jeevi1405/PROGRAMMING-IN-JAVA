# Reflection: Design Decisions, SDG Relevance & Learning Outcomes

**Course Code & Name:** CSA09 - Programming in Java  
**Assignment Title:** Smart Campus Parking and Traffic Management System using Java AWT/Swing and JDBC  
**Bloom’s Taxonomy Level:** L3 – Apply; L4 – Analyse  

---

## 1. Technical Design Decisions & Architectural Justifications

### 1.1 MVC (Model-View-Controller) & DAO Pattern Separation
* **Rationale:** A monolithic Swing application where database calls and GUI rendering are interleaved leads to code fragility, race conditions on the Event Dispatch Thread (EDT), and testability issues.
* **Implementation:** We decoupled the system into:
  - **Models (`model/`):** Pure data transfer objects representing entities (`User`, `Vehicle`, `ParkingSlot`, `Reservation`, `ParkingSession`, `ParkingPass`, `Violation`, `Payment`).
  - **Data Access Objects (`dao/`):** Dedicated SQL query handlers demonstrating `Statement`, `PreparedStatement`, and `CallableStatement`.
  - **Service Layer (`service/`):** Encapsulated business rules, dynamic tariff calculations, conflict checking, and report generation.
  - **View Layer (`ui/`):** Modern Java Swing panels, custom renderers, and responsive layout hierarchies.

### 1.2 Multi-Statement JDBC Strategy (CO5)
* **`Statement`:** Utilized for static, non-parameterized analytical queries over database views (`view_zone_occupancy`, `view_daily_revenue_summary`) and automatic DDL schema initialization.
* **`PreparedStatement`:** Standardized across all CRUD operations to guarantee SQL injection prevention, pre-compiled query caching, and binary data safety.
* **`CallableStatement`:** Implemented for transactional, high-integrity stored procedures in MySQL:
  1. `sp_ProcessVehicleExit`: Atomically computes duration, applies hierarchical discounts, updates slot status to 'Available', settles session records, and outputs calculated fee and duration via OUT parameters.
  2. `sp_GetZoneOccupancySummary`: Aggregates real-time slot telemetry by zone code.
  3. `sp_IssueViolationTicket`: Creates violation records and returns generated ticket references.

### 1.3 Smart Dual-Engine Database Architecture
* **Rationale:** Academic evaluations occur across varied environments where MySQL service credentials may differ or services may be unstarted.
* **Implementation:** The system auto-detects MySQL on `localhost:3306`. If connected, it uses live MySQL with stored procedures; if disconnected, it seamlessly switches to an embedded in-memory relational simulation engine (`MockDatabaseEngine.java`) without any crash or UI freeze.

---

## 2. UN Sustainable Development Goals (SDG) Alignment

### 🏗️ SDG 9: Industry, Innovation and Infrastructure
* **Target 9.1 & 9.4:** Develop quality, reliable, sustainable, and resilient infrastructure.
* **System Contribution:**
  - Automated parking allocation eliminates manual ticketing friction, minimizes campus congestion at entry gates, and optimizes physical land utilization across multi-floor campus facilities.
  - Real-time digital telemetry provides actionable utilization metrics to university administration for infrastructure capacity planning.

### 🏙️ SDG 11: Sustainable Cities and Communities
* **Target 11.2 & 11.6:** Provide access to safe, affordable, accessible, and sustainable transport systems and reduce adverse per capita environmental impacts.
* **System Contribution:**
  - Campus-wide zone segregation (Student, Faculty, Staff, Visitor, Service, Accessible) reduces circulation time and chaos during peak morning and evening rush hours.
  - Advance reservation capabilities allow students and staff to guarantee slot availability before departure, eliminating cruising for parking.

### 🌿 SDG 13: Climate Action
* **Target 13.2:** Integrate climate change measures into policies and planning.
* **System Contribution:**
  - **EV Green Subsidies:** The system integrates dedicated EV Fast-Charging Hubs (Zone `Z-EVP`) and applies an automated **20% Green Incentive Subsidy** on parking tariffs to encourage zero-emission electric mobility among university students and faculty.
  - **Emission Reduction:** Studies indicate that up to 30% of campus traffic congestion is caused by vehicles cruising for parking spaces. Real-time availability indicators directly cut vehicular idling time, lowering greenhouse gas emissions.

---

## 3. Bloom’s Taxonomy Reflection & Learning Outcomes

### Level 3 (Apply): Implementation of AWT/Swing & JDBC Concepts
* **CO4 Application:** Successfully applied AWT layout managers (`BorderLayout`, `GridBagLayout`, `GridLayout`, `FlowLayout`, `CardLayout`), custom 2D graphics rendering (`Graphics2D` antialiasing for slot status boards), and event-driven programming (ActionListener, MouseListener, KeyListener, ChangeListener).
* **CO5 Application:** Implemented end-to-end JDBC connection lifecycles, mapped database result sets to object graphs, and executed parameterized DML operations.

### Level 4 (Analyse): System Decomposition, Conflict Detection & Performance
* **Concurrency & Integrity Analysis:** Analyzed edge cases including concurrent slot allocation, reservation time-overlap conflicts, and multi-tier discount precedence.
* **Relational Schema Normalization:** Structured the database to 3rd Normal Form (3NF), ensuring referential integrity via foreign key cascades, unique plate indexes, and pre-computed views.
