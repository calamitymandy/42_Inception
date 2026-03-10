# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: amdemuyn <amdemuyn@student.42madrid.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/09 18:19:56 by amdemuyn          #+#    #+#              #
#    Updated: 2026/03/10 19:17:44 by amdemuyn         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


BLUE	= \033[0;34m
GREEN	= \033[0;32m
RED		= \033[0;31m
RESET	= \033[0m

DOCKER_CMP = srcs/docker-compose.yml

# Do `make` to check /etc/hosts and launch containers
# hosts → ensures amdemuyn.42.fr is in /etc/hosts.
# up → creates local directories and starts the containers.
# remember → prints a summary of all Makefile commands.
all: hosts up remember

# Create empty .env from .env.example
ENV_FILE = srcs/.env

period_env:
	@echo "$(GREEN) Let's create the .env file! $(RESET)"
	@if [ ! -f $(ENV_FILE) ]; then \
		cp srcs/.env.example $(ENV_FILE); \
		echo "$(GREEN) .env created. YAY! $(RESET)"; \
	else \
		echo "$(RED) .env is already there... $(RESET)"; \
	fi

# Load environment variables
# exports all variable names to the shell so that subsequent commands can use them.
ifneq ("$(wildcard $(ENV_FILE))","")
    include $(ENV_FILE)
    export $(shell sed 's/=.*//' $(ENV_FILE))
endif

# Checks if domain amdemuyn.42.fr exists in /etc/hosts.
# If not, it adds it using sudo tee -a.
# Ensures your local machine can resolve amdemuyn.42.fr to 127.0.0.1 for testing.
hosts:
	@echo "$(GREEN) Check /etc/hosts for amdemuyn.42.fr $(RESET)"
	@if ! grep -q 'amdemuyn.42.fr' /etc/hosts; then \
		echo "$(GREEN) ADD amdemuyn.42.fr to /etc/hosts $(RESET)" \
		echo "127.0.0.1 amdemuyn.42.fr www.amdemuyn.42.fr" | sudo tee -a /etc/hosts; \
	else \
		echo "$(BLUE) amdemuyn.42.fr ALREADY IN /etc/hosts $(RESET)"; \
	fi

# Creates local directories for Docker volumes if they don’t exist.
# & Launches containers with Docker Compose:
# --build → rebuilds images.
# -d → runs in detached mode (background).
# ### FOR LINUX ###
# 	@mkdir -p /home/${USER}/data/mariadb
#	@mkdir -p /home/${USER}/data/wordpress
up:
	@echo "$(GREEN) Create directories and launch containers: $(RESET)"
	@mkdir -p /Users/amandine/data/mariadb
	@mkdir -p /Users/amandine/data/wordpress
	@docker compose -f $(DOCKER_CMP) up --build -d

# Stops containers and removes Docker networks.
# Does NOT delete volumes or images, so database data persists.
down:
	@echo "$(RED) Stop & remove containers & networks $(RESET)"
	@docker compose -f $(DOCKER_CMP) down

# Reset the project completely:
# Cleans everything: containers, images, volumes, and local folders.
# docker system prune -a --force cleans unused containers, images, and volumes.

fclean: down
	@echo "$(RED)Cleaning containers...$(RESET)"
	@if [ $$(docker images -qa | wc -l) -gt 0 ]; then \
		docker rmi -f $$(docker images -qa); \
	fi
	@echo "$(RED)Cleaning volumes...$(RESET)"
	@if [ $$(docker volume ls -q | wc -l) -gt 0 ]; then \
		docker volume rm $$(docker volume ls -q); \
	fi
	@echo "$(RED)Cleaning directories...$(RESET)"
	@docker system prune -a --force
	@sudo rm -rf /home/${USER}/data/mariadb /home/${USER}/data/wordpress
	
# Cleans everything & starts containers
re: fclean all

# Lists running containers & status of
ps:
	@docker compose -f $(DOCKER_CMP) ps

# Opens an interactive MySQL shell inside the MariaDB container.
exec_mariadb:
	@echo "$(GREEN)Accessing MariaDB database...$(RESET)"
	@echo "To list all databases: $(GREEN)<show databases;>$(RESET)"
	@echo "To list tables in a database: $(GREEN)<use database_name; show tables;>$(RESET)"
	@echo "To show content of a table: $(GREEN)<use database_name; select * from table_name;>$(RESET)"
	@echo "To see the structure of a table: $(GREEN)<use database_name; describe table_name;>$(RESET)"
	@echo "$(GREEN)To exit: <exit;>$(RESET)"
	@docker exec -it mariadb mysql -u $(DB_USER) -p $(DB_ROOT)
