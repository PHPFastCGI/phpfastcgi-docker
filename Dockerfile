FROM alpine:3.3

# Expose HTTP HTTPS and Caddy ports
EXPOSE 80 443 2015

# Update/Upgrade packages
RUN apk update --no-cache && apk upgrade --no-cache --available

# Install ssh-client, php and required php extensions for composer and app
RUN apk add --no-cache --update \
	openssh-client \
	tar \
	php \
	php-curl \
	php-openssl \
	php-phar \
	php-pcntl \
	php-json	

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
	&& curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
	&& php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

# Install composer and show version information
RUN php /tmp/composer-setup.php --install-dir=/usr/sbin --filename=composer \
	&& rm -rf /tmp/composer-setup.php \
	&& composer --version

# Download and install Caddy and show version information
RUN curl --silent --show-error --fail --location \
	--header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
	"https://caddyserver.com/download/build?os=linux&arch=amd64" \
	| tar --no-same-owner -C /usr/sbin/ -xz caddy \
	&& chmod 0755 /usr/sbin/caddy \
	&& /usr/sbin/caddy -version

# Set the working directory to /srv
WORKDIR /srv

# Copy application to container
COPY app/ /srv

# Run composer on application
RUN chdir /srv && /usr/sbin/composer --ansi install

# Copy Caddy config file over
ADD Caddyfile /etc/Caddyfile

# Set container entry point and parameters to Caddy
ENTRYPOINT ["/usr/sbin/caddy"]
CMD ["--conf", "/etc/Caddyfile"]
