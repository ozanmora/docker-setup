FROM php:8.5-fpm

# Gerekli sistem paketleri ve Git
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    mariadb-client

# PHP Eklentileri (Laravel, WP, CI uyumlu)
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl mysqli

# Composer Kurulumu
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node.js Kurulumu (LTS sürümü)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Çalışma dizini
WORKDIR /var/www