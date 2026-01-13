# Ralph Fix Plan - Stand Capacity Planning Tool

> **Task Size Guideline**: Each task should be completable in ONE loop iteration (single context window).
> Tasks are atomic - implement, test, validate, commit in one go.

---

## Phase 1A: Database Schema - Stands (REQ-1.6)

### Stands Table Schema
- [x] Create migration file `02-stands-schema.sql` with full stands table
- [x] Add columns: stand_id (PK), max_aircraft_code (enum C/E/F), max_wingspan, max_length
- [x] Add columns: contact_remote (enum), terminal, domestic_international (enum)
- [x] Add columns: operating_hours_start, operating_hours_end (TIME)
- [x] Add columns: avdgs, fegp, pca, fuel_hydrant (BOOLEAN)
- [x] Add optional columns: pier, jet_bridge_count, jet_bridge_type, notes
- [x] Add timestamps: created_at, updated_at with trigger
- [x] Add indexes on: terminal, max_aircraft_code, status
- [x] Run migration and verify tables exist in database
- [ ] Remove sample data from 01-init.sql (will use proper seed data)

---

## Phase 1B: Database Schema - Supporting Tables

### MARS Configurations (REQ-2.1)
- [ ] Create migration `03-mars-schema.sql` with mars_configurations table
- [ ] Add columns: id, stand_id (FK), config_name, positions_count, aircraft_codes (array)
- [ ] Add columns: child_stand_ids (array), is_default_config
- [ ] Add constraint: at least 2 configurations per MARS stand

### Adjacency Dependencies (REQ-3.1)
- [ ] Create migration `04-adjacency-schema.sql` with adjacency_dependencies table
- [ ] Add columns: id, primary_stand_id (FK), trigger_condition (enum)
- [ ] Add columns: affected_stand_ids (array), constraint_applied (enum)
- [ ] Add enum types for trigger conditions and constraints

### Turnaround Times (REQ-4.1)
- [ ] Create migration `05-turnaround-schema.sql` with turnaround_times table
- [ ] Add columns: id, aircraft_code (enum), turnaround_minutes, buffer_minutes
- [ ] Insert default values: C=45/15, E=75/20, F=90/25

### Maintenance Records (REQ-5.1)
- [ ] Create migration `06-maintenance-schema.sql` with maintenance_records table
- [ ] Add columns: id, stand_ids (array), start_datetime, end_datetime
- [ ] Add columns: maintenance_type (enum: Planned/Emergency/Reactive)
- [ ] Add columns: description, equipment_affected (array)
- [ ] Add columns: recurrence_pattern, parent_maintenance_id
- [ ] Add indexes on: start_datetime, maintenance_type

### Scenarios (REQ-7.1)
- [ ] Create migration `07-scenarios-schema.sql` with scenarios table
- [ ] Add columns: id, name, stand_ids (array), start_date, end_date
- [ ] Add columns: description, created_at, calculated_impact (JSONB)

### Settings & Audit (REQ-12.x)
- [ ] Create migration `08-settings-schema.sql` with settings table
- [ ] Add columns: key, value (JSONB), updated_at
- [ ] Insert defaults: operating_hours_start=06:00, operating_hours_end=23:00
- [ ] Create migration `09-audit-log-schema.sql` with audit_log table
- [ ] Add columns: id, action, entity_type, entity_id, user_id
- [ ] Add columns: timestamp, before_value (JSONB), after_value (JSONB)

---

## Phase 1C: Backend API - Stand CRUD

### GET /api/stands (REQ-1.2)
- [ ] Create `backend/src/routes/stands.js` router file
- [ ] Implement GET /api/stands - return all stands from database
- [ ] Add query params: search (filters by stand_id, terminal, pier)
- [ ] Add query params: sort_by, sort_order (asc/desc)
- [ ] Add query params: page, limit for pagination
- [ ] Add unit test for GET /api/stands endpoint
- [ ] Register router in main index.js

