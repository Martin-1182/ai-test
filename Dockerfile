FROM serversideup/php:8.2-fpm-nginx

# Nainštalujeme curl pre healthcheck
USER root
RUN apt-get update && apt-get install -y curl && apt-get clean

WORKDIR /var/www/html

# Vytvoríme priečinky s správnymi oprávneniami
RUN mkdir -p storage/logs storage/framework/sessions storage/framework/views storage/framework/cache bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Skopírujeme aplikáciu
COPY --chown=www-data:www-data . .

# Nainštalujeme dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts && \
    composer dump-autoload --optimize

# Nastavíme oprávnenia
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 storage bootstrap/cache

USER www-data
