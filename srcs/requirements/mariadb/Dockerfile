# Use Debian Bullseye as base image (required for Inception)
FROM debian:bullseye

# Update system packages and install MariaDB server
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*   # Clean cache to reduce image size

# Copy custom MariaDB configuration file into the container
#   - Lower numbers → base configs (client, mysqld_safe, etc.)
#   - 50-server.cnf → main server configuration
#   - Higher numbers (like 99) → overrides/custom tweaks
# 👉 So 50 is just a convention for “main config”
COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

# Create the startup script directly inside the image
RUN printf '#!/bin/bash\n\
\n\
# Path to temporary SQL file used to initialize the database\n\
MYSQL_INIT_FILE="/createdb.sql"\n\
\n\
# Create directory required by MariaDB to store PID/socket\n\
mkdir -p /run/mysqld\n\
\n\
# Set correct ownership so MariaDB (mysql user) can access it\n\
chown -R mysql:mysql /run/mysqld\n\
chown -R mysql:mysql /var/lib/mysql\n\
\n\
# Initialize MariaDB data directory (only creates system tables)\n\
mysql_install_db > /dev/null 2>&1\n\
\n\
# Check if the database already exists (data persistence check)\n\
if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then\n\
\n\
    # Remove previous init file if it exists\n\
    rm -f "$MYSQL_INIT_FILE"\n\
\n\
    # Create database\n\
    echo "CREATE DATABASE $DB_NAME;" >> "$MYSQL_INIT_FILE"\n\
\n\
    # Create user with password (accessible from any host '%')\n\
    echo "CREATE USER '\''$DB_USER'\''@'\''%'\'' IDENTIFIED BY '\''$DB_USER_PASS'\'';" >> "$MYSQL_INIT_FILE"\n\
\n\
    # Grant all privileges on the database to this user\n\
    echo "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '\''$DB_USER'\''@'\''%'\'' WITH GRANT OPTION;" >> "$MYSQL_INIT_FILE"\n\
\n\
    # Apply privilege changes\n\
    echo "FLUSH PRIVILEGES;" >> "$MYSQL_INIT_FILE"\n\
\n\
    # Set root password\n\
    echo "ALTER USER '\''root'\''@'\''localhost'\'' IDENTIFIED BY '\''$DB_ROOT_PASS'\'';" >> "$MYSQL_INIT_FILE"\n\
\n\
    # Inform that initialization is happening\n\
    echo "MariaDB: Initializing database..."\n\
\n\
    # Start MariaDB and execute the SQL initialization file\n\
    # 'exec' replaces the shell → keeps container alive\n\
    exec mysqld_safe --init-file=$MYSQL_INIT_FILE\n\
\n\
else\n\
\n\
    # If database already exists → skip initialization\n\
    echo "MariaDB: Database already exists!"\n\
\n\
    # Start MariaDB normally\n\
    exec mysqld_safe\n\
fi\n' > /start.sh

# Give execution permission to the startup script
RUN chmod +x /start.sh

# Expose MariaDB port (not mandatory for compose but good practice)
EXPOSE 3306

# Run the startup script when the container starts
CMD ["/start.sh"]