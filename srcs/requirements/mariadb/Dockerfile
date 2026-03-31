# Use Debian Bullseye as base image (required for Inception)
FROM debian:bullseye

# Update system packages and install MariaDB server
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copy custom MariaDB configuration file into the container
COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

# Create the startup script directly inside the image (clean version using heredoc)
RUN cat << 'EOF' > /start.sh
#!/bin/bash

# Path to temporary SQL file used to initialize the database
MYSQL_INIT_FILE="/createdb.sql"

# Create directory required by MariaDB (PID/socket)
mkdir -p /run/mysqld

# Set correct ownership so MariaDB can access directories
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Initialize MariaDB system tables (first run only)
mysql_install_db > /dev/null 2>&1

# Check if database already exists (data persistence)
if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then

    # Remove old init file if present
    rm -f "$MYSQL_INIT_FILE"

    # Create database
    echo "CREATE DATABASE $DB_NAME;" >> "$MYSQL_INIT_FILE"

    # Create user
    echo "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASS';" >> "$MYSQL_INIT_FILE"

    # Grant privileges
    echo "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' WITH GRANT OPTION;" >> "$MYSQL_INIT_FILE"

    # Apply privileges
    echo "FLUSH PRIVILEGES;" >> "$MYSQL_INIT_FILE"

    # Set root password
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';" >> "$MYSQL_INIT_FILE"

    echo "MariaDB: Initializing database..."

    # Start MariaDB with init file
    exec mysqld_safe --init-file=$MYSQL_INIT_FILE

else
    echo "MariaDB: Database already exists!"

    # Start MariaDB normally
    exec mysqld_safe
fi
EOF

# Give execution permission to the startup script
RUN chmod +x /start.sh

# Expose MariaDB port (optional but good practice)
EXPOSE 3306

# Run the startup script when the container starts
CMD ["/start.sh"]