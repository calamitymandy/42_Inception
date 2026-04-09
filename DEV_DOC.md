
---

## 📄 DEV_DOC.md

```md
# Developer Documentation — Inception

## Prerequisites

- Linux virtual machine
- Docker
- Docker Compose
- Make
- Root or Docker group access

---

## Initial Setup

### 1. Clone the Repository

```bash```
git clone <repository_url>
cd inception

### 2. Environment Variables

Create the environment file:

srcs/.env


Example:

DOMAIN_NAME=login.42.fr
MYSQL_USER=wp_user
MYSQL_DATABASE=wordpress


This files must not be committed to Git.

### 3. Build and Launch

To build images and start containers:

```make```


This command:

Builds custom Docker images

Creates volumes and network

Launches all services using Docker Compose

Useful Docker Commands
Container Management
docker ps
docker stop <container>
docker restart <container>

Logs
docker logs <container>

Docker Compose
docker-compose ps
docker-compose down