### POST /api/stands (REQ-1.1)
- [ ] Implement POST /api/stands - create new stand
- [ ] Add validation: all required fields present
- [ ] Add validation: stand_id is unique
- [ ] Add validation: max_wingspan and max_length > 0
- [ ] Add validation: operating_hours_end > operating_hours_start
- [ ] Return 201 with created stand, or 400 with validation errors
- [ ] Add unit test for POST /api/stands with valid data
- [ ] Add unit test for POST /api/stands with invalid data

### GET /api/stands/:id
- [ ] Implement GET /api/stands/:id - return single stand
- [ ] Return 404 if stand not found
- [ ] Add unit test for GET /api/stands/:id

### PUT /api/stands/:id (REQ-1.3)
- [ ] Implement PUT /api/stands/:id - update stand
- [ ] Prevent changing stand_id field
- [ ] Apply same validation as POST
- [ ] Return 200 with updated stand, or 400/404 with errors
- [ ] Add unit test for PUT /api/stands/:id

### DELETE /api/stands/:id (REQ-1.4)
- [ ] Implement DELETE /api/stands/:id - delete stand
- [ ] Check for associated maintenance records
- [ ] If maintenance exists: return warning in response
- [ ] Delete with cascade or return 409 if dependencies exist
- [ ] Add unit test for DELETE /api/stands/:id

---

## Phase 1D: Backend API - Bulk Import

### POST /api/stands/import (REQ-1.5)
- [ ] Install multer for file uploads
- [ ] Install xlsx library for Excel parsing
- [ ] Create file upload endpoint POST /api/stands/import
- [ ] Parse CSV files and extract rows
- [ ] Parse XLSX files and extract rows
- [ ] Validate all rows before inserting any
- [ ] Return validation errors with row numbers
- [ ] Insert all valid rows in transaction
- [ ] Add unit test for CSV import
- [ ] Add unit test for XLSX import
- [ ] Add unit test for validation error reporting

### GET /api/stands/template
- [ ] Create CSV template with all required columns
- [ ] Implement GET /api/stands/template - download template
- [ ] Add unit test for template download

---

## Phase 1E: Frontend - Stand List Page (REQ-1.2)

### Basic List View
- [ ] Create `frontend/app/stands/page.tsx` - stands list page
- [ ] Fetch stands from API using useEffect
- [ ] Display stands in HTML table with columns: ID, Aircraft Code, Terminal, Pier
- [ ] Add columns: Contact/Remote, AVDGS, FEGP, Hydrant, Status
- [ ] Style table with basic CSS

### Sorting
- [ ] Add clickable column headers for sorting
- [ ] Track sort column and direction in state
- [ ] Re-fetch with sort params when header clicked
- [ ] Show sort indicator (arrow) on active column

### Search/Filter
- [ ] Add search input above table
- [ ] Debounce search input (300ms)
- [ ] Filter by stand_id, terminal, or pier
- [ ] Clear search button

### Pagination
- [ ] Add pagination controls below table
- [ ] Show current page and total pages
- [ ] Previous/Next buttons
- [ ] Items per page selector (10, 25, 50, 100)

### Row Click Navigation
- [ ] Add onClick handler to table rows
- [ ] Navigate to stand detail page on click

---

## Phase 1F: Frontend - Stand Create/Edit Form (REQ-1.1, REQ-1.3)

### Create Stand Form
- [ ] Create `frontend/app/stands/new/page.tsx` - new stand form
- [ ] Add form fields for all required stand attributes
- [ ] Add dropdown for max_aircraft_code (C, E, F)
- [ ] Add dropdown for contact_remote (Contact, Remote)
- [ ] Add dropdown for domestic_international
- [ ] Add time pickers for operating hours
- [ ] Add checkboxes for AVDGS, FEGP, PCA, Fuel Hydrant
- [ ] Add optional fields: pier, jet_bridge_count, notes

### Form Validation (Client-side)
- [ ] Validate required fields before submit
- [ ] Validate wingspan and length are positive numbers
- [ ] Validate operating_hours_end > start
- [ ] Show inline error messages

