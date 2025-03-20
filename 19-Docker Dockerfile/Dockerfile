FROM debian:bookworm-slim

# Устанавливаем необходимые пакеты, включая envsubst
RUN apt-get update && apt-get install -y \
    nginx openssl gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Создаем директорию для сертификатов
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=MyCompany/CN=localhost"

# Создаем HTML-страницу
RUN echo '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Docker</title></head><body><h1>Привет, я твой Docker контейнер!</h1></body></html>' \
    > /var/www/html/index.html

# Используем переменную окружения для порта SSL (по умолчанию 5432)
ENV SSL_PORT=5432

# Настраиваем Nginx для работы с HTTPS и редиректа с HTTP
RUN mkdir -p /etc/nginx/templates && \
    printf "server {\n\
    listen \$SSL_PORT ssl;\n\
    ssl_certificate /etc/nginx/ssl/nginx.crt;\n\
    ssl_certificate_key /etc/nginx/ssl/nginx.key;\n\
    root /var/www/html;\n\
    index index.html;\n\
    charset utf-8;\n\
}\n\
\n\
server {\n\
    listen 80;\n\
    return 301 https://\$host:\$SSL_PORT\$request_uri;\n\
}" > /etc/nginx/templates/default.conf.template

# Открываем порты
EXPOSE 80 5432

# Запуск Nginx с динамической заменой порта SSL
ENTRYPOINT ["sh", "-c"]
CMD ["envsubst '$SSL_PORT' < /etc/nginx/templates/default.conf.template > /etc/nginx/sites-enabled/default && exec nginx -g 'daemon off;'"]
