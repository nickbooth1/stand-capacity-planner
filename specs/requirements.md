# Stand Capacity Planning Tool
# Developer Requirements Specification

**Version:** 1.0  
**Date:** January 2025

---

## Overview

This document provides a detailed list of requirements for developing the Stand Capacity Planning Tool. Each requirement includes acceptance criteria that define when the requirement is considered complete.

---

## 1. Stand Inventory Management

### REQ-1.1: Create Stand Record

**Description:** Users can create a new stand record with all required attributes.

**Acceptance Criteria:**
- [ ] Form captures all required fields (see data specification below)
- [ ] Stand ID must be unique; system rejects duplicates with clear error message
- [ ] Maximum wingspan and length must be positive numbers
- [ ] Operating hours end must be after operating hours start
- [ ] Successful creation displays confirmation and adds stand to list
- [ ] New stand immediately appears in all relevant views (list, map, capacity calculations)

---

### REQ-1.2: View Stand List

**Description:** Users can view all stands in a searchable, sortable table.

**Acceptance Criteria:**
- [ ] Table displays: Stand ID, Aircraft Code, Terminal, Pier, Contact/Remote, AVDGS, FEGP, Hydrant, Status
- [ ] Table is sortable by any column (click column header)
- [ ] Search box filters stands by ID, terminal, or pier (instant filtering as user types)
- [ ] Pagination or virtual scrolling for large datasets (>100 stands)
- [ ] Click on row opens stand detail view

---

### REQ-1.3: Edit Stand Record

**Description:** Users can modify existing stand attributes.

**Acceptance Criteria:**
- [ ] All fields are editable except Stand ID
- [ ] Same validation rules apply as creation
- [ ] Cancel button discards changes
- [ ] Save button persists changes and displays confirmation
- [ ] Changes immediately reflected in capacity calculations

---

### REQ-1.4: Delete Stand Record

**Description:** Users can remove a stand from the system.

**Acceptance Criteria:**
- [ ] Delete requires confirmation dialog ("Are you sure? This cannot be undone.")
- [ ] If stand has associated maintenance records, warn user these will also be deleted
- [ ] Successful deletion removes stand from all views and recalculates capacity
- [ ] Deleted stand no longer appears in any dropdown or selection list

---

### REQ-1.5: Bulk Import Stands

**Description:** Users can import multiple stands from a CSV or Excel file.

**Acceptance Criteria:**
- [ ] System accepts .csv and .xlsx file formats
- [ ] Template file available for download showing required columns
- [ ] Import validates all rows before committing any
- [ ] Validation errors displayed with row number and field name
- [ ] Successful import shows count of stands created
- [ ] Duplicate Stand IDs are rejected with clear error

---

### REQ-1.6: Stand Data Specification

**Required Fields:**

| Field | Type | Validation |
|-------|------|------------|
| Stand ID | String (max 20 chars) | Required, unique, alphanumeric |
| Maximum Aircraft Code | Enum: C, E, F | Required |
| Maximum Wingspan (m) | Decimal | Required, > 0, max 2 decimal places |
| Maximum Length (m) | Decimal | Required, > 0, max 2 decimal places |
| Contact/Remote | Enum: Contact, Remote | Required |
| Terminal | String (max 50 chars) | Required |
| Domestic/International | Enum: Domestic, International, Swing | Required |
| Operating Hours Start | Time (HH:MM) | Required |
| Operating Hours End | Time (HH:MM) | Required, must be after start |
| AVDGS | Boolean | Required |
| FEGP | Boolean | Required |
| PCA | Boolean | Required |
| Fuel Hydrant | Boolean | Required |

**Optional Fields:**

| Field | Type | Validation |
|-------|------|------------|
| Pier | String (max 50 chars) | Optional |
| Jet Bridge Count | Integer | Optional, >= 0 |
| Jet Bridge Type | String (max 50 chars) | Optional |
| Notes | Text (max 500 chars) | Optional |

