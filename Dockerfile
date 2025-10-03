FROM serversideup/php:8.3-fpm-nginx

WORKDIR /var/www/html

# Najprv vytvoríme priečinky s správnymi oprávneniami
RUN mkdir -p storage/logs storage/framework/sessions storage/framework/views storage/framework/cache bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Skopírujeme aplikáciu
COPY --chown=www-data:www-data . .

# Nainštalujeme dependencies BEZ spúšťania post-install scriptov
RUN composer install --no-dev --optimize-autoloader --no-scripts && \
    composer dump-autoload --optimize

# Nastavíme oprávnenia znova po kopírovaní
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 storage bootstrap/cache

# Prepneme sa na www-data užívateľa
USER www-data