### Form Submission
- [ ] Submit form to POST /api/stands
- [ ] Show loading state during submission
- [ ] Show success message and redirect to list
- [ ] Show API validation errors if any

### Edit Stand Form
- [ ] Create `frontend/app/stands/[id]/edit/page.tsx` - edit form
- [ ] Fetch existing stand data on mount
- [ ] Pre-populate form with existing values
- [ ] Disable stand_id field (not editable)
- [ ] Submit to PUT /api/stands/:id
- [ ] Add Cancel button that returns to list

---

## Phase 1G: Frontend - Stand Delete (REQ-1.4)

### Delete Confirmation
- [ ] Add Delete button to stand detail/edit page
- [ ] Create confirmation modal component
- [ ] Show warning message: "Are you sure? This cannot be undone."
- [ ] If maintenance records exist, show additional warning
- [ ] Cancel and Confirm buttons

### Delete Action
- [ ] Call DELETE /api/stands/:id on confirm
- [ ] Show loading state
- [ ] Redirect to list on success
- [ ] Show error message on failure

---

## Phase 1H: Frontend - Bulk Import (REQ-1.5)

### Import UI
- [ ] Create `frontend/app/stands/import/page.tsx` - import page
- [ ] Add download template button (calls GET /api/stands/template)
- [ ] Add file upload dropzone (accepts .csv, .xlsx)
- [ ] Preview selected file name

### Import Process
- [ ] Submit file to POST /api/stands/import
- [ ] Show progress/loading indicator
- [ ] On success: show count of stands created, redirect to list
- [ ] On validation errors: display table of errors with row numbers
- [ ] Allow user to fix file and re-upload

---

## Phase 2A: MARS Configuration (REQ-2.x)

### MARS API
- [ ] Create `backend/src/routes/mars.js` router
- [ ] GET /api/stands/:id/mars - get MARS configs for stand
- [ ] POST /api/stands/:id/mars - add MARS config
- [ ] PUT /api/mars/:configId - update MARS config
- [ ] DELETE /api/mars/:configId - delete MARS config
- [ ] Validate: at least 2 configs for MARS stand

### MARS UI
- [ ] Add "MARS Capable" toggle to stand form
- [ ] When enabled, show MARS configuration section
- [ ] Form to add configuration: positions, aircraft codes, child IDs
- [ ] List existing configurations with edit/delete
- [ ] Validate child stand IDs don't conflict

### MARS Calculation Logic
- [ ] Create `backend/src/services/capacity.js`
- [ ] Function: getMarsEffectiveCapacity(stand)
- [ ] Returns least flexible configuration
- [ ] Add unit tests for MARS calculation

---

## Phase 2B: Adjacency Dependencies (REQ-3.x)

### Adjacency API
- [ ] Create `backend/src/routes/adjacency.js` router
- [ ] GET /api/adjacency - list all dependencies
- [ ] POST /api/adjacency - create dependency
- [ ] PUT /api/adjacency/:id - update dependency
- [ ] DELETE /api/adjacency/:id - delete dependency
- [ ] Add filtering by primary_stand_id

### Adjacency UI
- [ ] Create `frontend/app/adjacency/page.tsx` - list page
- [ ] Table: Primary Stand, Trigger, Affected Stands, Constraint
- [ ] Add/Edit form with dropdowns for trigger and constraint
- [ ] Multi-select for affected stands

### Adjacency Calculation Logic
- [ ] Function: applyAdjacencyConstraints(stands)
- [ ] Downgrade affected stands to constrained capability
- [ ] Add unit tests for adjacency logic

---

## Phase 2C: Turnaround Times (REQ-4.x)

### Turnaround API
- [ ] GET /api/settings/turnaround - get all turnaround times
- [ ] PUT /api/settings/turnaround - update turnaround times
- [ ] Validate: positive integers only

### Turnaround UI
- [ ] Create `frontend/app/settings/turnaround/page.tsx`
- [ ] Editable table: Aircraft Code, Turnaround (mins), Buffer (mins)
- [ ] Save button to persist changes
- [ ] Show confirmation on save