---

## 2. MARS Configuration

### REQ-2.1: Define MARS Stand

**Description:** Users can mark a stand as MARS-capable and define its configurations.

**Acceptance Criteria:**
- [ ] Checkbox or toggle to indicate stand is MARS-capable
- [ ] When enabled, user can define 2+ configuration options
- [ ] Each configuration specifies: number of positions, aircraft code per position, child stand IDs
- [ ] Example: "1× Code E" OR "2× Code C (501L, 501R)"
- [ ] Child stand IDs must not conflict with existing stand IDs
- [ ] At least 2 configurations required for MARS stand

---

### REQ-2.2: MARS Capacity Calculation

**Description:** System applies conservative assumption for MARS stands in capacity calculations.

**Acceptance Criteria:**
- [ ] MARS stand counted as its least flexible configuration (typically the single large aircraft option)
- [ ] System does not count both configurations simultaneously
- [ ] Tooltip or indicator shows user which configuration is being assumed
- [ ] Documentation clearly explains this assumption

---

## 3. Adjacency Dependencies

### REQ-3.1: Define Adjacency Dependency

**Description:** Users can define relationships where one stand's occupancy affects another.

**Acceptance Criteria:**
- [ ] User selects: Primary Stand, Trigger Condition, Affected Stand(s), Constraint Applied
- [ ] Trigger Condition options: "Code C or larger", "Code E or larger", "Code F", "Any aircraft"
- [ ] Constraint options: "Unavailable", "Max Code C", "Max Code E", "No push-back"
- [ ] Multiple affected stands can be selected for one dependency
- [ ] Circular dependencies are allowed (Stand A affects B and B affects A)
- [ ] Dependencies stored and displayed in a list view

---

### REQ-3.2: View Adjacency Dependencies

**Description:** Users can view all defined adjacency relationships.

**Acceptance Criteria:**
- [ ] Table shows: Primary Stand, Trigger, Affected Stands, Constraint
- [ ] Sortable and filterable by any column
- [ ] Edit and delete actions available per row

---

### REQ-3.3: Adjacency Capacity Calculation

**Description:** System applies conservative assumption for adjacency constraints.

**Acceptance Criteria:**
- [ ] When calculating capacity, assume adjacency constraints are always active
- [ ] Affected stands are downgraded to their constrained capability
- [ ] Example: If Stand 80 (Code E) constrains Stand 81 to Code C when occupied, capacity calculation counts Stand 81 as Code C only
- [ ] This applies to theoretical and live capacity calculations

---

## 4. Turnaround Time Configuration

### REQ-4.1: Configure Default Turnaround Times

**Description:** Users can set default turnaround and buffer times by aircraft code.

**Acceptance Criteria:**
- [ ] Settings page shows table with Code C, Code E, Code F rows
- [ ] Columns: Aircraft Code, Turnaround Time (mins), Buffer Time (mins)
- [ ] Default values pre-populated (e.g., 45/15, 75/20, 90/25)
- [ ] Values editable inline
- [ ] Validation: all values must be positive integers
- [ ] Save button persists changes
- [ ] Changes immediately affect capacity calculations

---

### REQ-4.2: Turnaround Time in Calculations

**Description:** System uses turnaround times to calculate movements per day.

**Acceptance Criteria:**
- [ ] Movements per day per stand = Operating Hours ÷ (Turnaround + Buffer)
- [ ] Calculation uses the turnaround time matching the stand's maximum aircraft code
- [ ] Example: Code E stand with 17 operating hours, 75-min turnaround, 20-min buffer = 17×60÷95 = 10.7 → 10 movements

---

## 5. Maintenance Management

### REQ-5.1: Create Maintenance Record

**Description:** Users can record planned or unplanned maintenance.

