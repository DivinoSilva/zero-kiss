default:
	@just --list

build:
	docker compose -f docker-compose.dev.yml build

dev:
	docker compose -f docker-compose.dev.yml up -d

dev-bundle:
	docker compose -f docker-compose.dev.yml exec app bundle install

dev-migrate:
	docker compose -f docker-compose.dev.yml exec app bundle exec rails db:create db:migrate

dev-seed:
	docker compose -f docker-compose.dev.yml exec app bundle exec rails db:seed

dev-console:
	docker compose -f docker-compose.dev.yml exec app bundle exec rails c

dev-logs service='app':
	docker compose -f docker-compose.dev.yml logs -f --tail=100 {{service}}

dev-stop:
	docker compose -f docker-compose.dev.yml stop

dev-clean:
	docker compose -f docker-compose.dev.yml down

dev-swaggerize:
	docker compose -f docker-compose.dev.yml exec -e RAILS_ENV=development app bundle exec rake rswag:specs:swaggerize

test-build:
	docker compose -f docker-compose.test.yml build

test path='':
	docker compose -f docker-compose.test.yml up -d --scale app=0
	docker compose -f docker-compose.test.yml run --rm app bundle exec rails db:create db:migrate
	docker compose -f docker-compose.test.yml run --rm app bundle exec rspec {{path}}
	docker compose -f docker-compose.test.yml stop -t 0 app

test-clean:
	docker compose -f docker-compose.test.yml down

test-swaggerize:
	docker compose -f docker-compose.test.yml run --rm app bundle exec rake rswag:specs:swaggerize

clean-all:
	docker compose -f docker-compose.dev.yml down
	docker compose -f docker-compose.test.yml down
	docker volume rm zero_kiss_postgres_data_dev zero_kiss_postgres_data_test || true
