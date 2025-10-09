# ZeroKiss

Rails 7.2 (API-only) + Postgres + RSpec, running in Docker.

## Requirements
- Docker and Docker Compose
- Just (optional): https://github.com/casey/just

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
