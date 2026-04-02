# Use Debian
FROM debian:bullseye

# Install nginx + openssl
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Copy nginx configuration
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/nginx

# Create start script directly inside image
RUN cat << 'EOF' > /start.sh
#!/bin/bash

set -e

# Generate SSL certificate if it does not exist
if [ ! -f /etc/ssl/certs/nginx.crt ]; then
    echo "Nginx: Initializing SSL certificate..."

    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout /etc/ssl/private/nginx.key \
        -out /etc/ssl/certs/nginx.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=wordpress/CN=amdemuyn.42.fr"

    echo "Nginx: SSL certificate created!"
fi

# Test nginx configuration before starting
echo "Nginx: Testing configuration..."
nginx -t

# Start nginx in foreground
echo "Nginx: Server started!"
exec nginx -g "daemon off;"
EOF

# Make script executable
RUN chmod +x /start.sh

# Expose HTTPS port
EXPOSE 443

# Start container
CMD ["/start.sh"]