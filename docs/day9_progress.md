# CampusOps AI — Day 9 Progress Log

**Date:** Day 9 of 30-day development plan
**Branch:** feature/frontend (backend additions made on feature/backend and merged)
**Status:** ✅ Complete

---

## What Was Done

Built the complete student side of the application: dashboard with stats and ticket list, complaint submission form, and ticket detail page with a status timeline.

Two small backend endpoints were added first because the frontend needed them.

---

## 1. Backend Additions

### `GET /locations/` (`app/api/locations.py` — new file)
- Returns all campus locations (id, building, floor, room, location_type)
- Requires authentication
- Used to fill the Location dropdown in the complaint form

### `GET /tickets/{id}/history` (added to `app/api/tickets.py`)
- Returns the status history of one ticket in chronological order
- Students can only view history of their own tickets (403 otherwise)
- Used to render the status timeline on the ticket detail page

### `app/main.py`
- Registered the new `locations` router

---

## 2. Frontend Files Created

```
frontend/src/
├── services/
│   └── ticketService.js          ← list, get, history, create, locations
├── components/common/
│   ├── StatusBadge.jsx           ← coloured badge per ticket status
│   └── PriorityBadge.jsx         ← coloured badge per priority
├── layouts/
│   └── DashboardLayout.jsx       ← header with user name, role, logout
├── pages/student/
│   ├── StudentDashboard.jsx      ← stats + ticket list
│   ├── SubmitTicket.jsx          ← complaint form
│   └── TicketDetail.jsx          ← details + status timeline
└── App.jsx                       ← updated routes + Toaster
```

---

## 3. Features

### Student Dashboard (`/student`)
- Stat cards: Total, Active, Resolved
- Ticket list showing ticket number, title, date, priority badge, status badge
- Each row links to the ticket detail page
- Empty state message when no tickets exist
- Loading and error states

### Submit Complaint (`/student/new`)
- Fields: title, description, category (optional), location (dropdown from API)
- Category has a "Not sure" option for the future AI classification
- Success toast with ticket number, then redirect to the detail page
- Error toast on failure

### Ticket Detail (`/student/tickets/:id`)
- Ticket number, title, status/priority/category badges, description
- Resolution notes box (shown only when resolved)
- Submitted time and expected-by (SLA due) time
- Status timeline built from ticket history, newest changes visible with comments and timestamps

### Routing
| Route | Page | Roles |
|---|---|---|
| `/student` | StudentDashboard | STUDENT, ADMIN |
| `/student/new` | SubmitTicket | STUDENT, ADMIN |
| `/student/tickets/:id` | TicketDetail | STUDENT, ADMIN |

(ADMIN is allowed on student routes to make testing easier.)

---

## 4. Testing Done

| Test | Result |
|---|---|
| Student dashboard loads ticket list | ✅ |
| Stat cards count correctly | ✅ |
| New complaint submits and redirects to detail | ✅ |
| Ticket detail shows timeline from history | ✅ |
| Location dropdown filled from API | ✅ |

---

## 5. Key Design Decisions

| Decision | Reason |
|---|---|
| Ticket history as a separate endpoint | Keeps the ticket response small, history loaded only on detail page |
| Student access check on history endpoint | Same rule as the ticket endpoint, no data leak across students |
| Shared `StatusBadge` / `PriorityBadge` | Reused by technician, supervisor and admin dashboards later |
| Shared `DashboardLayout` | One header and logout for all roles |
| Category optional in the form | AI classification (Day 15) will fill it when the student is unsure |

---

## 6. Known Gaps (Planned)

| Gap | Plan |
|---|---|
| Image upload not implemented | Backend upload endpoint with file type and 5 MB limit, plus form field, after the dashboards |
| No "My tickets" filters/search | Possible polish later |
| Feedback after resolution not built | Day 23 (resolution and feedback workflow) |

---

## Services Running After Day 9

| Service | URL | Status |
|---|---|---|
| React Frontend | http://localhost:5173 | ✅ |
| FastAPI Backend | http://localhost:8000 | ✅ |
| PostgreSQL | localhost:5432 | ✅ (Docker) |
| pgAdmin | http://127.0.0.1:5050 | ✅ (Docker) |

---

## Next — Day 10

**Goal:** Technician Dashboard

**Tasks:**
- Assigned tickets list with priority and SLA due time
- Accept, Start Work and Resolve actions wired to the existing endpoints
- Resolve form with resolution notes
- Ticket detail view for technicians

---

*Log created for documentation and portfolio reference.*
