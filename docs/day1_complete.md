# CampusOps AI — Day 1 Complete Documentation

---

## 1. requirements.md

### Functional Requirements

#### Student / Reporter
- Register and login with email and password
- Submit maintenance complaint with title, description, location, image upload
- View own ticket status and history
- Receive notifications (Email / Telegram) on status updates
- Submit feedback after ticket is resolved

#### Technician
- Login and view assigned tickets
- Accept, start, and resolve tickets
- Add work notes and update progress
- View SLA deadline for each ticket

#### Supervisor
- View all tickets in their department
- Reassign tickets to other technicians
- Escalate overdue tickets
- Monitor SLA breaches
- View department-level analytics

#### Admin
- Manage users, departments, and locations
- View campus-wide analytics dashboard
- Configure SLA rules per department
- Receive weekly operational report
- View recurring issue alerts

#### AI System
- Automatically classify ticket into a department category
- Predict priority level (LOW / MEDIUM / HIGH / CRITICAL)
- Detect semantic duplicate tickets
- Suggest department to student before submission

#### n8n Automation
- Send notification when new ticket is created
- Alert admin and supervisor for CRITICAL tickets
- Monitor SLA deadlines and send reminders
- Escalate overdue tickets automatically
- Send resolution notification to student
- Request feedback after resolution
- Send weekly report every Sunday
- Alert supervisor when recurring issue is detected

---

### Non-Functional Requirements

| Category | Requirement |
|---|---|
| Language | Bengali + English bilingual UI |
| Authentication | JWT-based, token expires in 24 hours |
| Security | Password hashing (bcrypt), role-based access, input validation |
| File Upload | Image only (JPG, PNG, WEBP), max 5MB per file |
| Notifications | Email (SMTP) + Telegram Bot (free, MVP) |
| Availability | System should run 24/7 on VPS |
| Scalability | Docker Compose — can scale horizontally later |
| Auditability | All status changes logged with timestamp and user |
| Data | Synthetic dataset clearly labeled — not real campus data |

---

### Out of Scope (MVP)

- WhatsApp notification (add after MVP)
- IoT sensor integration
- Computer vision on images
- Mobile app
- Real-time chat between student and technician
- Payment or fee collection
- Multi-campus support

---

## 2. roles.md

### User Roles & Permissions

| Action | Student | Technician | Supervisor | Admin |
|---|---|---|---|---|
| Register / Login | ✅ | ✅ | ✅ | ✅ |
| Submit complaint | ✅ | ❌ | ❌ | ❌ |
| Upload image with ticket | ✅ | ❌ | ❌ | ❌ |
| View own tickets | ✅ | ❌ | ❌ | ❌ |
| View assigned tickets | ❌ | ✅ | ✅ | ✅ |
| View all department tickets | ❌ | ❌ | ✅ | ✅ |
| View all campus tickets | ❌ | ❌ | ❌ | ✅ |
| Accept ticket | ❌ | ✅ | ❌ | ❌ |
| Start work on ticket | ❌ | ✅ | ❌ | ❌ |
| Resolve ticket | ❌ | ✅ | ✅ | ✅ |
| Reassign ticket | ❌ | ❌ | ✅ | ✅ |
| Escalate ticket | ❌ | ❌ | ✅ | ✅ |
| Submit feedback | ✅ | ❌ | ❌ | ❌ |
| View analytics dashboard | ❌ | ❌ | ✅ (dept) | ✅ (campus) |
| Manage users | ❌ | ❌ | ❌ | ✅ |
| Manage departments | ❌ | ❌ | ❌ | ✅ |
| Configure SLA rules | ❌ | ❌ | ❌ | ✅ |
| View weekly report | ❌ | ❌ | ✅ | ✅ |

### Pages Each Role Can Access

| Role | Pages |
|---|---|
| Student | Login, Register, Dashboard, Submit Complaint, My Tickets, Ticket Detail, Feedback |
| Technician | Login, My Assigned Tickets, Ticket Detail, Work Notes |
| Supervisor | Login, Department Queue, Ticket Detail, Reassign, Analytics (dept), SLA Monitor |
| Admin | Login, All Tickets, Analytics (campus), User Management, Department Management, SLA Config, Reports |

---

## 3. ticket_lifecycle.md

### Ticket Status Flow

```
OPEN
  |
  ↓ (AI processes automatically)
AI_PROCESSED
  |
  ↓ (Supervisor or system assigns department + technician)
ASSIGNED
  |
  ↓ (Technician accepts the ticket)
ACCEPTED
  |
  ↓ (Technician starts working)
IN_PROGRESS
  |
  ↓ (Technician marks resolved)
RESOLVED
  |
  ↓ (Student gives feedback OR auto-closes after 48 hours)
CLOSED
```

### Alternative Paths

```
OPEN → CANCELLED          (Student cancels before assignment)
OPEN → REJECTED           (Supervisor rejects invalid complaint)
IN_PROGRESS → ESCALATED   (SLA breached, n8n auto-escalates)
ESCALATED → IN_PROGRESS   (Senior technician picks up)
```

### Who Triggers What

