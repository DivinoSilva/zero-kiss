# ZeroKiss

Rails 7.2 (API-only) + Postgres + RSpec, running in Docker.

## Requirements
- Docker and Docker Compose
- Just (optional): https://github.com/casey/just

> **Postgres port note**  
> By default we do **not** expose the Postgres port on the host to avoid conflicts with local databases.  
> The app connects internally via Docker network (`db:5432`). If you *really* need external access, map a different host port (e.g. `5433:5432`) locally.

## Quick start with Docker + Just
1) just build  
2) just dev  
3) just dev-migrate  
4) Test: curl http://localhost:3000/healthz  
5) Stop: just dev-stop  
6) List commands: just

## Tests
- just test
- just test path='spec/requests/health_spec.rb'
