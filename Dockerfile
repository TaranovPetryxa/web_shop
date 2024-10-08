# Используем официальный образ PHP с необходимыми расширениями
FROM php:7.4-apache

# Установка необходимых расширений PHP для PrestaShop
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libonig-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mysqli opcache

# Установка Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Настройка Apache
RUN a2enmod rewrite

# Установка PrestaShop
RUN curl -LO https://github.com/PrestaShop/PrestaShop/releases/download/1.7.8.7/prestashop_1.7.8.7.zip \
    && unzip prestashop_1.7.8.7.zip -d /var/www/html/ \
    && rm prestashop_1.7.8.7.zip

# Настройка прав доступа
RUN chown -R www-data:www-data /var/www/html/ \
    && chmod -R 755 /var/www/html/

# Установка переменных окружения для PrestaShop
ENV PS_DEV_MODE=true \
    PS_INSTALL_AUTO=1 \
    DB_SERVER=db_host \
    DB_NAME=prestashop \
    DB_USER=root \
    DB_PASSWORD=root \
    DB_PREFIX=ps_

# Открытие порта 80 для работы приложения
EXPOSE 80

# Указание команды для запуска Apache
CMD ["apache2-foreground"]
