# Variables
DC := docker compose
DC_RUN := $(DC) run --rm
DC_RUN_APP := $(DC_RUN) app
DC_EXEC := $(DC) exec

# Common actions
.PHONY: up down build logs

up:
	$(DC) up -d

down:
	$(DC) down

build:
	$(DC) build

logs:
	$(DC) logs -f

# Application commands
.PHONY: bundle console server bash install print.img

bundle:
	$(DC_RUN_APP) bundle install

console:
	$(DC_RUN_APP) bundle exec rails console

server:
	$(DC) up app

bash:
	$(DC_RUN_APP) bash

install:
	$(DC) build
	$(MAKE) bundle
	$(MAKE) db.setup
	$(MAKE) test.install
	$(MAKE) print.img

print.img:
	@echo "\n"
	@echo "\033[31m   ___             \033[32m_    \033[33m_       "
	@echo "\033[31m  / __| \033[32m__ _  \033[33m_ _ \033[34m| |_ \033[35m| | \033[36m_  _ "
	@echo "\033[31m | (__ \033[32m/ _\` |\033[33m| '_|\033[34m|  _|\033[35m| |\033[36m| || |"
	@echo "\033[31m  \___|\033[32m\__,_|\033[33m|_|  \033[34m \__|\033[35m|_| \033[36m\_, |"
	@echo "\033[31m       \033[32m      \033[33m     \033[34m     \033[35m    \033[36m|__/ "
	@echo "\033[0m"
	@echo "🎉 Welcome to Cartly! 🚀"
	@echo "🔧 You can run 'make server' to start the application."
	@echo "\n"
	@echo "🔧 To use the admin panel, go to http://localhost:3000/control_panel"
	@echo "🔧 The test user is 'test@test.com' with password 'Abc123..'"
	@echo "🌟 Enjoy! 🌟"
	@echo "\n"

# Testing commands
.PHONY: test test.install test.auth test.smoke test.mobile test.desktop test.headed test.debug test.report test.codegen

test.install:
	npm install
	npm run test:install

test.auth:
	npm test -- auth-core.spec.js

test.smoke:
	npm test -- auth-smoke.spec.js

test.mobile:
	npm run test:mobile

test.desktop:
	npm run test:desktop

test.headed:
	npm run test:headed

test.debug:
	npm run test:debug

test.report:
	npm run test:report

test.codegen:
	npm run test:codegen

test: test.smoke test.auth
	@echo "✅ All core tests passed!"

# Database commands
.PHONY: db.setup db.migrate db.rollback db.reset db.seed db.session

db.setup:
	$(DC_RUN_APP) bin/rails db:drop db:setup

db.migrate:
	$(DC_RUN_APP) bin/rails db:migrate

db.rollback:
	$(DC_RUN_APP) bundle exec rails db:rollback STEP=$(STEP)

db.reset:
	$(DC_RUN_APP) bundle exec rails db:reset

db.seed:
	$(DC_RUN_APP) bundle exec rails db:seed

db.session:
	$(DC_RUN_APP) bundle exec rails db

# Commands for other services
.PHONY: pgadmin chrome redis

# Command to clean volumes
.PHONY: clean

clean:
	$(DC) down -v
