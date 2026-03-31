# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: amdemuyn <amdemuyn@student.42madrid.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/09 18:19:56 by amdemuyn          #+#    #+#              #
#    Updated: 2026/03/31 20:17:11 by amdemuyn         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BLUE	= \033[0;34m
GREEN	= \033[0;32m
RED		= \033[0;31m
ORANGE	= \033[38;5;208m
YELLOW	= \033[0;33m
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
		echo "$(YELLOW) .env created. YAY! $(RESET)"; \
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
		echo "$(YELLOW) ADD amdemuyn.42.fr to /etc/hosts $(RESET)" \
		echo "127.0.0.1 amdemuyn.42.fr www.amdemuyn.42.fr" | sudo tee -a /etc/hosts; \
	else \
		echo "$(RED) amdemuyn.42.fr ALREADY IN /etc/hosts $(RESET)"; \
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
	@echo "To list all databases: $(YELLOW)<show databases;>$(RESET)"
	@echo "To list tables in a database: $(YELLOW)<use database_name; show tables;>$(RESET)"
	@echo "To show content of a table: $(YELLOW)<use database_name; select * from table_name;>$(RESET)"
	@echo "To see the structure of a table: $(YELLOW)<use database_name; describe table_name;>$(RESET)"
	@echo "$(RED)To exit: <exit;>$(RESET)"
	@docker exec -it mariadb mysql -u $(DB_USER) -p $(DB_ROOT)

# Simulates a full restart to check if database data persists:
# Checks if the mariadb container exists.
# If it does not exist yet, it waits 1 second.
# Repeats the check until the container appears.
test_persistence: down
	@docker system prune -a --force
	@$(MAKE) up
	@echo "$(ORANGE)Waiting until MariaDB has restarted...$(RESET)"
	@echo "$(ORANGE)Waiting for MariaDB to be READY...$(RESET)"
	@until docker exec mariadb mysqladmin ping -u root -p$(DB_ROOT_PASS) --silent; do \
		sleep 2; \
	done
	@$(MAKE) test_data

# Executes a SQL query directly to verify that WordPress users still exist:
test_data:
	@echo "$(ORANGE)Check user data in MariaDB...$(RESET)"
	@docker exec mariadb mysql -u root -p$(DB_ROOT_PASS) -e \
	"USE wordpress; SELECT ID, user_login, user_email FROM wp_users;" \
	| sed 's/\t/    /g'
	@echo "$(GREEN)Data check complete ✔$(RESET)"

# Opens a shell inside each container for debugging or manual management:
inspect_container:
	@echo "$(YELLOW)Accessing container...$(RESET)"
	@read -p "Indicate the name of container (mariadb, wordpress or nginx): " CONTAINER_NAME; \
	docker exec -it "$$CONTAINER_NAME" /bin/sh

# Shows logs for all services (PHP, Nginx, MariaDB) to troubleshoot errors or startup issues.
logs:
	@docker compose -f $(DOCKER_CMP) logs

# remember
remember:
	@echo ""
	@echo "Usage: 'make <target>' list of <target>:"
	@echo ""
	@echo "$(BLUE)all$(RESET)              			Verify /etc/hosts and start containers"
	@echo "$(BLUE)period_env$(RESET)     			Create .env file from .env.example"
	@echo "$(BLUE)hosts$(RESET)           			Check /etc/hosts and add amdemuyn.42.fr if not present"
	@echo "$(BLUE)up$(RESET)              			Create directories and start services in the background"
	@echo "$(BLUE)down$(RESET)         	 			Stop and remove containers and networks but keep images and volumes"
	@echo "$(BLUE)fclean$(RESET)           			Remove containers, images, volumes, and remove directories"
	@echo "$(BLUE)re$(RESET)               			Remove containers, images, volumes, and clean directories, then start containers"
	@echo "$(BLUE)ps$(RESET)               			List running containers and their status"
	@echo "$(BLUE)exec_mariadb$(RESET)      		Access MariaDB database"
	@echo "$(YELLOW)test_persistence$(RESET)  		Demonstrate data persistence"
	@echo "$(YELLOW)test_data$(RESET)       		Check if data persists in MariaDB"
	@echo "$(BLUE)inspect_container$(RESET)  		Access mariadb/wordpress/nginx containers"
	@echo "$(BLUE)logs$(RESET)             			Display logs"
	@echo "$(ORANGE)remember$(RESET)             	Display remember"
	@echo ""

.PHONY: all period_env hosts up down fclean re ps exec_mariadb test_persistence test_data inspect_container logs remember 