### Movements Calculation
- [ ] Function: calculateMovementsPerDay(stand, turnaroundTimes)
- [ ] Formula: Operating Hours ÷ (Turnaround + Buffer)
- [ ] Add unit tests with example from spec

---

## Phase 2D: Maintenance Management (REQ-5.x)

### Maintenance API - CRUD
- [ ] Create `backend/src/routes/maintenance.js` router
- [ ] GET /api/maintenance - list with filters (status, type, stand, date range)
- [ ] POST /api/maintenance - create with validation
- [ ] GET /api/maintenance/:id - get single record
- [ ] PUT /api/maintenance/:id - update
- [ ] DELETE /api/maintenance/:id - delete with confirmation

### Maintenance List UI (REQ-5.2)
- [ ] Create `frontend/app/maintenance/page.tsx` - list page
- [ ] Table: Stands, Period, Type, Description, Equipment, Status
- [ ] Status badges: Active (green), Upcoming (blue), Completed (grey)
- [ ] Filters: status, type, stand dropdown, date range picker
- [ ] Click row to open detail

### Maintenance Form (REQ-5.1, REQ-5.3)
- [ ] Create form for new/edit maintenance
- [ ] Multi-select for stands affected
- [ ] Date/time pickers for start and end
- [ ] Dropdown for type: Planned, Emergency, Reactive
- [ ] Multi-select for equipment: AVDGS, FEGP, PCA, Hydrant, Jet Bridge, Full Stand
- [ ] Textarea for description
- [ ] Validate: end > start
- [ ] Warn on overlapping maintenance (same stand)

### Recurring Maintenance (REQ-5.5)
- [ ] Add recurrence options to maintenance form
- [ ] Options: None, Weekly, Fortnightly, Monthly
- [ ] Day of week selector (for weekly)
- [ ] Generate individual instances on save
- [ ] Link instances to parent pattern
- [ ] Edit pattern updates future instances only

### Maintenance Calendar (REQ-5.6)
- [ ] Create `frontend/app/maintenance/calendar/page.tsx`
- [ ] Monthly grid view using a calendar component
- [ ] Display maintenance blocks on relevant days
- [ ] Color coding: Planned=blue, Emergency=red, Recurring=purple
- [ ] Click block shows details popover
- [ ] Previous/Next month navigation
- [ ] Today button

---

## Phase 3: Capacity Calculations (REQ-6.x)
*Tasks to be broken down when Phase 2 is complete*

---

## Phase 4: Scenario Analysis (REQ-7.x)
*Tasks to be broken down when Phase 3 is complete*

---

## Phase 5: Dashboard & Visualizations (REQ-8.x, 9.x, 10.x)
*Tasks to be broken down when Phase 4 is complete*

---

## Phase 6: Reports & Export (REQ-11.x)
*Tasks to be broken down when Phase 5 is complete*

---

## Phase 7: Settings & Polish (REQ-12.x, NF)
*Tasks to be broken down when Phase 6 is complete*

---

## Completed
- [x] Project initialization
- [x] Docker environment setup (frontend, backend, postgres)
- [x] Basic database schema (stands, capacity_plans, capacity_events)
- [x] Health check API endpoint
- [x] Basic frontend with health status display
- [x] Development scripts (start, stop, status, logs, reset-db, e2e-validate)
- [x] @AGENT.md with Docker commands and E2E validation requirements
- [x] PROMPT.md with full requirements specification and E2E loop instructions

---

## Notes

### Task Sizing
- Each checkbox = ONE loop iteration
- Complete, test, validate E2E, commit before next task
- If a task takes more than one loop, break it down further

### E2E Validation Per Loop
1. START: `./scripts/e2e-validate.sh pre`
2. Implement task
3. END: `./scripts/e2e-validate.sh post`
4. Manual browser testing
5. Commit and mark complete

### Dependencies
- Phase 1A-1B (Database) must complete before 1C-1H (API/UI)
- Phase 2 depends on Phase 1 complete
- Later phases will be broken down as we approach them
