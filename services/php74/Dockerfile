FROM php:7.4-fpm

# Sistem kütüphanelerini yükle
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

# PHP 7.4 Eklentileri (GD, Zip, MySQL vs.)
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl mysqli

# Composer Kurulumu (Eski PHP sürümleri için 2.2 sürümü daha kararlı olabilir ama latest deneyelim)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node.js Kurulumu (PHP 7.4 eski projeler içindir, Node 16 veya 18 daha uygun olabilir ama 20 de genelde çalışır)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

WORKDIR /var/www