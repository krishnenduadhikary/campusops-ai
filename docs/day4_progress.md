# CampusOps AI — Day 4 Progress Log

**Date:** Day 4 of 30-day development plan
**Branch:** feature/backend
**Status:** ✅ Complete

---

## What Was Done

### 1. Switched to Backend Branch

```bash
git checkout feature/backend
```

### 2. Python Virtual Environment Setup

```bash
cd backend
python -m venv venv
venv\Scripts\activate
```

Python version: 3.14.2

### 3. Packages Installed

```bash
pip install fastapi uvicorn sqlalchemy psycopg2-binary alembic python-dotenv pydantic pydantic-settings passlib bcrypt python-jose python-multipart pillow
```

**Issue faced:** `psycopg2-binary` not compatible with Python 3.14
**Fix:** Uninstalled psycopg2-binary, installed psycopg v3

```bash
pip uninstall psycopg2-binary -y
pip install psycopg[binary]
pip freeze > requirements.txt
```

### 4. Backend Folder Structure Created

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── api/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── tickets.py
│   │   ├── users.py
│   │   ├── assets.py
│   │   └── analytics.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── ticket.py
│   │   └── department.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── ticket.py
│   ├── services/
│   ├── repositories/
│   ├── db/
│   │   ├── __init__.py
│   │   └── database.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py
│   │   └── security.py
│   └── utils/
│       └── __init__.py
├── .env
├── requirements.txt
└── venv/
```

### 5. Files Created

#### `app/core/config.py`
- Pydantic Settings for environment variables
- DATABASE_URL property computed from parts
- JWT config (SECRET_KEY, ALGORITHM, expiry)
- File upload config

#### `app/db/database.py`
- SQLAlchemy engine with connection pooling
- SessionLocal for dependency injection
- `get_db()` generator function
- `check_db_connection()` for health check

**Fix applied:** Changed deprecated import
```python
# Old (deprecated)
from sqlalchemy.ext.declarative import declarative_base
# New (correct)
from sqlalchemy.orm import declarative_base
```

#### `app/main.py`
- FastAPI app instance
- CORS middleware configured for React frontend (port 3000)
- `/` root endpoint
- `/health` endpoint with database connectivity check
- Swagger UI at `/docs`
- ReDoc at `/redoc`

#### `backend/.env`
- PostgreSQL connection variables
- JWT secret key
- Environment settings

### 6. FastAPI Server Started

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 7. All Endpoints Verified

| Endpoint | Method | Status | Response |
|---|---|---|---|
| `/` | GET | 200 OK ✅ | App name, version, status |
| `/health` | GET | 200 OK ✅ | healthy, database: connected |
| `/docs` | GET | 200 OK ✅ | Swagger UI loaded |
| `/openapi.json` | GET | 200 OK ✅ | OpenAPI schema |

---

## Issues Faced & Fixed

| Issue | Fix |
|---|---|
| `ModuleNotFoundError: No module named 'psycopg'` | Uninstalled psycopg2-binary, installed psycopg[binary] (v3) |
| `sqlalchemy.ext.declarative` deprecation warning | Changed to `sqlalchemy.orm.declarative_base` |

---

## Key Decisions

| Decision | Reason |
|---|---|
| `psycopg` v3 instead of `psycopg2` | Python 3.14 compatibility |
| `pool_size=10, max_overflow=20` | Handle concurrent requests |
| `pool_pre_ping=True` | Auto-reconnect if DB connection drops |
| CORS allows `localhost:3000` | React frontend will run on port 3000 |
| `--reload` flag in uvicorn | Auto-restart on code changes during development |

---

## Services Running After Day 4

| Service | URL | Status |
|---|---|---|
| FastAPI Backend | http://localhost:8000 | ✅ Running |
| Swagger UI | http://localhost:8000/docs | ✅ Running |
| PostgreSQL | localhost:5432 | ✅ Running (Docker) |
| pgAdmin | http://127.0.0.1:5050 | ✅ Running (Docker) |

---

## Next — Day 5

**Goal:** JWT Authentication + Role-Based Access Control

**Tasks:**
- User registration endpoint
- Login endpoint with JWT token generation
- Password hashing with bcrypt
- JWT token verification middleware
- Role-based authorization (Student, Technician, Supervisor, Admin)
- `/auth/me` endpoint
- Test with Swagger UI

---

*Log created for documentation and portfolio reference.*