**Acceptance Criteria:**
- [ ] Form captures: Stand(s) affected, Start datetime, End datetime, Type, Description, Equipment affected
- [ ] Stand selection allows multiple stands
- [ ] Type options: Planned, Emergency, Reactive
- [ ] Equipment affected options (multi-select): AVDGS, FEGP, PCA, Hydrant, Jet Bridge, Full Stand
- [ ] End datetime must be after start datetime
- [ ] Overlapping maintenance on same stand is allowed (with warning)
- [ ] Successful creation shows confirmation

---

### REQ-5.2: View Maintenance List

**Description:** Users can view all maintenance records.

**Acceptance Criteria:**
- [ ] Table shows: Stands, Period, Type, Description, Equipment, Status (Active/Upcoming/Completed)
- [ ] Filterable by: status, type, stand, date range
- [ ] Sortable by any column
- [ ] Click opens detail/edit view

---

### REQ-5.3: Edit Maintenance Record

**Description:** Users can modify existing maintenance records.

**Acceptance Criteria:**
- [ ] All fields editable
- [ ] Same validation as creation
- [ ] Changes reflected in capacity calculations immediately

---

### REQ-5.4: Delete Maintenance Record

**Description:** Users can remove maintenance records.

**Acceptance Criteria:**
- [ ] Confirmation dialog required
- [ ] Deletion recalculates live capacity

---

### REQ-5.5: Recurring Maintenance

**Description:** Users can define recurring maintenance patterns.

**Acceptance Criteria:**
- [ ] Recurrence options: Weekly, Fortnightly, Monthly
- [ ] Specify day(s) of week and time window
- [ ] System generates individual maintenance instances
- [ ] Editing the pattern updates future instances only
- [ ] Individual instances can be modified or cancelled

---

### REQ-5.6: Maintenance Calendar View

**Description:** Visual calendar display of maintenance.

**Acceptance Criteria:**
- [ ] Monthly calendar grid view
- [ ] Maintenance blocks displayed on relevant days
- [ ] Colour-coded by type (Planned=blue, Emergency=red, Recurring=purple)
- [ ] Click on block shows maintenance details
- [ ] Navigate between months (previous/next buttons)
- [ ] "Today" button returns to current month

---

## 6. Capacity Calculation

### REQ-6.1: Theoretical Capacity Calculation

**Description:** Calculate maximum capacity assuming all stands operational.

**Acceptance Criteria:**
- [ ] Output: Number of positions by aircraft code (F, E, C)
- [ ] Output: Daily stand-hours by aircraft code
- [ ] Output: Movements per day by aircraft code (using turnaround times)
- [ ] MARS stands counted in least flexible configuration
- [ ] Adjacency constraints applied (worst-case)
- [ ] Calculation completes in < 3 seconds

---

### REQ-6.2: Live Capacity Calculation

**Description:** Calculate current capacity accounting for maintenance.

**Acceptance Criteria:**
- [ ] Starts with theoretical capacity
- [ ] Subtracts stands with active maintenance (current datetime falls within maintenance period)
- [ ] Subtracts stands with scheduled maintenance for selected date
- [ ] Recalculates adjacency impacts based on remaining stands
- [ ] Output: Same format as theoretical (positions, stand-hours, movements by code)
- [ ] Shows delta from theoretical

---

### REQ-6.3: Hourly Capacity Profile

**Description:** Calculate capacity for each hour of the operating day.

**Acceptance Criteria:**
- [ ] Output: Table/chart showing positions by hour (rows) and aircraft code (columns)
- [ ] Hours outside operating day show zero
- [ ] Accounts for maintenance that affects only part of the day
- [ ] Selectable date (defaults to today)

---

### REQ-6.4: Equipment Capacity Calculation

**Description:** Calculate capacity of equipped stands.

**Acceptance Criteria:**
- [ ] Output: Positions with AVDGS (theoretical and live)
- [ ] Output: Positions with FEGP (theoretical and live)
- [ ] Output: Positions with PCA (theoretical and live)
- [ ] Output: Positions with Hydrant (theoretical and live)
- [ ] Output: Contact stand positions (theoretical and live)
- [ ] Delta shown where live differs from theoretical

