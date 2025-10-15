Você tem razão — ficou confuso antes. Aqui vai **um único bloco Markdown**, completo, com **todos os itens** e os blocos de código corretamente fechados:

````markdown
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
- **No PostGIS** (per challenge). Geometry enforced with:
  - DB **exclusion constraints** (GiST over `numrange`) so **frames never touch/overlap**.
  - App validations so **circles fit** the frame and **never touch/overlap** each other.
- **Docs-first** with **RSwag** (OpenAPI 3).
- **RSpec** covers requests, models, queries, validators.
- **Docker Compose** for dev & test.
- **Justfile** wraps common commands.

---

## Business Rules
- **Frames must not touch or overlap** any other frame (edge/corner contact is forbidden).
- **Circles** must:
  - belong to a frame,
  - be **fully inside** the frame (can touch the frame border),
  - **not touch/overlap** other circles in the same frame.
- **Search (`GET /api/v1/circles`)** with `(center_x, center_y, radius)` returns circles **fully inside** that radius:  
  `dist(center, circle_center) ≤ radius - diameter/2`.
- **Atomicity**: `POST /api/v1/frames` with `circles_attributes` is **all-or-nothing**.  
  If any circle is invalid → **422** and **rollback** (nothing is persisted).

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

# 5) generate/open docs
just dev-swaggerize
# visit http://localhost:3000/api-docs

# 6) stop services
just dev-stop

# list all Just commands
just
````

---

## Everyday Commands (Justfile)

### Dev

```bash
just build                 # build dev images
just dev                   # up -d
just dev-bundle            # bundle install in container
just dev-migrate           # db:create db:migrate
just dev-seed              # rails db:seed (optional)
just dev-console           # rails c
just dev-logs app          # tail logs (service=app|db)
just dev-swaggerize        # generate OpenAPI (served at /api-docs)
just dev-stop              # stop containers
just dev-clean             # down (remove dev stack)
```

### Test

```bash
just test-build            # build test image
just test                  # run full rspec suite
just test path=spec/...    # run specific file
just test-swaggerize       # generate OpenAPI via test env
just test-clean            # down (remove test stack)
```

### Cleanup

```bash
just clean-all             # down dev+test and remove PG volumes
```

---

## Development Workflow

1. `just dev` → `just dev-migrate`
2. Code → `just test`
3. Update docs: `just dev-swaggerize` → open `/api-docs`
4. Commit & PR

---

## Testing

```bash
# full suite
just test

# single file
just test path=spec/requests/api/v1/circles_spec.rb
```

---

## API Documentation (Swagger)

```bash
just dev-swaggerize
# open: http://localhost:3000/api-docs
```

---

## Endpoints (summary)

**Frames**

* `POST /api/v1/frames` – creates a frame (optional `circles_attributes`), **atomic**.
* `GET  /api/v1/frames/:id` – returns frame + `circles_count` + extremals + `circles`.
* `DELETE /api/v1/frames/:id` – only if the frame has no circles (else 422).

**Circles**

* `POST /api/v1/frames/:frame_id/circles` – create one circle.
* `PUT  /api/v1/circles/:id` – update circle (same validations).
* `DELETE /api/v1/circles/:id` – delete circle.
* `GET  /api/v1/circles` – list/search; filters: `frame_id`, `(center_x, center_y, radius)`; pagination `page`, `per_page` (1..200, clamped).

---

## Data Model

* **Frame**: `(center_x, center_y, width, height)` + generated `x_range`, `y_range`.
  Exclusion constraint: `EXCLUDE USING gist (x_range WITH &&, y_range WITH &&)`.
* **Circle**: `(frame_id, center_x, center_y, diameter)` + bbox ranges and edges.
  Exclusion constraint (bbox within frame): `EXCLUDE USING gist (frame_id WITH =, x_range WITH &&, y_range WITH &&)`.

---

## Troubleshooting

* **422 frames cannot touch/overlap**: adjust `center_x/center_y/width/height` to leave a positive gap (e.g., `+0.001`).
* **422 circle must be fully inside / circles cannot touch/overlap**: reduce `diameter` or move centers.
* **PG::ExclusionViolation**: DB constraint blocked a touch/overlap; nothing was persisted.

---

## Contributing

* Keep messages/labels/docs in **English**.
* Add/update specs with behavior changes.
* Run `just test` and `just test-swaggerize` before PR.

---

## License

MIT

````

**Commit pronto:**
```bash
git add README.md
git commit -m "docs(readme): single-file markdown with complete sections, atomicity, Justfile commands, endpoints and troubleshooting"
````
