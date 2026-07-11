# NEXORA CONTROL CENTER — SKILL.md

## Mission

Build a production-grade AI operating system called Nexora.

The Control Center is the single interface used to manage:

* WhatsApp Agents
* Calling Agents
* AI Assistants
* Knowledge Base
* Leads
* Customers
* Analytics
* Billing
* System Health

The software must feel like a premium SaaS product.

Never build demo-quality code.

---

# Technology Stack

Frontend:

* Flutter 3.x
* Material 3
* Riverpod
* GoRouter
* Dio
* Freezed
* Json Serializable

Backend:

* Nexora Brain API

Database:

* PostgreSQL

AI:

* Ollama
* Llama3

Vector Database:

* Qdrant

Authentication:

* JWT
* Refresh Tokens

---

# Architecture Rules

Follow Clean Architecture.

Layers:

presentation/
application/
domain/
data/

Never bypass layers.

UI must never directly call APIs.

UI → Application → Repository → API

Only.

---

# UI Philosophy

Design inspiration:

* Linear
* Notion
* Stripe Dashboard
* Vercel
* OpenAI Platform

Requirements:

* Professional
* Minimal
* Fast
* Enterprise-grade

Avoid:

* Heavy gradients
* Cartoon UI
* Fancy animations
* Mobile-app style dashboards

---

# Navigation Structure

Dashboard

Agents

* WhatsApp Agents
* Calling Agents

Knowledge Base

Leads

Customers

Conversations

Analytics

Audit Logs

System Health

Settings

Billing

---

# Dashboard Requirements

Show:

* Active Agents
* Messages Today
* Calls Today
* Leads Generated
* Customers Managed
* AI Usage
* System Health

All metrics must be realtime-ready.

---

# WhatsApp Agent Module

Features:

* Agent List
* Agent Creation
* Agent Settings
* Prompt Editor
* Knowledge Base Linking
* Conversation History
* Agent Analytics

---

# Calling Agent Module

Features:

* Agent List
* Voice Selection
* Prompt Configuration
* Call History
* Call Recordings
* Lead Extraction
* Analytics

---

# Knowledge Base Module

Features:

* Upload Documents
* View Documents
* Delete Documents
* Reindex Documents
* Search Knowledge Base

Supported:

* PDF
* DOCX
* TXT

---

# Lead Management

Features:

* Lead List
* Lead Score
* Lead Source
* Lead Status
* Lead Timeline

Statuses:

* New
* Contacted
* Qualified
* Proposal
* Won
* Lost

---

# Customer Memory

Features:

* Customer Profile
* Notes
* Tags
* History
* Preferences
* AI Memory

---

# API Standards

Every API call must:

* Handle loading
* Handle errors
* Handle retry
* Handle timeout
* Handle unauthorized state

Never crash UI.

---

# Security

Requirements:

* JWT storage
* Auto refresh token
* Session validation
* Secure logout

Never store secrets in code.

---

# Code Quality

Requirements:

* Strong typing
* No dead code
* No duplicated logic
* No hardcoded values

Every feature must include:

* Models
* Repository
* Service
* UI

---

# Testing

Every module must include:

* Unit Tests
* Widget Tests
* Integration Tests

No feature is complete without tests.

---

# Production Definition

A feature is considered complete only if:

1. Compiles successfully
2. Passes tests
3. Handles failures
4. Works with Nexora Brain API
5. Has production UI
6. Has logging
7. Has loading states
8. Has error states

Never mark a task complete before verification.
