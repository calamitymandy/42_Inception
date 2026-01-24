# 42_Inception

*This project has been created as part of the 42 curriculum by amdemuyn.*

# Inception

## Description

**Inception** is a system administration project focused on designing and deploying a small, secure web infrastructure using **Docker** and **Docker Compose**, entirely within a **virtual machine**.

The goal of the project is to virtualize multiple services into isolated containers while respecting strict security, networking, and persistence constraints. The infrastructure is composed of:
- An **NGINX** web server acting as the single entrypoint via HTTPS (TLSv1.2 / TLSv1.3),
- A **WordPress** application running with **PHP-FPM**,
- A **MariaDB** database server,
- Dedicated **Docker volumes** for persistent data storage,
- A private **Docker network** to interconnect services securely.

All Docker images are built manually from Alpine or Debian base images, without using pre-built service images.

---

## Project Architecture Overview

The infrastructure includes the following services:

- **NGINX**
  - Handles HTTPS traffic on port 443 only
  - Terminates TLS connections
  - Proxies requests to the WordPress container

- **WordPress (PHP-FPM)**
  - Hosts the WordPress application
  - Communicates with MariaDB over the Docker network
  - Does not include NGINX

- **MariaDB**
  - Stores WordPress data
  - Runs in its own isolated container

- **Docker Volumes**
  - One volume for the WordPress database
  - One volume for WordPress website files
  - Both volumes are stored under `/home/login/data` on the host

---

## Instructions

### Requirements
- Linux virtual machine
- Docker
- Docker Compose
- Make

### Build and Run

From the root of the repository:

```make```

This command:
- Builds all Docker images
- Creates the Docker network and volumes
- Starts all containers using docker-compose

To stop the infrastructure:
- make down

To remove containers, volumes, and network:
- make clean

---

## Design Choices and Comparisons

### **Virtual Machines vs Docker**

Virtual Machines emulate full operating systems and consume more resources.

Docker containers share the host kernel, start faster, and are more lightweight.

Docker allows fine-grained service isolation while keeping performance high.


### **Secrets vs Environment Variables**

Environment variables are used for non-sensitive configuration values.

Docker secrets are used for passwords and credentials.

This separation prevents sensitive data from being exposed in images or repositories.


### **Docker Network vs Host Network**

Docker networks provide isolated, internal communication between containers.

Host networking removes isolation and is less secure.

A dedicated Docker network ensures controlled service exposure.


### **Docker Volumes vs Bind Mounts**

Docker volumes are managed by Docker and portable across systems.

Bind mounts depend on host paths and are less predictable.

Volumes are required for data persistence and portability in this project.

---

## Resources

Docker Documentation — Containerization and best practices: 

- Docker Compose Documentation
- NGINX Documentation
- WordPress Documentation
- MariaDB Documentation

---

## Use of AI

AI tools were used for:
- Structuring documentation
- Clarifying Docker concepts
- Improving wording and consistency
All architectural decisions and implementation details were designed and implemented manually.

---

## Additional Documentation

USER_DOC.md — End-user and administrator guide

DEV_DOC.md — Developer setup and maintenance guide


