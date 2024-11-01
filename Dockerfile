# Используем официальный образ WordPress
FROM wordpress:latest

# Устанавливаем необходимые расширения PHP (если нужно)
RUN docker-php-ext-install mysqli

# Копируем настройки конфигурации WordPress (если у вас есть)
# COPY wp-config.php /var/www/html/wp-config.php

# Устанавливаем права доступа
RUN chown -R www-data:www-data /var/www/html

# Указываем рабочую директорию
WORKDIR /var/www/html

# Открываем порт 80
EXPOSE 80
