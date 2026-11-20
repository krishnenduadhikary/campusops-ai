# CampusOps AI — Day 10 Progress Log

**Date:** Day 10 of 30-day development plan
**Branch:** feature/frontend (backend fixes made on feature/backend and merged in)
**Status:** ✅ Complete

---

## What Was Done

Built the technician side of the application: a work dashboard with tabs, priority sorting and SLA badges, plus a ticket detail page where the technician can Accept, Start and Resolve a ticket.

Before building the UI, three gaps in the Day 6 backend code were fixed, and a timezone bug that affected every displayed time was corrected.

---

## 1. Backend Fixes (`app/api/tickets.py`)

| Problem found | Fix |
|---|---|
| A technician could call `assign` | `assign` now requires SUPERVISOR or ADMIN (`get_supervisor_or_admin`) |
| A technician could start or resolve another technician's ticket | New `ensure_can_work()` helper, called in `accept`, `start` and `resolve` |
| Tickets assigned to a department but to nobody never reached any technician | `list_tickets` now also returns unclaimed tickets of the technician's own department |

### `ensure_can_work(ticket, user)`
A technician may act on a ticket only if:
- it is assigned to them, or
- it is unclaimed and assigned to their department.

Otherwise the API returns `403 This ticket is not assigned to you`. Supervisors and admins are not restricted.

### Technician visibility in `GET /tickets/`
```
assigned_to == me
OR (assigned_department == my department AND assigned_to IS NULL)
```
The technician user was given `department_id = 1` in the database so the department queue works.

---

## 2. Timezone Bug Fix

**Problem:** The backend stores UTC but sends timestamps without a timezone suffix. The browser read them as local time, so times in IST were 5 hours 30 minutes behind. This was visible in the Day 9 timeline and would have made SLA countdowns wrong.

**Fix:** `src/utils/date.js` appends `Z` to timestamps that have no timezone before parsing.

- `parseDate(value)` returns a correct `Date`
- `formatDateTime(value)` returns a local date and time string
- Day 9 files (`StudentDashboard.jsx`, `TicketDetail.jsx`) were updated to use these helpers

---

## 3. Frontend Files Created

```
frontend/src/
├── utils/
│   ├── date.js                         ← NEW: UTC-safe date parsing
│   └── sla.js                          ← NEW: SLA countdown logic
├── components/common/
│   ├── SlaBadge.jsx                    ← NEW: Due in / Overdue badge
│   └── StatusTimeline.jsx              ← NEW: shared timeline component
├── services/
│   └── ticketService.js                ← UPDATED: accept, start, resolve
├── pages/technician/
│   ├── TechnicianDashboard.jsx         ← NEW
│   └── TechnicianTicketDetail.jsx      ← NEW
└── App.jsx                             ← UPDATED: technician routes
```

---

## 4. Features

### SLA Badge (`utils/sla.js`)
| State | Condition | Colour |
|---|---|---|
| Due in X | More than 60 minutes left | Green |
| Due in X | 60 minutes or less left | Orange |
| Overdue by X | Past `due_at` | Red |
| Completed | Ticket resolved, closed, cancelled or rejected | Grey |
| No SLA set | No `due_at` | Grey |

### Technician Dashboard (`/technician`)
- Stat cards: New, In progress, Overdue
- Tabs: **New** (ASSIGNED, ACCEPTED), **In progress** (IN_PROGRESS, ESCALATED), **Completed** (RESOLVED, CLOSED)
- Tickets sorted by priority (CRITICAL first), then by nearest due time
- Each row shows ticket number, title, location name, priority, status and SLA badge
- Empty, loading and error states

### Technician Ticket Detail (`/technician/tickets/:id`)
- Full ticket info with location name, category, submitted and due times
- Action area changes with the ticket status:

| Ticket status | Action shown |
|---|---|
| ASSIGNED | **Accept ticket** button |
| ACCEPTED | **Start work** button |
| IN_PROGRESS | Resolution notes box + **Mark as resolved** |
| RESOLVED / CLOSED | Resolution notes displayed |
| Any other status | "No action available" message |

- Buttons are disabled while a request is running
- Success and error toasts; page reloads ticket and timeline after each action
- Status timeline from ticket history

### Routing
| Route | Page | Roles |
|---|---|---|
| `/technician` | TechnicianDashboard | TECHNICIAN, ADMIN |
| `/technician/tickets/:id` | TechnicianTicketDetail | TECHNICIAN, ADMIN |

---

## 5. Testing Done

| Test | Result |
|---|---|
| Admin assigns ticket to technician via Swagger | ✅ |
| Technician logs in and sees the ticket under "New" | ✅ |
| Accept → Start work → Resolve with notes | ✅ |
| Resolved ticket moves to "Completed" tab | ✅ |
| Timeline and SLA times now show correct local time | ✅ |
| Priority sorting (CRITICAL above others) | ✅ |

---

## 6. Key Design Decisions

| Decision | Reason |
|---|---|
| Ownership check in a separate helper | One rule reused by three endpoints, easy to change later |
| Department queue visible to technicians | Otherwise unassigned tickets can never be accepted |
| SLA logic in `utils/sla.js` | Reused by supervisor and admin dashboards on Day 11 |
| Date parsing in one place | Timezone fix applies everywhere at once |
| Action area driven by ticket status | The UI cannot offer a transition the backend would reject |

---

## 7. Known Gaps (Planned)

| Gap | Plan |
|---|---|
| Image upload still not implemented | Backend upload endpoint (type and 5 MB limit) plus form field, after the dashboards |
| Technician cannot add work notes before resolving | Possible later addition |
| Technician cannot reject or return a ticket | Possible later addition |
| `develop` branch is far behind the feature branches | Merge `feature/backend` and `feature/frontend` into `develop` at the start of Day 11 |

---

## Services Running After Day 10

| Service | URL | Status |
|---|---|---|
| React Frontend | http://localhost:5173 | ✅ |
| FastAPI Backend | http://localhost:8000 | ✅ |
| PostgreSQL | localhost:5432 | ✅ (Docker) |
| pgAdmin | http://127.0.0.1:5050 | ✅ (Docker) |

---

## Next — Day 11

**Goal:** Supervisor and Admin dashboards

**Tasks:**
- Merge feature branches into `develop`
- Supervisor: department queue, assign ticket UI, SLA risk list
- Admin: campus KPI cards, ticket lists across departments
- Backend endpoint to list technicians of a department (needed for assignment)

---

*Log created for documentation and portfolio reference.*