---

## 7. Scenario Analysis

### REQ-7.1: Create Scenario

**Description:** Users can define a hypothetical scenario.

**Acceptance Criteria:**
- [ ] Input: Scenario name (required, max 100 chars)
- [ ] Input: Stands to remove (multi-select from available stands)
- [ ] Input: Date range (start and end date)
- [ ] Input: Reason/description (optional, max 500 chars)
- [ ] Scenario saved with unique ID

---

### REQ-7.2: Scenario Impact Calculation

**Description:** Calculate capacity impact of a scenario.

**Acceptance Criteria:**
- [ ] Output: Capacity by aircraft code (Baseline → Scenario → Delta)
- [ ] Output: Equipment capacity (Baseline → Scenario → Delta)
- [ ] Output: Hourly impact profile for the period
- [ ] Output: Peak hour impact (worst hour)
- [ ] Output: Total stand-hours lost
- [ ] Baseline = Live capacity (already accounting for existing maintenance)
- [ ] Scenario = Live capacity minus scenario stands

---

### REQ-7.3: Real-time Impact Preview

**Description:** As user builds scenario, impact updates in real-time.

**Acceptance Criteria:**
- [ ] Impact panel updates within 1 second of changing any input
- [ ] No need to click "Calculate" button
- [ ] Clear visual indication when recalculating

---

### REQ-7.4: Save and Load Scenarios

**Description:** Users can persist and retrieve scenarios.

**Acceptance Criteria:**
- [ ] Save button stores scenario with all inputs and calculated impacts
- [ ] Saved scenarios listed in a retrievable list
- [ ] Load button populates scenario builder with saved values
- [ ] Delete option available for saved scenarios
- [ ] Saved scenarios show: name, date created, stands affected, period

---

### REQ-7.5: Compare Scenarios

**Description:** Users can compare multiple scenarios side-by-side.

**Acceptance Criteria:**
- [ ] Select 2-3 scenarios for comparison
- [ ] Table shows each scenario as column, metrics as rows
- [ ] Metrics: Code F/E/C delta, equipment deltas, peak hour impact
- [ ] Visual highlighting of "best" option per metric (least negative impact)

---

### REQ-7.6: Period Comparison

**Description:** Compare same works scheduled in different periods.

**Acceptance Criteria:**
- [ ] User defines works (stands affected) once
- [ ] User selects multiple periods to compare (e.g., March, April, September)
- [ ] System calculates impact for each period
- [ ] Output shows: period, capacity impact, risk level indicator
- [ ] Risk level based on configurable thresholds (e.g., >10% reduction = High)

---

### REQ-7.7: Export Scenario Report

**Description:** Generate downloadable report of scenario analysis.

**Acceptance Criteria:**
- [ ] Export to PDF format
- [ ] Report includes: scenario details, capacity impacts, hourly profile, comparison (if applicable)
- [ ] Report header shows: generated date, user, tool version
- [ ] Filename includes scenario name and date

---

## 8. Dashboard

### REQ-8.1: Capacity Health Cards

**Description:** Display current capacity status by aircraft code.

**Acceptance Criteria:**
- [ ] Three cards: Code F, Code E, Code C
- [ ] Each shows: positions available, status indicator
- [ ] Status indicator: Green (no reduction), Amber (1-3 reduction), Red (>3 reduction)
- [ ] If reduced, shows reduction amount and cause (e.g., "-2 from maintenance")
- [ ] Click on card navigates to detail view

---

### REQ-8.2: Equipment Capability Bars

**Description:** Display equipment availability as progress bars.

**Acceptance Criteria:**
- [ ] Bars for: AVDGS, FEGP, PCA, Hydrant, Contact Stands
- [ ] Each shows: available/total and percentage
- [ ] Bar colour: Green (>90%), Amber (75-90%), Red (<75%)
- [ ] Hover shows breakdown details

