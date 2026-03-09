# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: amdemuyn <amdemuyn@student.42madrid.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/09 18:19:56 by amdemuyn          #+#    #+#              #
#    Updated: 2026/03/09 20:38:29 by amdemuyn         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


BLUE	= \033[0;34m
GREEN	= \033[0;32m
RED		= \033[0;31m
RESET	= \033[0m

# Do `make` to check /etc/hosts and launch containers
# hosts → ensures amdemuyn.42.fr is in /etc/hosts.
# up → creates local directories and starts the containers.
# remember → prints a summary of all Makefile commands.

all: hosts up remember

# Create empty .env from .env.example
ENV_FILE = srcs/.env

make_env:
	@echo "$(GREEN) Let's create the .env file! $(RESET)"
	@if [ ! -f $(ENV_FILE) ]; then \
		cp srcs/.env.example $(ENV_FILE); \
		echo "$(GREEN) .env created. YAY! $(RESET)"
	else \
		echo "$(RED) .env is already there... $(RESET)"
	fi

# Load environment variables
# exports all variable names to the shell so that subsequent commands can use them.
ifneq ("$(wildcard $(ENV_FILE))","")
	include $(ENV_FILE)
	export $(shell sed 's/=.*//' $(ENV_FILE))
endif

