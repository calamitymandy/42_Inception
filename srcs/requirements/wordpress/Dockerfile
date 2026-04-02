# Use Debian Bullseye
FROM debian:bullseye

# Install required packages
# Install PHP-FPM to run PHP code (php7.4-fpm)
# Install PHP MySQL extension to connect to the MariaDB database (php7.4-mysql)
# Install MariaDB client to connect to the MariaDB database (mariadb-client)
# Install curl, a tool for transferring data from or to a server using supported 
# protocols (HTTP, HTTPS, FTP, etc.) designed to work without user interaction (curl)
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --fix-missing \
        php7.4-fpm \
        php7.4-mysql \
        mariadb-client \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Copy PHP-FPM config
COPY ./conf/wordpress.conf /etc/php/7.4/fpm/pool.d/www.conf

# Create startup script inside container
RUN cat << 'EOF' > /start.sh
#!/bin/bash

# Create required directory for PHP-FPM
mkdir -p /run/php/
touch /run/php/php7.4-fpm.pid

# If WordPress is not installed → install it
if [ ! -f /var/www/html/wordpress/wp-config.php ]; then
    echo "WordPress: Initializing configuration..."

    # Install WP-CLI
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    # Go to WordPress directory
    cd /var/www/html/wordpress

    # Download WordPress
    wp core download --allow-root

    # Set permissions
    chown -R www-data:www-data /var/www/html/wordpress
    chmod -R 755 /var/www/html/wordpress

    # Create config file
    wp config create --allow-root \
        --dbname=$DB_NAME \
        --dbhost=mariadb:3306 \
        --dbprefix=wp_ \
        --dbuser=$DB_USER \
        --dbpass=$DB_USER_PASS

    echo "WordPress: Creating users..."

    # Install WordPress
    wp core install --allow-root \
        --url=amdemuyn.42.fr \
        --title=$WP_NAME \
        --admin_user=$WP_ADMIN_NAME \
        --admin_password=$WP_ADMIN_PASS \
        --admin_email=$WP_ADMIN_MAIL

    # Create additional user
    wp user create $WP_USER $WP_USER_MAIL \
        --user_pass=$WP_USER_PASS \
        --role=author \
        --allow-root

    # Install theme
    wp theme install inspiro --activate --allow-root

    # Configure comments
    wp option update comment_moderation 0 --allow-root
    wp option update comment_whitelist 1 --allow-root
    wp option update comment_registration 1 --allow-root

    echo "WordPress: Configuration complete!"
else
    echo "WordPress: Configuration already exists!"
fi

echo "WordPress: Successfully started!"

# Start PHP-FPM in foreground
exec /usr/sbin/php-fpm7.4 --nodaemonize --allow-to-run-as-root
EOF

# Make script executable
RUN chmod +x /start.sh

# Expose port
EXPOSE 9000

# Run script
CMD ["/start.sh"]