---

### REQ-8.3: Upcoming Maintenance Panel

**Description:** Display list of upcoming maintenance.

**Acceptance Criteria:**
- [ ] Shows next 5-10 maintenance items
- [ ] Each shows: stands, period, type badge, impact summary
- [ ] Sorted by start date (soonest first)
- [ ] "View all" link navigates to maintenance calendar
- [ ] Click on item opens maintenance detail

---

### REQ-8.4: Hourly Capacity Chart

**Description:** Display today's capacity profile as a chart.

**Acceptance Criteria:**
- [ ] Stacked area chart or stacked bar chart
- [ ] X-axis: hours of operating day
- [ ] Y-axis: positions
- [ ] Stacks: Code F, Code E, Code C (distinct colours)
- [ ] Legend showing colours
- [ ] Current hour highlighted

---

### REQ-8.5: View Toggle

**Description:** Toggle between Theoretical and Live capacity views.

**Acceptance Criteria:**
- [ ] Toggle button/switch clearly visible
- [ ] Default: Live
- [ ] Switching updates all dashboard components
- [ ] Visual indicator of current mode

---

### REQ-8.6: Date Selector

**Description:** View capacity for a specific date.

**Acceptance Criteria:**
- [ ] Date picker input
- [ ] Default: today
- [ ] Selecting date updates dashboard for that date
- [ ] Future dates use scheduled maintenance
- [ ] Past dates use historical maintenance records

---

## 9. Airfield Map View

### REQ-9.1: Stand Visualisation

**Description:** Display stands in a visual layout.

**Acceptance Criteria:**
- [ ] Stands represented as clickable shapes
- [ ] Grouped by terminal/pier with labels
- [ ] Colour-coded by status: Green (available), Amber (constrained), Red (maintenance)
- [ ] Stand ID and aircraft code displayed on each shape
- [ ] Layout approximates physical airfield layout (does not need to be geographically accurate)

---

### REQ-9.2: Stand Filtering

**Description:** Filter visible stands by criteria.

**Acceptance Criteria:**
- [ ] Filter options: Aircraft code, Terminal, Equipment type, Status
- [ ] Filters apply instantly
- [ ] Filtered-out stands either hidden or greyed out (configurable)
- [ ] Active filter count shown
- [ ] Clear filters button

---

### REQ-9.3: Stand Detail Panel

**Description:** Show stand details when selected.

**Acceptance Criteria:**
- [ ] Panel appears on click (sidebar or popover)
- [ ] Shows all stand attributes
- [ ] Shows equipment status with check/cross indicators
- [ ] Shows current status and reason (if constrained or maintenance)
- [ ] Shows associated maintenance if any
- [ ] Edit button navigates to stand edit form
- [ ] Close button dismisses panel

---

### REQ-9.4: Legend

**Description:** Display legend explaining colour coding.

**Acceptance Criteria:**
- [ ] Legend visible on map view
- [ ] Shows: Available (green), Constrained (amber), Maintenance (red)
- [ ] Collapsible to save space

---

## 10. Timeline View

### REQ-10.1: Hourly Capacity Chart

**Description:** Display capacity over time as stacked area chart.

**Acceptance Criteria:**
- [ ] X-axis: hours (06:00 to 23:00 or configured operating hours)
- [ ] Y-axis: positions
- [ ] Stacked areas for Code C, E, F
- [ ] Responsive sizing
- [ ] Tooltip on hover showing exact values

---

### REQ-10.2: Capacity Heatmap

**Description:** Display capacity as a heatmap grid.

**Acceptance Criteria:**
- [ ] Rows: dates (configurable range, default 7 days)
- [ ] Columns: hours of day
- [ ] Cell colour intensity: Green (good), Amber (constrained), Red (critical)
- [ ] Colour thresholds configurable
- [ ] Click on cell shows breakdown for that hour
- [ ] Legend showing colour scale

