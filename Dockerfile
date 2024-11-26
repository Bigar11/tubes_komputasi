# Menggunakan image PHP 8.2 dengan FPM
FROM php:8.2-fpm

# Memasang dependensi sistem yang diperlukan
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
&& docker-php-ext-configure gd --with-freetype --with-jpeg \
&& docker-php-ext-install gd zip pdo pdo_mysql exif \
&& docker-php-ext-enable exif

# Set working directory
WORKDIR /var/www

# Menyalin seluruh file aplikasi ke dalam container
COPY . .

# Memasang Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Menjalankan perintah Composer untuk memasang dependensi PHP
RUN composer install --no-scripts --no-autoloader

# Mengubah kepemilikan direktori storage dan cache agar dapat diakses oleh user www-data
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Menambahkan setup untuk Node.js (versi 16)
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Memasang dependensi JavaScript menggunakan npm
RUN npm install

# Membuat build frontend menggunakan npm
RUN npm run build 

# Mengekspos port 9000 untuk PHP-FPM
EXPOSE 9000

# Menjalankan PHP-FPM
CMD ["php-fpm"]
