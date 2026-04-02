# Use Debian Bullseye
FROM debian:bullseye

# Install MariaDB
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --fix-missing mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copy MariaDB config
COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

# Create startup script directly inside container
RUN cat << 'EOF' > /start.sh
#!/bin/bash

MYSQL_INIT_FILE="/createdb.sql"

# Create required directory
mkdir -p /run/mysqld

# Set correct permissions
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Initialize database (system tables)
mysql_install_db > /dev/null 2>&1

# If DB does not exist → initialize
if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then

    rm -f "$MYSQL_INIT_FILE"

    echo "CREATE DATABASE $DB_NAME;" >> "$MYSQL_INIT_FILE"
    echo "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASS';" >> "$MYSQL_INIT_FILE"
    echo "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' WITH GRANT OPTION;" >> "$MYSQL_INIT_FILE"
    echo "FLUSH PRIVILEGES;" >> "$MYSQL_INIT_FILE"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';" >> "$MYSQL_INIT_FILE"

    echo "MariaDB: Initializing database..."

    exec mysqld_safe --init-file="$MYSQL_INIT_FILE"

else
    echo "MariaDB: Database already exists!"

    exec mysqld_safe
fi
EOF

# Make script executable
RUN chmod +x /start.sh

# Expose port
EXPOSE 3306

# Run script
CMD ["/start.sh"]