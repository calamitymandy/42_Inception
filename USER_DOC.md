
---

## 📄 USER_DOC.md

```md
# User Documentation — Inception

## Overview

This project provides a secure WordPress website hosted through a containerized infrastructure using Docker.  
All services run inside isolated containers and are accessed through a single HTTPS entrypoint.

Provided services:
- Public WordPress website
- WordPress administration panel
- Secure HTTPS access via NGINX

---

## Starting and Stopping the Project

### Start the Infrastructure

From the project root directory:

```
make

### Stop the Infrastructure
```
make down

### Accessing the Website
```
Website

Open a browser and go to:

https://login.42.fr

WordPress Admin Panel
https://login.42.fr/wp-admin


Use the administrator credentials defined during setup.


### Credentials Management

Credentials are not stored in the repository.

They are managed using:

A .env file for non-sensitive variables

###  Docker secrets for passwords

Location of secrets:

secrets/
├── db_password.txt
├── db_root_password.txt
└── credentials.txt


Only authorized users should have access to this directory.

Checking Service Status

To verify running containers:

docker ps


To inspect logs for a specific service:

docker logs nginx
docker logs wordpress
docker logs mariadb

Persistent Data

All persistent data is stored on the host machine:

/home/login/data


This includes:

WordPress database data

WordPress website files

Data remains intact even if containers are stopped or rebuilt.

Troubleshooting

Ensure Docker and Docker Compose are installed

Verify that port 443 is not already in use

Check logs if a service fails to start

Confirm that login.42.fr resolves to your local IP address