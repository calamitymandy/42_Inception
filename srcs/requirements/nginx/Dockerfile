# install Debian
FROM debian:bullseye

# update system
RUN apt-get update && apt-get upgrade -y

# install nginx: server for wordpress website
# install openssl to generate ssl certificate
RUN apt-get install -y nginx openssl

# Copy configuration file of nginx
COPY ./conf/default.conf /etc/nginx/sites-enabled/default

# launch script to start service
RUN printf '#!/bin/bash\n\
if [ ! -f /etc/ssl/certs/nginx.crt ]; then\n\
echo "Nginx: Initializing SSL certificate..."\n\
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
-keyout /etc/ssl/private/nginx.key \
-out /etc/ssl/certs/nginx.crt \
-subj "/C=ES/ST=Madrid/L=Madrid/O=wordpress/CN=amdemuyn.42.fr"\n\
echo "Nginx: SSL certificate created!"\n\
fi\n\
echo "Nginx: Server started!"\n\
nginx -g \"daemon off;\"\n' \
> /start.sh

# Give execution rights to the script
RUN chmod +x /start.sh

# Start service
CMD ["/start.sh"]
