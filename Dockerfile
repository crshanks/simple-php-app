FROM php:8.0-cli

WORKDIR /var/www/html

COPY src/ .

CMD ["php", "-S", "0.0.0.0:8080", "-t", "."]