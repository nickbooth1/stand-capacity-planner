# Agent Build Instructions

## Architecture Overview

This is a full-stack application with Docker-containerized services:

| Service   | Technology     | Port | Container Name |
|-----------|---------------|------|----------------|
| Frontend  | Next.js 14    | 3000 | scp-frontend   |
| Backend   | Node.js/Express | 3002 | scp-backend    |
| Database  | PostgreSQL 16 | 5432 | scp-postgres   |

## Quick Start

```bash
# Start all services (builds containers if needed)
./scripts/start.sh

# Check status of all services
./scripts/status.sh

# Stop all services
./scripts/stop.sh
```

## Access Points

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3002
- **API Health Check**: http://localhost:3002/api/health
- **Database**: localhost:5432 (database: stand_capacity, user: postgres)

## Project Setup

```bash
# Start all Docker containers (recommended - handles everything)
./scripts/start.sh

# Or manually with docker-compose
docker-compose up -d --build

# Install dependencies locally (for IDE support)
cd frontend && npm install
cd backend && npm install
```

## Running Tests

```bash
# Run all tests via Docker
./scripts/test.sh

# Run tests in specific container
docker-compose exec backend npm test
docker-compose exec frontend npm test

# Run E2E tests
docker-compose exec frontend npm run test:e2e

# Run with coverage
docker-compose exec backend npm run test:coverage
docker-compose exec frontend npm run test:coverage
```

## Build Commands

```bash
# Rebuild all containers
docker-compose build

# Rebuild specific service
docker-compose build frontend
docker-compose build backend

# Production build (frontend)
docker-compose exec frontend npm run build
```

## Development Server

```bash
# Start all services in development mode
./scripts/start.sh

# Or with docker-compose directly
docker-compose up -d

# View logs (all services)
./scripts/logs.sh

# View logs for specific service
./scripts/logs.sh frontend
./scripts/logs.sh backend
./scripts/logs.sh postgres
```

## Database Commands

```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U postgres -d stand_capacity

# Reset database (drops all data)
./scripts/reset-db.sh

# View database tables
docker-compose exec postgres psql -U postgres -d stand_capacity -c "\dt"

# Run migrations (when implemented)
docker-compose exec backend npm run db:migrate

# Seed database (when implemented)
docker-compose exec backend npm run db:seed
```

## E2E Validation Scripts

```bash
# Pre-build validation (run before any changes)
./scripts/e2e-validate.sh pre

# Post-build validation (run after completing a task)
./scripts/e2e-validate.sh post

# Quick status check
./scripts/status.sh
```

## Container Management

```bash
# View running containers
docker-compose ps

# Restart a specific service
docker-compose restart frontend
docker-compose restart backend

# View container logs
docker-compose logs -f frontend
docker-compose logs -f backend

# Execute command in container
docker-compose exec backend sh
docker-compose exec frontend sh
docker-compose exec postgres psql -U postgres

# Stop and remove all containers + volumes (clean slate)
docker-compose down -v
```

## E2E Validation Requirements

**MANDATORY**: All build activities and task completions require E2E validation testing.

### Pre-Build Validation

Before starting ANY build activity (install, compile, deploy, etc.), you MUST:

1. **Verify Application Health**:
   - Start the application/development server
   - Navigate to the application as a human user would (browser, API client, CLI)
   - Confirm the application loads and responds correctly
   - Check that core functionality is accessible

2. **Run Baseline E2E Test**:
   ```bash
   # Run the E2E validation script
   ./scripts/e2e-validate.sh pre

   # Or run E2E tests directly
   docker-compose exec frontend npm run test:e2e
   ```

3. **Document Current State**:
   - Note any existing issues before making changes
   - Capture baseline behavior for comparison after changes

### Post-Task Validation

After completing ANY task and before marking it complete, you MUST:

1. **Test as a Human User Would**:
   - Open the application in a browser/client
   - Manually walk through the user workflow affected by your changes
   - Verify the acceptance criteria by actually using the feature
   - Check edge cases a real user might encounter

2. **Validate Acceptance Criteria**:
   - For each acceptance criterion, perform the exact user action described
   - Confirm the expected outcome occurs
   - Screenshot or document the validation if helpful

3. **Run Full E2E Suite**:
   ```bash
   # Run post-task validation
   ./scripts/e2e-validate.sh post

   # Or run E2E tests directly
   docker-compose exec frontend npm run test:e2e
   ```

4. **Cross-Browser/Device Check** (if applicable):
   - Test in multiple browsers if it's a web application
   - Verify responsive behavior on different screen sizes

### Human-Like Testing Approach

When testing as a human user:
- **Don't just check if code runs** - verify the UX is correct
- **Click through flows manually** - use the UI, don't just call APIs
- **Look for visual issues** - layout, spacing, colors, loading states
- **Test error states** - what happens with invalid input?
- **Check performance** - does it feel responsive?
- **Verify accessibility** - can you tab through forms? Are labels clear?

