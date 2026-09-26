# CampusOps AI — Day 6 Progress Log

**Date:** Day 6 of 30-day development plan
**Branch:** feature/backend
**Status:** ✅ Complete

---

## What Was Done

### 1. Files Created/Updated

```
backend/
└── app/
    ├── core/
    │   └── dependencies.py     ← NEW: JWT middleware + role guards
    ├── models/
    │   ├── __init__.py         ← UPDATED: all models imported
    │   ├── location.py         ← NEW: Location SQLAlchemy model
    │   ├── asset.py            ← NEW: Asset SQLAlchemy model
    │   └── ticket.py           ← NEW: Ticket + TicketHistory models
    ├── schemas/
    │   └── ticket.py           ← NEW: Ticket Pydantic schemas
    ├── api/
    │   ├── auth.py             ← UPDATED: /me endpoint complete
    │   └── tickets.py          ← NEW: All ticket endpoints
    └── main.py                 ← UPDATED: tickets router added
```

---

### 2. JWT Middleware (`app/core/dependencies.py`)

| Function | Purpose |
|---|---|
| `get_current_user()` | Extract + verify JWT token, return User |
| `require_role(*roles)` | Role checker factory function |
| `get_admin()` | Shortcut — ADMIN only |
| `get_supervisor_or_admin()` | Shortcut — SUPERVISOR or ADMIN |
| `get_technician_or_above()` | Shortcut — TECHNICIAN, SUPERVISOR, ADMIN |

---

### 3. New Models

#### Location Model (`app/models/location.py`)
- Maps to `locations` table
- Fields: building, floor, room, location_type, description
- ENUM: CLASSROOM, LABORATORY, HOSTEL, OFFICE, CANTEEN, LIBRARY, GARDEN, PARKING, CORRIDOR, WASHROOM, OTHER

#### Asset Model (`app/models/asset.py`)
- Maps to `assets` table
- Fields: asset_code, name, category, location_id, department_id, purchase_date, warranty_end, status, last_maintenance
- ENUM: WORKING, UNDER_MAINTENANCE, BROKEN, REPLACED, DISPOSED

#### Ticket Model (`app/models/ticket.py`)
- Maps to `tickets` table
- ENUMs: TicketStatus (10 states), TicketPriority (4 levels), TicketCategory (9 categories)
- AI fields: ai_category, ai_category_confidence, ai_priority, ai_priority_confidence
- Duplicate fields: is_duplicate, duplicate_of, duplicate_similarity
- SLA fields: due_at, escalation_level
- Relationships: reporter, assignee, department, history

#### TicketHistory Model
- Maps to `ticket_history` table
- Records every status change with who changed it and when

---

### 4. Ticket Schemas (`app/schemas/ticket.py`)

| Schema | Purpose |
|---|---|
| `TicketCreate` | Create request (title, description, category, priority, location_id) |
| `TicketUpdate` | Partial update (any field optional) |
| `TicketAssign` | Assign request (department_id, technician_id) |
| `TicketResolve` | Resolve request (resolution_notes required) |
| `TicketResponse` | Full ticket response |
| `TicketListResponse` | Paginated list with total count |

---

### 5. Ticket Endpoints (`app/api/tickets.py`)

| Endpoint | Method | Auth | Role | Status |
|---|---|---|---|---|
| `/tickets/` | POST | ✅ | Any | ✅ 201 |
| `/tickets/` | GET | ✅ | Any (filtered by role) | ✅ 200 |
| `/tickets/{id}` | GET | ✅ | Any (filtered by role) | ✅ 200 |
| `/tickets/{id}` | PATCH | ✅ | Any | ✅ 200 |
| `/tickets/{id}` | DELETE | ✅ | ADMIN/SUPERVISOR | ✅ 204 |
| `/tickets/{id}/assign` | POST | ✅ | TECHNICIAN+ | ✅ 200 |
| `/tickets/{id}/accept` | POST | ✅ | TECHNICIAN+ | ✅ 200 |
| `/tickets/{id}/start` | POST | ✅ | TECHNICIAN+ | ✅ 200 |
| `/tickets/{id}/resolve` | POST | ✅ | TECHNICIAN+ | ✅ 200 |

