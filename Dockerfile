FROM php:8.3-apache

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libbz2-dev \
    libgmp-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensões PHP necessárias para Nextcloud
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    zip \
    intl \
    pdo \
    pdo_pgsql \
    opcache \
    curl \
    xml \
    mbstring \
    bz2 \
    gmp

# Habilitar mod_rewrite do Apache
RUN a2enmod rewrite

# Configurações PHP
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
    echo 'memory_limit=512M'; \
    echo 'upload_max_filesize=512M'; \
    echo 'post_max_size=512M'; \
    echo 'max_execution_time=300'; \
    } > /usr/local/etc/php/conf.d/nextcloud.ini

# Copiar arquivos do Nextcloud
COPY nextcloud-files/ /var/www/html/

# Configurar permissões
RUN chown -R www-data:www-data /var/www/html

# Expor porta 80
EXPOSE 80

# Comando padrão
CMD ["apache2-foreground"]
