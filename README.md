# ZeroKiss

Rails 7.2 (API-only) + Ruby 3.3 + Postgres + RSpec, running in Docker.  
Docs-first approach with RSwag (OpenAPI). No PostGIS.

## Contents
- [Requirements](#requirements)
- [Architecture & Decisions](#architecture--decisions)
- [Business Rules](#business-rules)
- [Quick Start](#quick-start)
- [Everyday Commands (Justfile)](#everyday-commands-justfile)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [API Documentation (Swagger)](#api-documentation-swagger)
- [Endpoints (summary)](#endpoints-summary)
- [Data Model](#data-model)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Requirements
- **Docker** & **Docker Compose**
- **Just** (optional, but used throughout): https://github.com/casey/just

> **Postgres port note**  
> By default the Postgres port is **not** exposed on the host to avoid conflicts.  
> The app connects internally via Docker network (`db:5432`).  
> If you really need external access, you can map `5433:5432` locally.

---

## Architecture & Decisions
- **Rails API-only**: minimal footprint, no views/assets.
- **No PostGIS** (per challenge). Geometric checks are implemented with:
  - DB-side **exclusion constraint** (GiST over numeric ranges) for **frames not touching/overlapping**.
  - App-side validations for circle geometry.
- **Docs-first** with **RSwag** (OpenAPI 3).
- **RSpec** for request/model specs.
- **Docker Compose** for dev & test environments.
- **Justfile** wraps common commands.

---

## Business Rules
- **Frames must not touch or overlap** other frames.
- **Circles must belong to a frame**, must **fit fully inside** that frame (edges may touch).
- **Circles within the same frame must not touch or overlap**.
- **Search (/circles)** returns only circles **fully inside** a given search radius (inclusive).

---

## Quick Start
```bash
# 1) build images
just build

# 2) start dev stack
just dev

# 3) create/migrate dev DB
just dev-migrate

# 4) smoke test
curl http://localhost:3000/healthz
# => {"ok":true}

# 5) open docs (after swaggerize): http://localhost:3000/api-docs

# 6) stop services
just dev-stop

# List all Just commands
just
