# 🏫 CampusOps AI
### Smart Campus Operations Intelligence Platform

> An intelligent campus maintenance platform that classifies complaints using ML, detects duplicates semantically, automates SLA monitoring and escalation via n8n, and provides operational analytics — built with React, FastAPI, PostgreSQL and Docker.

---

## 🚨 The Problem

A college campus receives maintenance complaints through WhatsApp, phone calls, verbal reports and paper forms. This causes:

- Lost or duplicate tickets
- Wrong department assignment
- Delayed resolution
- No visibility into recurring problems

## ✅ The Solution

```
Student submits complaint
        ↓
AI classifies category + predicts priority
        ↓
Duplicate detection (semantic similarity)
        ↓
AI suggests department → Student confirms
        ↓
Assigned to technician
        ↓
n8n sends notification (Email + Telegram)
        ↓
SLA monitored → auto-escalate if breached
        ↓
Resolved → Student notified → Feedback collected
        ↓
Analytics + Recurring issue detection
```

---

## 👥 Users & Roles

| Role | What they do |
|---|---|
| **Student** | Submit complaints, track status, give feedback |
| **Technician** | View assigned tickets, accept, work, resolve |
| **Supervisor** | Manage department queue, reassign, monitor SLA |
| **Admin** | Campus analytics, user management, SLA config |

---

## 🏗️ Architecture

```
Users (Student / Technician / Supervisor / Admin)
        ↓
React Frontend (Tailwind CSS · Bengali + English UI)
        ↓ REST API
FastAPI Backend (Auth · Business Logic · File Upload)
    ↓           ↓              ↓
PostgreSQL    ML Service      n8n Automation
(Database)  (Classify·       (Email · Telegram
            Priority·        SLA · Escalation
            Duplicate)       Weekly Report)
        ↓
Docker Compose → VPS Deployment
```

---

## ⚙️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React + Tailwind CSS |
| Backend | Python + FastAPI |
| Database | PostgreSQL |
| ML / NLP | Scikit-learn + Sentence Transformers |
| Automation | n8n (self-hosted) |
| Containerization | Docker + Docker Compose |
| Notifications | Email (SMTP) + Telegram Bot |
| Version Control | GitHub + GitHub Actions |
| Deployment | VPS (Docker Compose) |

---

## 🏢 Departments

| Department | SLA (Normal) | Emergency SLA |
|---|---|---|
| IT & Network | 1 day | 2 hours |
| Electrical | 1 day | 1 hour |
| Plumbing | 2 days | 2 hours |
| Civil & Infrastructure | 2 days | 4 hours |
| Housekeeping | 1 day | 3 hours |
| Security | 1 day | 30 minutes |
| Canteen & Mess | 1 day | 2 hours |
| Horticulture | 2 days | 4 hours |

---

## 🤖 ML / AI Features

| Feature | Method |
|---|---|
| Ticket Classification | TF-IDF + Logistic Regression (baseline) → Sentence Transformers |
| Priority Prediction | Rule-based baseline → ML model |
| Duplicate Detection | Sentence Transformer embeddings + cosine similarity |

> Dataset: 500–1000 synthetic campus complaints (clearly labeled as synthetic prototype data)

**Model Metrics** *(to be updated after training)*
- Classification Accuracy: —
- F1 Score: —
- Duplicate Detection Threshold: —

---

## 🔄 Ticket Lifecycle

```
OPEN → AI_PROCESSED → ASSIGNED → ACCEPTED → IN_PROGRESS → RESOLVED → CLOSED
                                                    ↓
                                              ESCALATED (SLA breach)
```

---

## ⚡ n8n Automation Workflows

| Workflow | Trigger | Action |
|---|---|---|
| New ticket | Ticket created | Notify technician |
| Critical alert | Priority = CRITICAL | Alert Admin + Supervisor |
| SLA reminder | < 1 hour remaining | Remind technician |
| Escalation | SLA breached | Notify Supervisor → Admin |
| Resolution | Ticket resolved | Notify student + request feedback |
| Weekly report | Every Sunday | Email report to Admin |
| Recurring issue | Backend detects pattern | Alert Supervisor |

---

## 🗄️ Database Schema

*See [docs/database.md](docs/database.md) for full ER diagram and schema.*

Key tables: `users` · `departments` · `locations` · `assets` · `tickets` · `ticket_history` · `notifications` · `feedback` · `audit_logs`

---

## 📁 Project Structure

```
campusops-ai/
├── frontend/          # React + Tailwind CSS
├── backend/           # FastAPI application
├── ml/                # datasets, notebooks, trained models
├── n8n/workflows/     # exported n8n workflow JSONs
├── database/          # migrations + seed data
├── docs/              # architecture, API, DB, workflows
├── tests/             # unit + integration tests
├── docker-compose.yml
├── docker-compose.prod.yml
├── .env.example
└── README.md
```

---

## 🚀 Getting Started (Local)

```bash
# 1. Clone the repository
git clone https://github.com/your-username/campusops-ai.git
cd campusops-ai

# 2. Copy environment variables
cp .env.example .env
# Edit .env with your values

# 3. Start all services
docker-compose up --build

# Access:
# Frontend:  http://localhost:3000
# Backend:   http://localhost:8000
# API Docs:  http://localhost:8000/docs
# n8n:       http://localhost:5678
```

---

## 📊 Dashboard KPIs

- Total Tickets · Open · Resolved · Critical
- SLA Compliance % · Average Resolution Time
- Top Problem Categories · Problem Hotspots
- Department Performance · Recurring Issues

---

## 🔒 Security

- JWT Authentication (24hr expiry)
- Role-Based Access Control (RBAC)
- Password hashing (bcrypt)
- Input validation + file type/size restrictions
- Environment variables (no secrets in code)
- n8n webhook protection
- Audit logging for all status changes

---

## 📸 Screenshots

*Coming after UI development (Day 8–12)*

---

## 🎥 Demo Video

*Coming after deployment (Day 29–30)*

---

## 📈 Future Work

- WhatsApp notification integration
- IoT sensor integration (ESP32)
- Computer vision on uploaded images
- Mobile app (React Native)
- Multi-campus support
- Predictive maintenance scoring (Phase 2)

---

## 👤 Developer

**Krishnendu Adhikary**
M.Sc. Computer Science

---

*⚠️ Dataset Disclaimer: The ML training dataset contains synthetically generated campus complaints created for prototype evaluation. It does not represent real campus data.*
