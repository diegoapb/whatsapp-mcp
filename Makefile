.PHONY: help build up down logs clean restart auth health

# Default target
help: ## Show this help message
	@echo "WhatsApp MCP Docker Management"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build all Docker images
	docker-compose build

up: ## Start all services
	docker-compose up -d

down: ## Stop all services
	docker-compose down

logs: ## Show logs for all services
	docker-compose logs -f

logs-bridge: ## Show logs for whatsapp-bridge only
	docker-compose logs -f whatsapp-bridge

logs-mcp: ## Show logs for whatsapp-mcp-server only
	docker-compose logs -f whatsapp-mcp-server

clean: ## Stop services and remove volumes
	docker-compose down -v
	# docker system prune -f

up-bridge: ## Start whatsapp-bridge service only
	docker-compose up -d whatsapp-bridge
up-mcp: ## Start whatsapp-mcp-server service only		
	docker-compose up -d whatsapp-mcp-server

restart: ## Restart all services
	docker-compose down
	docker-compose up -d

build-restart: ## Rebuild and restart all services
	docker-compose down
	docker-compose up --build -d

auth: ## Remove session data to force re-authentication
	docker-compose down
	sudo rm -rf ./whatsapp-bridge/session/*
	docker-compose up -d

health: ## Check service health
	@echo "Checking WhatsApp Bridge health..."
	@curl -f http://localhost:8080/health 2>/dev/null && echo "✓ Bridge is healthy" || echo "✗ Bridge is not responding"
	@echo "Checking if MCP server is running..."
	@docker-compose ps whatsapp-mcp-server | grep "Up" >/dev/null && echo "✓ MCP server is running" || echo "✗ MCP server is not running"

status: ## Show service status
	docker-compose ps

shell-bridge: ## Open shell in whatsapp-bridge container
	docker-compose exec whatsapp-bridge sh

shell-mcp: ## Open shell in whatsapp-mcp-server container
	docker-compose exec whatsapp-mcp-server bash

backup: ## Backup important data
	@echo "Creating backup..."
	@mkdir -p backup
	@cp -r ./whatsapp-bridge/store backup/store-$(shell date +%Y%m%d-%H%M%S)
	@cp -r ./whatsapp-bridge/session backup/session-$(shell date +%Y%m%d-%H%M%S)
	@echo "Backup created in backup/ directory"

install: ## Initial setup - copy env file and build
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env file from template"; fi
	@make build
	@echo "Setup complete! Run 'make up' to start services"
