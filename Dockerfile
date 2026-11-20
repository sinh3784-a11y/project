
FROM php:8.4-apache

# Install dependencies for MySQL and image handling
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

# Configure Apache to listen on port 80
RUN sed -i \
    's/Listen 80/Listen 0.0.0.0:80/' \
    /etc/apache2/ports.conf

# Enable .htaccess and disable directory listing
RUN printf '<Directory /var/www/html>\n\
AllowOverride All\n\
Options -Indexes\n\
</Directory>\n' \
    > /etc/apache2/conf-available/app.conf \
    && a2enconf app

WORKDIR /var/www/html

COPY . /var/www/html/

# Prepare student image / QR upload directory
RUN mkdir -p /var/www/html/asset/images

EXPOSE 80

CMD ["bash", "-c", \
  "chown -R www-data:www-data /var/www/html/asset/images && exec apache2-foreground"]