---

### REQ-10.3: Date Range Selector

**Description:** Select time period for timeline view.

**Acceptance Criteria:**
- [ ] Options: Today, This Week, This Month, Custom Range
- [ ] Custom range shows date pickers for start and end
- [ ] View updates on selection

---

## 11. Reports and Export

### REQ-11.1: Capacity Summary Report

**Description:** Generate PDF report of current capacity.

**Acceptance Criteria:**
- [ ] Includes: theoretical capacity, live capacity, equipment capacity
- [ ] Includes: hourly profile chart
- [ ] Includes: active maintenance list
- [ ] Header: report title, date generated, date range covered
- [ ] Footer: page numbers

---

### REQ-11.2: Scenario Impact Report

**Description:** Generate PDF report of scenario analysis.

**Acceptance Criteria:**
- [ ] Includes: scenario definition (name, stands, period, reason)
- [ ] Includes: impact table (baseline, scenario, delta)
- [ ] Includes: hourly impact profile
- [ ] Includes: period comparison if applicable
- [ ] Filename: Scenario_[Name]_[Date].pdf

---

### REQ-11.3: Data Export

**Description:** Export raw data to Excel.

**Acceptance Criteria:**
- [ ] Export options: Stand Inventory, Maintenance Schedule, Capacity Data
- [ ] Excel format (.xlsx)
- [ ] Includes all fields
- [ ] Filename includes export type and date

---

## 12. Settings and Configuration

### REQ-12.1: Operating Parameters

**Description:** Configure global operating parameters.

**Acceptance Criteria:**
- [ ] Operating day start time (default 06:00)
- [ ] Operating day end time (default 23:00)
- [ ] Settings persisted
- [ ] Changes affect all calculations

---

### REQ-12.2: User Management (if applicable)

**Description:** Manage user access.

**Acceptance Criteria:**
- [ ] Roles: Viewer (read-only), Editor (CRUD stands/maintenance), Admin (all + settings)
- [ ] Admin can assign roles
- [ ] SSO integration (as per infrastructure requirements)

---

### REQ-12.3: Audit Log

**Description:** Track changes to data.

**Acceptance Criteria:**
- [ ] Log captures: action, entity, user, timestamp, before/after values
- [ ] Actions logged: create, update, delete for stands, maintenance, scenarios
- [ ] Log viewable by Admin users
- [ ] Log exportable
- [ ] Retention: minimum 12 months

---

## 13. Non-Functional Requirements

### REQ-NF-1: Performance

| Metric | Target |
|--------|--------|
| Page load time | < 2 seconds |
| Capacity calculation | < 3 seconds |
| Scenario calculation | < 5 seconds |
| Search/filter response | < 500ms |

---

### REQ-NF-2: Browser Support

| Browser | Version |
|---------|---------|
| Chrome | Latest 2 versions |
| Edge | Latest 2 versions |
| Safari | Latest 2 versions |
| Firefox | Latest 2 versions |

---

### REQ-NF-3: Responsive Design

- [ ] Fully functional on desktop (1280px+ width)
- [ ] Functional on tablet (768px+ width)
- [ ] Mobile not required for initial release

---

### REQ-NF-4: Accessibility

- [ ] WCAG 2.1 AA compliance
- [ ] Keyboard navigation for all functions
- [ ] Screen reader compatible
- [ ] Colour contrast meets accessibility standards

---

### REQ-NF-5: Data Validation

- [ ] All required fields enforced
- [ ] Type validation on all inputs
- [ ] Range validation where applicable
- [ ] Clear error messages indicating specific issue

---

## 14. Success Criteria

### Overall Delivery Success