| Transition | Triggered By |
|---|---|
| OPEN → AI_PROCESSED | System (automatic after ticket created) |
| AI_PROCESSED → ASSIGNED | Supervisor manually OR system auto-assign |
| ASSIGNED → ACCEPTED | Technician |
| ACCEPTED → IN_PROGRESS | Technician |
| IN_PROGRESS → RESOLVED | Technician |
| RESOLVED → CLOSED | Student feedback OR auto after 48hr |
| OPEN → CANCELLED | Student |
| OPEN → REJECTED | Supervisor |
| IN_PROGRESS → ESCALATED | n8n automation (SLA breach) |

### n8n Automation Points

| Event | n8n Action |
|---|---|
| Ticket created (any priority) | Notify assigned technician via Email/Telegram |
| Ticket created (CRITICAL) | Alert Admin + Supervisor immediately |
| SLA < 1 hour remaining | Send reminder to technician |
| SLA breached | Escalate: notify supervisor → admin |
| Ticket resolved | Notify student + send feedback request |
| Every Sunday | Send weekly operations report to Admin |
| Recurring issue detected | Alert supervisor with asset/location details |

---

## 4. departments.md

### Department List with SLA

| # | Department | Handles | Normal SLA | Emergency SLA | Example Tickets |
|---|---|---|---|---|---|
| 1 | IT & Network | WiFi, computers, projectors, servers, printers, software | 1 day | 2 hours | "Lab 3 WiFi not working", "Projector dead in Room 204" |
| 2 | Electrical | Lights, fans, AC, power sockets, generator, wiring | 1 day | 1 hour | "Room 201 fan not working", "Electric wire broken near water — CRITICAL" |
| 3 | Plumbing | Water leak, tap, toilet, drainage, water supply | 2 days | 2 hours | "Hostel bathroom leaking", "No water supply in Block B" |
| 4 | Civil & Infrastructure | Wall crack, broken door/window, floor damage, roof leak | 2 days | 4 hours | "Classroom door hinge broken", "Roof leaking in Library" |
| 5 | Housekeeping | Cleaning, garbage, pest control, washroom hygiene | 1 day | 3 hours | "Canteen not cleaned", "Rats in storeroom — urgent" |
| 6 | Security | Gate, CCTV, access control, lost & found, suspicious activity | 1 day | 30 minutes | "Main gate CCTV offline", "Unknown person in hostel — CRITICAL" |
| 7 | Canteen & Mess | Food quality, hygiene, equipment, water filter | 1 day | 2 hours | "Mess water filter not working", "Food quality complaint" |
| 8 | Horticulture | Garden, plants, outdoor areas, fallen trees | 2 days | 4 hours | "Tree fallen near parking — CRITICAL", "Garden path damaged" |

### Priority Rules (CRITICAL Override)

Any ticket becomes CRITICAL automatically if:
- Electrical issue near water (wire + water combination)
- Security threat (unknown person, gate breach)
- Structural danger (roof collapse risk, fallen tree blocking path)
- Campus-wide service outage (entire network down, no water supply)

CRITICAL SLA = resolve within 2 hours (except Security = 30 minutes)

---

## 5. architecture.md

### System Architecture Summary

#### Tech Stack

| Layer | Technology | Why |
|---|---|---|
| Frontend | React + Tailwind CSS | Already known, fast development, bilingual UI easy |
| Backend | Python + FastAPI | Central to ML, async support, auto Swagger docs |
| Database | PostgreSQL | Relational data (users, tickets, departments, SLA) |
| ML/NLP | Scikit-learn + Sentence Transformers | Classification, priority, duplicate detection |
| Automation | n8n (self-hosted via Docker) | Notifications, SLA checks, escalation, reports |
| Containerization | Docker + Docker Compose | Reproducible local + production environment |
| Version Control | GitHub + GitHub Actions | CI/CD pipeline |
| Notifications | Email (SMTP) + Telegram Bot | Free, reliable for MVP |
| Deployment | VPS (DigitalOcean / Render) | Docker Compose on single server |

#### Data Flow — Complaint to Resolution

```
Student submits complaint (React)
        ↓
FastAPI receives + validates
        ↓
Save ticket to PostgreSQL (status: OPEN)
        ↓
Call ML Service
  ├── Category classification (TF-IDF + Logistic Regression)
  ├── Priority prediction (rules + ML)
  └── Duplicate detection (Sentence Transformers similarity)
        ↓
AI suggests department → Student confirms
        ↓
Update ticket (status: AI_PROCESSED)
        ↓
Assign to department technician
        ↓
Trigger n8n webhook
  ├── Notify technician (Email + Telegram)
  └── If CRITICAL → Alert Admin + Supervisor immediately
        ↓
Technician: Accept → Start → Resolve
        ↓
n8n: Notify student + Request feedback
        ↓
Student submits feedback
        ↓
Ticket CLOSED → Analytics updated
```

#### Campus Scope

- Campus type: Hostel + Academic Buildings
- Student capacity: 500–2000 (Medium campus)
- Departments: 8 operational departments
- Notification channels: Email + Telegram (WhatsApp post-MVP)
- UI language: Bengali + English bilingual

#### Folder Structure

```
campusops-ai/
├── frontend/          # React + Tailwind
├── backend/           # FastAPI + ML service
├── ml/                # datasets, notebooks, models
├── n8n/workflows/     # exported automation JSONs
├── database/          # migrations + seed data
├── docs/              # this folder
├── tests/
├── docker-compose.yml
├── docker-compose.prod.yml
├── .env.example
└── README.md
```

---

*Day 1 completed. All decisions finalized. Ready for Day 2: GitHub repo setup + database schema.*
