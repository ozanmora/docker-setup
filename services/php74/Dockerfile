FROM php:7.4-fpm

# Install system libraries
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    mariadb-client

# PHP 7.4 Extensions (GD, Zip, MySQL etc.)
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl mysqli

# Install Composer (Latest)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js (Node 18 is suitable for older projects)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

WORKDIR /var/www