| Criterion | Measure | Target |
|-----------|---------|--------|
| Functional completeness | All acceptance criteria pass | 100% |
| Test coverage | Unit and integration tests | > 80% |
| Performance | All performance targets met | 100% |
| Accessibility | WCAG 2.1 AA audit pass | Pass |
| User acceptance | UAT sign-off from key stakeholders | Obtained |

### Calculation Accuracy

| Criterion | Measure | Target |
|-----------|---------|--------|
| Capacity calculation accuracy | Compared against manual spreadsheet calculation | Within 5% |
| Scenario impact accuracy | Verified against manual scenario analysis | Exact match |
| Edge case handling | Tested with MARS, adjacency, partial-day maintenance | All pass |

### Usability

| Criterion | Measure | Target |
|-----------|---------|--------|
| Stand creation time | Time to add a new stand | < 2 minutes |
| Scenario analysis time | Time from question to answer | < 5 minutes |
| Learning curve | New user can perform core tasks | < 1 hour training |

### Reliability

| Criterion | Measure | Target |
|-----------|---------|--------|
| Data integrity | No data loss or corruption | Zero incidents |
| Calculation consistency | Same inputs produce same outputs | 100% |
| Error handling | Graceful handling of edge cases | No unhandled exceptions |

### Deployment Readiness

| Criterion | Measure | Target |
|-----------|---------|--------|
| Documentation | User guide and admin guide complete | Delivered |
| Deployment guide | Installation and configuration documented | Delivered |
| Data migration | Existing stand data imported successfully | Verified |
| Training | Key users trained on system | Completed |

---

## 15. Test Scenarios

### Calculation Test Cases

| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| TC-1: Basic capacity | 10 Code E stands, 17hr operating day, 75+20min turnaround | 10 positions, ~10 movements/stand/day |
| TC-2: MARS stand | 1 MARS stand (1×E or 2×C) | Counted as 1×E only |
| TC-3: Adjacency | Stand 80 (E) constrains Stand 81 to C | Stand 81 counted as C capacity |
| TC-4: Maintenance impact | Stand 80 out for maintenance | Live capacity = Theoretical - 1 Code E |
| TC-5: Partial day maintenance | Stand 80 out 08:00-12:00 | Hourly profile shows reduction only for those hours |
| TC-6: Cumulative maintenance | Stands 80 and 81 both out | Live capacity = Theoretical - 2 Code E |
| TC-7: Scenario delta | Scenario removes Stand 82 | Scenario shows -1 from Live (not from Theoretical) |

### Edge Case Test Cases

| Test Case | Scenario | Expected Behaviour |
|-----------|----------|-------------------|
| EC-1: All stands in maintenance | Every stand has active maintenance | Live capacity = 0, no errors |
| EC-2: Overlapping maintenance | Same stand, two maintenance records overlap | Stand counted as unavailable once (not twice) |
| EC-3: Midnight-spanning maintenance | Maintenance 22:00 to 06:00 next day | Correctly affects both days |
| EC-4: MARS with adjacency | MARS stand constrained by neighbour | Both rules applied (least flexible MARS config AND adjacency) |
| EC-5: Future date scenario | Scenario for date 6 months ahead | Calculation works with scheduled maintenance for that date |

---

## 16. Deliverables Checklist

### Code Deliverables

- [ ] Source code in version control (Git)
- [ ] Build scripts and configuration
- [ ] Database schema and migrations
- [ ] API documentation (if applicable)
- [ ] Unit tests
- [ ] Integration tests

### Documentation Deliverables

- [ ] User Guide
- [ ] Administrator Guide
- [ ] Deployment/Installation Guide
- [ ] API Documentation (if applicable)
- [ ] Data Dictionary

### Deployment Deliverables

- [ ] Deployed application (staging environment)
- [ ] Deployed application (production environment)
- [ ] Initial data load (stand inventory)
- [ ] Configuration documentation

### Training Deliverables

- [ ] Training materials/slides
- [ ] Training session(s) delivered
- [ ] Quick reference guide

---

*End of Document*