### E2E Test Failure Protocol

If E2E tests fail at any point:
1. **Stop** - do not proceed with further changes
2. **Diagnose** - identify the root cause
3. **Fix** - resolve the issue before continuing
4. **Re-validate** - run E2E tests again to confirm the fix
5. **Document** - note what caused the failure in Key Learnings

## Key Learnings
- Update this section when you learn new build optimizations
- Document any gotchas or special setup requirements
- Keep track of the fastest test/build cycle

## Feature Development Quality Standards

**CRITICAL**: All new features MUST meet the following mandatory requirements before being considered complete.

### Testing Requirements

- **Minimum Coverage**: 85% code coverage ratio required for all new code
- **Test Pass Rate**: 100% - all tests must pass, no exceptions
- **Test Types Required**:
  - Unit tests for all business logic and services
  - Integration tests for API endpoints or main functionality
  - End-to-end tests for critical user workflows
- **Coverage Validation**: Run coverage reports before marking features complete:
  ```bash
  # Examples by language/framework
  npm run test:coverage
  pytest --cov=src tests/ --cov-report=term-missing
  cargo tarpaulin --out Html
  ```
- **Test Quality**: Tests must validate behavior, not just achieve coverage metrics
- **Test Documentation**: Complex test scenarios must include comments explaining the test strategy

### Git Workflow Requirements

Before moving to the next feature, ALL changes must be:

1. **Committed with Clear Messages**:
   ```bash
   git add .
   git commit -m "feat(module): descriptive message following conventional commits"
   ```
   - Use conventional commit format: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, etc.
   - Include scope when applicable: `feat(api):`, `fix(ui):`, `test(auth):`
   - Write descriptive messages that explain WHAT changed and WHY

2. **Pushed to Remote Repository**:
   ```bash
   git push origin <branch-name>
   ```
   - Never leave completed features uncommitted
   - Push regularly to maintain backup and enable collaboration
   - Ensure CI/CD pipelines pass before considering feature complete

3. **Branch Hygiene**:
   - Work on feature branches, never directly on `main`
   - Branch naming convention: `feature/<feature-name>`, `fix/<issue-name>`, `docs/<doc-update>`
   - Create pull requests for all significant changes

4. **Ralph Integration**:
   - Update @fix_plan.md with new tasks before starting work
   - Mark items complete in @fix_plan.md upon completion
   - Update PROMPT.md if development patterns change
   - Test features work within Ralph's autonomous loop

### Documentation Requirements

**ALL implementation documentation MUST remain synchronized with the codebase**:

1. **Code Documentation**:
   - Language-appropriate documentation (JSDoc, docstrings, etc.)
   - Update inline comments when implementation changes
   - Remove outdated comments immediately

2. **Implementation Documentation**:
   - Update relevant sections in this AGENT.md file
   - Keep build and test commands current
   - Update configuration examples when defaults change
   - Document breaking changes prominently

3. **README Updates**:
   - Keep feature lists current
   - Update setup instructions when dependencies change
   - Maintain accurate command examples
   - Update version compatibility information

4. **AGENT.md Maintenance**:
   - Add new build patterns to relevant sections
   - Update "Key Learnings" with new insights
   - Keep command examples accurate and tested
   - Document new testing patterns or quality gates

### Feature Completion Checklist

Before marking ANY feature as complete, verify:

- [ ] Pre-build E2E validation passed (application health confirmed)
- [ ] All tests pass with appropriate framework command
- [ ] Code coverage meets 85% minimum threshold
- [ ] Coverage report reviewed for meaningful test quality
- [ ] Code formatted according to project standards
- [ ] Type checking passes (if applicable)
- [ ] **Post-task E2E validation completed**:
  - [ ] Manually tested as a human user would
  - [ ] Walked through affected user workflows in browser/client
  - [ ] Acceptance criteria verified through actual usage
  - [ ] Edge cases tested
- [ ] Full E2E test suite passes (no regressions)
- [ ] All changes committed with conventional commit messages
- [ ] All commits pushed to remote repository
- [ ] @fix_plan.md task marked as complete
- [ ] Implementation documentation updated
- [ ] Inline code comments updated or added
- [ ] AGENT.md updated (if new patterns introduced)
- [ ] Breaking changes documented
- [ ] Features tested within Ralph loop (if applicable)
- [ ] CI/CD pipeline passes

### Rationale

These standards ensure:
- **Quality**: High test coverage and pass rates prevent regressions
- **Traceability**: Git commits and @fix_plan.md provide clear history of changes
- **Maintainability**: Current documentation reduces onboarding time and prevents knowledge loss
- **Collaboration**: Pushed changes enable team visibility and code review
- **Reliability**: Consistent quality gates maintain production stability
- **Automation**: Ralph integration ensures continuous development practices

**Enforcement**: AI agents should automatically apply these standards to all feature development tasks without requiring explicit instruction for each task.
