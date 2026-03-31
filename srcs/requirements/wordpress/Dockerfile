# Use Debian as base image
FROM debian:bullseye

# Update system packages
RUN apt-get update && apt-get upgrade -y

# Install PHP-FPM (to execute PHP)
RUN apt-get install -y php7.4-fpm

# Install PHP extension to connect to MariaDB
RUN apt-get install -y php7.4-mysql

# Install MariaDB client (to communicate with DB container)
RUN apt-get install -y mariadb-client

# Install curl (used to download wp-cli)
RUN apt-get install -y curl

# Copy PHP-FPM configuration
COPY ./conf/wordpress.conf /etc/php/7.4/fpm/pool.d

# Create startup script directly inside the image
RUN printf '#!/bin/sh\n\
\n\
# Create required directory for PHP-FPM\n\
mkdir -p /run/php/\n\
touch /run/php/php7.4-fpm.pid\n\
\n\
# Check if WordPress is already installed (persistent volume)\n\
if [ ! -f /var/www/html/wordpress/wp-config.php ]; then\n\
    echo "WordPress: Initializing configuration..."\n\
\n\
    # Download WP-CLI (WordPress command-line tool)\n\
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar\n\
    chmod +x wp-cli.phar\n\
    mv wp-cli.phar /usr/local/bin/wp\n\
\n\
    # Go to WordPress directory\n\
    cd /var/www/html/wordpress\n\
\n\
    # Download WordPress core files\n\
    wp core download --allow-root\n\
\n\
    # Set correct permissions (temporary write access)\n\
    chmod -R 775 /var/www/html/wordpress\n\
    chown -R www-data:www-data /var/www/html/wordpress\n\
\n\
    # Secure permissions after setup\n\
    chmod -R 755 /var/www/html/wordpress\n\
\n\
    # Create wp-config.php (database configuration)\n\
    wp config create --allow-root \\\n\
        --dbname=$DB_NAME \\\n\
        --dbhost=mariadb:3306 \\\n\
        --dbprefix=wp_ \\\n\
        --dbuser=$DB_USER \\\n\
        --dbpass=$DB_USER_PASS\n\
\n\
    echo "WordPress: Creating users..."\n\
\n\
    # Install WordPress (site + admin user)\n\
    wp core install --allow-root \\\n\
        --url=amdemuyn.42.fr \\\n\
        --title=${WP_NAME} \\\n\
        --admin_user=${WP_ADMIN_NAME} \\\n\
        --admin_password=${WP_ADMIN_PASS} \\\n\
        --admin_email=${WP_ADMIN_MAIL}\n\
\n\
    # Create additional user\n\
    wp user create ${WP_USER} ${WP_USER_MAIL} \\\n\
        --user_pass=${WP_USER_PASS} --role=author --allow-root\n\
\n\
    # Install and activate theme\n\
    wp theme install inspiro --activate --allow-root\n\
\n\
    # Configure comments settings\n\
    wp option update comment_moderation 0 --allow-root\n\
    wp option update comment_whitelist 1 --allow-root\n\
    wp option update comment_registration 1 --allow-root\n\
\n\
    echo "WordPress: Configuration complete!"\n\
else\n\
    echo "WordPress: Configuration already exists! Starting WordPress..."\n\
fi\n\
\n\
echo "WordPress: Successfully started!"\n\
\n\
# Start PHP-FPM in foreground (required for Docker)\n\
exec /usr/sbin/php-fpm7.4 --nodaemonize --allow-to-run-as-root\n\
' > /start.sh

# Give execution permission
RUN chmod +x /start.sh

# Run script at container start
CMD ["/start.sh"]