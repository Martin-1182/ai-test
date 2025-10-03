FROM serversideup/php:8.3-fpm-nginx

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader && \
    npm ci && \
    npm run build && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
