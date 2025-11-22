# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data
DB_PATH = $(DATA_PATH)/mariadb
WP_PATH = $(DATA_PATH)/wordpress

# Colors for output
GREEN = \033[0;32m
RED = \033[0;31m
YELLOW = \033[0;33m
NC = \033[0m # No Color

# Default target
all: setup build up

# Create directories for volumes
setup:
	@echo "$(YELLOW)Creating volume directories...$(NC)"
	@mkdir -p $(DB_PATH)
	@mkdir -p $(WP_PATH)
	@echo "$(GREEN)✓ Directories created successfully$(NC)"

# Build images
build:
	@echo "$(YELLOW)Building Docker images...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✓ Images built successfully$(NC)"

# Start containers
up:
	@echo "$(YELLOW)Starting containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✓ Containers started successfully$(NC)"

# Stop containers
down:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✓ Containers stopped$(NC)"

# Restart containers
restart: down up

# Show container status
status:
	@docker-compose -f $(COMPOSE_FILE) ps

# Show logs
logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

# Show logs for specific service
logs-nginx:
	@docker-compose -f $(COMPOSE_FILE) logs -f nginx

logs-mariadb:
	@docker-compose -f $(COMPOSE_FILE) logs -f mariadb

logs-wordpress:
	@docker-compose -f $(COMPOSE_FILE) logs -f wordpress

# Shell access
shell-nginx:
	@docker exec -it nginx sh

shell-mariadb:
	@docker exec -it mariadb bash

shell-wordpress:
	@docker exec -it wordpress bash

# Clean containers
clean:
	@echo "$(YELLOW)Removing containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down -v
	@rm -rf /home/$(USER)/data/$(WP_PATH)
	@rm -rf /home/$(USER)/data/$(DB_PATH)
	@echo "$(GREEN)✓ Containers removed$(NC)"

# Full clean (containers + images + volumes + directories)
fclean: down
	@echo "$(RED)Removing everything...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down --rmi all --volumes --remove-orphans
	@docker system prune -af --volumes
	@sudo rm -rf $(DATA_PATH)
	@echo "$(GREEN)✓ Everything cleaned$(NC)"

# Rebuild everything
re: fclean all

# Show help
help:
	@echo "$(GREEN)Available commands:$(NC)"
	@echo "  make setup       - Create volume directories"
	@echo "  make build       - Build Docker images"
	@echo "  make up          - Start containers"
	@echo "  make down        - Stop containers"
	@echo "  make restart     - Restart containers"
	@echo "  make status      - Show container status"
	@echo "  make logs        - Show all logs"
	@echo "  make logs-nginx  - Show nginx logs"
	@echo "  make logs-mariadb - Show mariadb logs"
	@echo "  make logs-wordpress - Show wordpress logs"
	@echo "  make shell-nginx - Access nginx shell"
	@echo "  make shell-mariadb - Access mariadb shell"
	@echo "  make shell-wordpress - Access wordpress shell"
	@echo "  make clean       - Remove containers and volumes"
	@echo "  make fclean      - Full cleanup"
	@echo "  make re          - Rebuild everything"
	@echo "  make help        - Show this help"

.PHONY: all setup build up down restart status logs logs-nginx logs-mariadb \
        logs-wordpress shell-nginx shell-mariadb shell-wordpress clean fclean re help