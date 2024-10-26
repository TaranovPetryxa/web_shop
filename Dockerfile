# Используем официальное изображение WordPress
FROM wordpress:latest

# Устанавливаем необходимые расширения PHP для работы WordPress и WooCommerce
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli opcache

# Даем необходимые права для плагинов и тем
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Копируем данные для WordPress
 COPY ./wp-content/ /var/www/html/wp-content/

# Открываем порт 80
EXPOSE 80

# Запускаем Apache
CMD ["apache2-foreground"]

