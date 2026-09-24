# CampusOps AI — Day 3 Progress Log

**Date:** Day 3 of 30-day development plan
**Branch:** develop
**Status:** ✅ Complete

---

## What Was Done

### 1. PostgreSQL + pgAdmin Setup via Docker

Added services to `docker-compose.yml`:

```yaml
services:
  postgres:
    image: postgres:15
    container_name: campusops_db
    restart: always
    environment:
      POSTGRES_DB: campusops
      POSTGRES_USER: campusops_user
      POSTGRES_PASSWORD: campusops_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/migrations:/docker-entrypoint-initdb.d
    networks:
      - campusops_network

  pgadmin:
    image: dpage/pgadmin4
    container_name: campusops_pgadmin
    restart: always
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@campusops.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "5050:80"
    depends_on:
      - postgres
    networks:
      - campusops_network
```

**Command used:**
```bash
docker-compose up -d postgres pgadmin
```

**Result:** Both containers started successfully
- `campusops_db` — PostgreSQL running on port 5432
- `campusops_pgadmin` — pgAdmin running on port 5050

---

### 2. pgAdmin Connection

- URL: `http://127.0.0.1:5050/browser/`
- Login: `admin@campusops.com` / `admin123`

**Issue faced:** `campusops_db` hostname not accepted
**Fix:** Used container IP address from Docker inspect

```bash
docker inspect campusops_db
# Found IPAddress: 172.18.0.3
```

**Connection settings used:**
```
Host:     172.18.0.3
Port:     5432
Database: campusops
Username: campusops_user
Password: campusops_pass
```

---

### 3. Complete Database Schema Created

**File:** `database/migrations/schema.sql`

#### Tables Created (9 tables)

| Table | Purpose |
|---|---|
| `departments` | 8 departments with SLA hours per priority |
| `users` | All roles — Student, Technician, Supervisor, Admin |
| `locations` | 20 campus locations across buildings |
| `assets` | Equipment tracking with status |
| `tickets` | Main ticket table with AI fields + duplicate detection |
| `ticket_history` | Full audit trail of every status change |
| `notifications` | Email/Telegram/WhatsApp notification log |
| `feedback` | Student rating (1–5) + comment after resolution |
| `audit_logs` | Enterprise-style action logging with JSONB |

#### ENUM Types Created (6 types)

| Type | Values |
|---|---|
| `user_role` | STUDENT, TECHNICIAN, SUPERVISOR, ADMIN |
| `ticket_status` | OPEN, AI_PROCESSED, ASSIGNED, ACCEPTED, IN_PROGRESS, RESOLVED, CLOSED, CANCELLED, REJECTED, ESCALATED |
| `ticket_priority` | LOW, MEDIUM, HIGH, CRITICAL |
| `ticket_category` | IT, ELECTRICAL, PLUMBING, CIVIL, HOUSEKEEPING, SECURITY, CANTEEN, HORTICULTURE, OTHER |
| `notification_channel` | EMAIL, TELEGRAM, WHATSAPP, IN_APP |
| `asset_status` | WORKING, UNDER_MAINTENANCE, BROKEN, REPLACED, DISPOSED |

#### Indexes Created (11 indexes)
- tickets: status, priority, category, reported_by, assigned_to, assigned_department, created_at
- ticket_history: ticket_id
- notifications: user_id
- audit_logs: user_id, entity

---

### 4. Seed Data Inserted

#### 8 Departments with SLA Hours

| Department | Low SLA | Medium SLA | High SLA | Critical SLA |
|---|---|---|---|---|
| IT & Network | 48hr | 24hr | 4hr | 2hr |
| Electrical | 48hr | 24hr | 4hr | 1hr |
| Plumbing | 48hr | 24hr | 6hr | 2hr |
| Civil & Infrastructure | 48hr | 24hr | 8hr | 4hr |
| Housekeeping | 48hr | 12hr | 4hr | 3hr |
| Security | 24hr | 12hr | 2hr | 1hr |
| Canteen & Mess | 48hr | 24hr | 4hr | 2hr |
| Horticulture | 48hr | 24hr | 8hr | 4hr |

#### 20 Campus Locations

| Building | Type |
|---|---|
| Main Building (5 rooms) | CLASSROOM |
| Computer Lab Block (3 labs) | LABORATORY |
| Science Block (2 labs) | LABORATORY |
| Hostel Block A (2 locations) | HOSTEL |
| Hostel Block B (2 locations) | HOSTEL |
| Admin Block | OFFICE |
| Library | LIBRARY |
| Canteen | CANTEEN |
| Campus Ground (3 areas) | OTHER/PARKING/GARDEN |

#### 1 Default Admin User
```
Name:  Campus Admin
Email: admin@campus.edu
Role:  ADMIN
Note:  Password hash is placeholder — will be replaced by FastAPI bcrypt hash
```

---

### 5. Schema Verification Result

```
CampusOps AI Database Schema Created Successfully!
total_departments: 8
total_locations: 20
```

---

## Key Design Decisions

| Decision | Reason |
|---|---|
| SERIAL PRIMARY KEY (not UUID) | Simpler for MVP, easier to read in pgAdmin |
| ENUM types for status/priority/role | Prevents invalid data at database level |
| ON DELETE CASCADE for history/feedback | Clean deletion without orphan records |
| ON DELETE SET NULL for assignments | Ticket survives even if user is deleted |
| ON DELETE RESTRICT for reported_by | Cannot delete user who has tickets |
| JSONB for audit_logs old/new value | Flexible schema for any entity changes |
| Separate ticket_history table | Full audit trail, not just current status |
| AI fields in tickets table | category, priority, confidence scores stored |
| duplicate_of self-reference | Tickets can reference each other |
| escalation_level INTEGER | Tracks how many times ticket was escalated |

---

## Issues Faced & Fixed

| Issue | Fix |
|---|---|
| `campusops_db` hostname rejected by pgAdmin | Used container IP: `172.18.0.3` from `docker inspect` |

---

## File Created

```
campusops-ai/
└── database/
    └── migrations/
        └── schema.sql    ← Complete database schema
```

---

## pgAdmin Access (Local Development)

```
URL:      http://127.0.0.1:5050/browser/
Email:    admin@campusops.com
Password: admin123
```

---

## Docker Status After Day 3

```bash
docker ps
# campusops_db      → Up (PostgreSQL 15)
# campusops_pgadmin → Up (pgAdmin 4)
```

---

## Next — Day 4

**Goal:** FastAPI project structure + health endpoint

**Tasks:**
- Setup Python virtual environment
- Install FastAPI, Uvicorn, SQLAlchemy, Alembic
- Create FastAPI folder structure
- Implement `/health` endpoint
- Connect FastAPI to PostgreSQL
- Test with Swagger UI

---

*Log created for documentation and portfolio reference.*