---

### 6. Business Logic Implemented

#### Ticket Number Generation
```python
def generate_ticket_number(db):
    count = db.query(Ticket).count()
    return f"TKT-{str(count + 1).zfill(4)}"
# Example: TKT-0001, TKT-0002
```

#### SLA Due Date Calculation
```python
def calculate_due_date(priority, department_id, db):
    # Fetches SLA hours from department config
    # LOW→48hr, MEDIUM→24hr, HIGH→4-8hr, CRITICAL→1-4hr
    return datetime.utcnow() + timedelta(hours=sla_hours)
```

#### Role-Based Ticket Filtering
```
STUDENT     → sees only own tickets
TECHNICIAN  → sees only assigned tickets
SUPERVISOR  → sees department tickets
ADMIN       → sees all tickets
```

#### Status Transition Validation
```
ASSIGNED   → ACCEPTED  (technician accepts)
ACCEPTED   → IN_PROGRESS (technician starts)
IN_PROGRESS → RESOLVED (technician resolves)
```

#### Ticket History Logging
Every status change automatically logged to `ticket_history` table with:
- old_status, new_status
- changed_by (user id)
- comment
- timestamp

---

### 7. Auth Endpoint Updated

`GET /auth/me` — now fully implemented with JWT middleware:
```python
@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user
```

---

### 8. Full Test Results

| Endpoint | Status Code | Result |
|---|---|---|
| POST /auth/login | 200 OK | ✅ Token received |
| POST /tickets/ | 201 Created | ✅ TKT-0001 created |
| GET /tickets/ | 200 OK | ✅ List returned |
| GET /tickets/1 | 200 OK | ✅ Ticket detail returned |
| POST /tickets/1/assign | 200 OK | ✅ Assigned to IT dept |
| POST /tickets/1/accept | 200 OK | ✅ Status → ACCEPTED |
| POST /tickets/1/start | 200 OK | ✅ Status → IN_PROGRESS |
| POST /tickets/1/resolve | 200 OK | ✅ Status → RESOLVED |

---

## Issues Faced & Fixed

| Issue | Fix |
|---|---|
| `NoReferencedTableError: assets table not found` | Created `Location` and `Asset` SQLAlchemy models |
| `403 Forbidden on /assign` | User role was STUDENT — updated to ADMIN via pgAdmin SQL |
| Multiple model files were empty | Pasted content into each file individually |

---

## Key Design Decisions

| Decision | Reason |
|---|---|
| `require_role()` factory function | Reusable role guard for any combination of roles |
| Role-based ticket filtering in GET | Students can't see other students' tickets |
| Status transition validation | Prevents invalid state changes (e.g., OPEN → RESOLVED) |
| History logged on every transition | Full audit trail for compliance |
| SLA calculated from department config | Admin can change SLA without code changes |
| `zfill(4)` for ticket numbers | Consistent TKT-0001 format |

---

## API Endpoints Status After Day 6

| Endpoint | Method | Status |
|---|---|---|
| `/` | GET | ✅ |
| `/health` | GET | ✅ |
| `/auth/register` | POST | ✅ |
| `/auth/login` | POST | ✅ |
| `/auth/me` | GET | ✅ |
| `/tickets/` | POST | ✅ |
| `/tickets/` | GET | ✅ |
| `/tickets/{id}` | GET | ✅ |
| `/tickets/{id}` | PATCH | ✅ |
| `/tickets/{id}` | DELETE | ✅ |
| `/tickets/{id}/assign` | POST | ✅ |
| `/tickets/{id}/accept` | POST | ✅ |
| `/tickets/{id}/start` | POST | ✅ |
| `/tickets/{id}/resolve` | POST | ✅ |

---

## Next — Day 7

**Goal:** Full backend testing with Swagger/Postman

**Tasks:**
- Test all endpoints systematically
- Test invalid inputs (validation errors)
- Test unauthorized access (403 checks)
- Test wrong status transitions (400 checks)
- Test duplicate email registration
- Create multiple test users (Student, Technician, Supervisor, Admin)
- Verify ticket history is being saved
- Fix any bugs found

---

*Log created for documentation and portfolio reference.*
