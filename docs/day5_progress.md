# CampusOps AI — Day 5 Progress Log

**Date:** Day 5 of 30-day development plan
**Branch:** feature/backend
**Status:** ✅ Complete

---

## What Was Done

### 1. Files Created/Updated

```
backend/
└── app/
    ├── models/
    │   ├── __init__.py       ← Department + User imports added
    │   ├── user.py           ← User SQLAlchemy model
    │   └── department.py     ← Department SQLAlchemy model
    ├── schemas/
    │   └── user.py           ← Pydantic schemas
    ├── core/
    │   └── security.py       ← JWT + bcrypt functions
    ├── api/
    │   └── auth.py           ← Register, Login endpoints
    └── main.py               ← Router included
```

---

### 2. User Model (`app/models/user.py`)

SQLAlchemy ORM model for `users` table:
- `id`, `name`, `email`, `password_hash`
- `role` → ENUM: STUDENT, TECHNICIAN, SUPERVISOR, ADMIN
- `department_id` → ForeignKey to departments
- `phone`, `student_id`, `is_active`
- `created_at`, `updated_at`
- Relationship: `department` → back_populates `users`

### 3. Department Model (`app/models/department.py`)

SQLAlchemy ORM model for `departments` table:
- `id`, `name`, `description`
- `contact_email`, `contact_phone`
- `sla_hours_low/medium/high/critical`
- `is_active`, `created_at`
- Relationship: `users` → back_populates `department`

### 4. Pydantic Schemas (`app/schemas/user.py`)

| Schema | Purpose |
|---|---|
| `UserRegister` | Registration request (name, email, password, phone, student_id) |
| `UserLogin` | Login request (email, password) |
| `UserResponse` | Response (no password_hash exposed) |
| `Token` | JWT token + user info response |

### 5. Security (`app/core/security.py`)

| Function | Purpose |
|---|---|
| `hash_password()` | bcrypt hash with 72-byte truncation |
| `verify_password()` | bcrypt verify with 72-byte truncation |
| `create_access_token()` | JWT token with expiry |
| `decode_token()` | JWT decode and verify |

### 6. Auth Endpoints (`app/api/auth.py`)

| Endpoint | Method | Status |
|---|---|---|
| `/auth/register` | POST | ✅ 201 Created |
| `/auth/login` | POST | ✅ 200 OK |
| `/auth/me` | GET | ⏳ Placeholder (Day 6) |

### 7. Test Results

**Register Request:**
```json
{
  "name": "Krishnendu Adhikary",
  "email": "krishnendu@campus.edu",
  "password": "Krish@123",
  "phone": "9564209924",
  "student_id": "CSPG/032/25"
}
```

**Register Response (201):**
```json
{
  "id": 2,
  "name": "Krishnendu Adhikary",
  "email": "krishnendu@campus.edu",
  "role": "STUDENT",
  "phone": "9564209924",
  "is_active": true,
  "created_at": "2026-09-26T09:11:27.679141"
}
```

**Login Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": 2,
    "name": "Krishnendu Adhikary",
    "email": "krishnendu@campus.edu",
    "role": "STUDENT",
    "is_active": true,
    "created_at": "2026-09-26T09:11:27.679141"
  }
}
```

---

## Issues Faced & Fixed

| Issue | Fix |
|---|---|
| `KeyError: 'Department'` — SQLAlchemy relationship not found | Added imports in `app/models/__init__.py` |
| `ModuleNotFoundError: email_validator` | Installed `pydantic[email]` |
| `bcrypt has no attribute '__about__'` | Downgraded bcrypt to version 4.0.1 |
| `password cannot be longer than 72 bytes` | Added `encode('utf-8')[:72]` truncation in security.py |

---

## Key Design Decisions

| Decision | Reason |
|---|---|
| bcrypt for password hashing | Industry standard, secure one-way hash |
| JWT token with role in payload | Role-based access without extra DB query |
| Token expiry: 1440 minutes (24hr) | Balance between security and UX |
| `UserResponse` schema excludes password_hash | Never expose hashed password in API response |
| Default role: STUDENT on register | Only admin can promote users to other roles |
| 72-byte truncation in bcrypt | bcrypt limitation — passwords over 72 bytes are silently truncated |

---

## Packages Added

```
pydantic[email]    ← EmailStr validation
bcrypt==4.0.1      ← Password hashing (downgraded for Python 3.14 compatibility)
```

Updated `requirements.txt` after changes.

---

## API Endpoints Status After Day 5

| Endpoint | Method | Auth Required | Status |
|---|---|---|---|
| `/` | GET | No | ✅ |
| `/health` | GET | No | ✅ |
| `/auth/register` | POST | No | ✅ |
| `/auth/login` | POST | No | ✅ |
| `/auth/me` | GET | Yes | ⏳ Day 6 |

---

## Next — Day 6

**Goal:** Ticket CRUD + Assignment + Status Transitions

**Tasks:**
- Ticket SQLAlchemy model
- Ticket Pydantic schemas
- POST /tickets (create)
- GET /tickets (list with filters)
- GET /tickets/{id} (detail)
- PATCH /tickets/{id} (update)
- POST /tickets/{id}/assign
- POST /tickets/{id}/accept
- POST /tickets/{id}/start
- POST /tickets/{id}/resolve
- JWT middleware for protected routes
- `/auth/me` endpoint complete

---

*Log created for documentation and portfolio reference.*
