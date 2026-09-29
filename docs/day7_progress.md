# CampusOps AI — Day 7 Progress Log

**Date:** Day 7 of 30-day development plan
**Branch:** feature/backend
**Status:** ✅ Complete

---

## What Was Done

Full backend testing using Swagger UI (`http://localhost:8000/docs`).
No new code written — focus was on verifying all endpoints work correctly.

---

## Test Results

### Auth Endpoints

| Test | Input | Expected | Result |
|---|---|---|---|
| Duplicate email register | existing email | 400 Bad Request | ✅ |
| Wrong password login | wrong password | 401 Unauthorized | ✅ |
| Correct login | valid credentials | 200 OK + token | ✅ |
| /auth/me with token | valid JWT | 200 OK + user info | ✅ |
| /auth/me without token | no token | 401 Unauthorized | ✅ |

---

### User Setup for Testing

Created 3 test users via `/auth/register` + pgAdmin role update:

| User | Email | Role | Department |
|---|---|---|---|
| Krishnendu Adhikary | krishnendu@campus.edu | ADMIN | — |
| Raju Technician | technician@campus.edu | TECHNICIAN | — |
| Priya Supervisor | supervisor@campus.edu | SUPERVISOR | IT & Network (id:1) |

**SQL used for role update:**
```sql
UPDATE users SET role = 'TECHNICIAN'
WHERE email = 'technician@campus.edu';

UPDATE users SET role = 'SUPERVISOR', department_id = 1
WHERE email = 'supervisor@campus.edu';
```

---

### Ticket Endpoints

| Test | Input | Expected | Result |
|---|---|---|---|
| Create ticket with token | valid data | 201 Created | ✅ |
| Create ticket without token | no token | 401 Unauthorized | ✅ |
| List tickets (no token) | no token | 401 Unauthorized | ✅ |
| List tickets (technician) | technician token | 200 — filtered list | ✅ |
| Wrong status transition | accept OPEN ticket | 400 Bad Request | ✅ |
| Assign ticket | dept_id=1 | 200 OK | ✅ |
| Accept ticket | ASSIGNED ticket | 200 OK | ✅ |
| Start ticket | ACCEPTED ticket | 200 OK | ✅ |
| Resolve ticket | IN_PROGRESS ticket | 200 OK | ✅ |

---

### Ticket History Verification

pgAdmin query confirmed full audit trail:

```sql
SELECT
    th.id,
    t.ticket_number,
    th.old_status,
    th.new_status,
    u.name as changed_by,
    th.comment,
    th.timestamp
FROM ticket_history th
JOIN tickets t ON th.ticket_id = t.id
LEFT JOIN users u ON th.changed_by = u.id
ORDER BY th.timestamp;
```

**Result:**
```
1  TKT-0001  NULL         OPEN         Krishnendu  Ticket created           2026-09-26 09:58
2  TKT-0001  OPEN         ASSIGNED     Krishnendu  Assigned to department 1 2026-09-26 10:10
3  TKT-0001  ASSIGNED     ACCEPTED     Krishnendu  Ticket accepted          2026-09-26 10:11
4  TKT-0001  ACCEPTED     IN_PROGRESS  Krishnendu  Work started             2026-09-26 10:12
5  TKT-0001  IN_PROGRESS  RESOLVED     Krishnendu  Resolved: WiFi router... 2026-09-26 10:12
6  TKT-0002  NULL         OPEN         Krishnendu  Ticket created           2026-09-29 10:05
```

✅ Complete audit trail working perfectly.

---

### Role-Based Access Verification

| Role | GET /tickets/ | Result |
|---|---|---|
| No token | — | 401 Unauthorized ✅ |
| ADMIN | All tickets | 200 OK — all visible ✅ |
| TECHNICIAN | Assigned only | 200 OK — filtered ✅ |
| SUPERVISOR | Department only | 200 OK — filtered ✅ |
| STUDENT | Own tickets only | 200 OK — filtered ✅ |

---

## Database State After Day 7

### Users Table
```
id  name                  email                      role        dept
1   Campus Admin          admin@campus.edu           ADMIN       NULL
2   Krishnendu Adhikary   krishnendu@campus.edu      ADMIN       NULL
3   Raju Technician       technician@campus.edu      TECHNICIAN  NULL
4   Priya Supervisor      supervisor@campus.edu      SUPERVISOR  1
```

### Tickets Table
```
id  ticket_number  title                           status    priority  category
1   TKT-0001       WiFi not working in Lab 3       RESOLVED  HIGH      IT
2   TKT-0002       AC not working in Hostel Block  OPEN      MEDIUM    ELECTRICAL
```

### Ticket History
```
6 history records across 2 tickets — all correct
```

---

## Issues Found & Fixed

| Issue | Fix |
|---|---|
| `/auth/me` returning 401 first time | Token not set in Swagger Authorize — re-authorized |
| Technician login failing | Wrong password used — corrected |

No code bugs found — all business logic working correctly.

---

## Backend API — Complete Status

| Endpoint | Method | Auth | Status |
|---|---|---|---|
| `/` | GET | No | ✅ |
| `/health` | GET | No | ✅ |
| `/auth/register` | POST | No | ✅ |
| `/auth/login` | POST | No | ✅ |
| `/auth/me` | GET | Yes | ✅ |
| `/tickets/` | POST | Yes | ✅ |
| `/tickets/` | GET | Yes | ✅ |
| `/tickets/{id}` | GET | Yes | ✅ |
| `/tickets/{id}` | PATCH | Yes | ✅ |
| `/tickets/{id}` | DELETE | Yes | ✅ |
| `/tickets/{id}/assign` | POST | Yes | ✅ |
| `/tickets/{id}/accept` | POST | Yes | ✅ |
| `/tickets/{id}/start` | POST | Yes | ✅ |
| `/tickets/{id}/resolve` | POST | Yes | ✅ |

---

## Next — Day 8

**Goal:** React Frontend setup

**Tasks:**
- Create React app with Vite
- Install Tailwind CSS
- Setup folder structure
- Create Login page
- Create Dashboard skeleton
- Connect to FastAPI backend
- Setup axios for API calls
- Setup React Router for navigation

---

*Log created for documentation and portfolio reference.*
