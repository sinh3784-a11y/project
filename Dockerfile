
FROM php:8.4-apache

# Install PHP dependencies
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    && docker-php-ext-configure gd \
       --with-freetype --with-jpeg \
    && docker-php-ext-install \
       mysqli pdo_mysql gd zip \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite
RUN a2enmod rewrite

# Configure Apache MPM
# mod_php requires mpm_prefork
RUN a2dismod -f mpm_event mpm_worker \
       2>/dev/null || true

RUN a2enmod mpm_prefork

# Configure Apache port
RUN sed -i \
    's/Listen 80/Listen 0.0.0.0:80/' \
    /etc/apache2/ports.conf

# Enable .htaccess
RUN printf '<Directory /var/www/html>\n\
AllowOverride All\n\
Options -Indexes\n\
</Directory>\n' \
    > /etc/apache2/conf-available/app.conf \
    && a2enconf app

WORKDIR /var/www/html

# Copy application code
COPY . /var/www/html/

# Prepare upload directory
RUN mkdir -p /var/www/html/asset/images

# Verify Apache configuration during build
RUN apache2ctl -t

EXPOSE 80

# Fix conflicting MPM modules at startup
# and run Apache in foreground
CMD ["bash", "-c", \
    "set -e; \
    a2dismod -f mpm_event mpm_worker 2>/dev/null || true; \
    rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.*; \
    a2enmod mpm_prefork; \
    apache2ctl -t; \
    chown -R www-data:www-data /var/www/html/asset/images; \
    exec apache2-foreground"]
