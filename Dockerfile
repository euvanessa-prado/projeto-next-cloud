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
    libmagickwand-dev \
    libmemcached-dev \
    libldap2-dev \
    libsmbclient-dev \
    supervisor \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensões PHP necessárias para Nextcloud
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) \
    gd \
    zip \
    intl \
    pdo \
    pdo_pgsql \
    pdo_mysql \
    opcache \
    curl \
    xml \
    mbstring \
    bz2 \
    gmp \
    bcmath \
    exif \
    ldap \
    sysvsem

# Instalar extensões PECL
RUN pecl install imagick redis apcu \
    && docker-php-ext-enable imagick redis apcu

# Habilitar módulos Apache
RUN a2enmod rewrite headers env dir mime ssl

# Configurações PHP otimizadas
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=1'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.validate_timestamps=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
    echo 'memory_limit=1G'; \
    echo 'upload_max_filesize=16G'; \
    echo 'post_max_size=16G'; \
    echo 'max_execution_time=3600'; \
    echo 'max_input_time=3600'; \
    echo 'max_file_uploads=100'; \
    echo 'default_phone_region=BR'; \
    } > /usr/local/etc/php/conf.d/nextcloud.ini

RUN { \
    echo 'apc.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/apcu.ini

# Configurar Apache
RUN { \
    echo 'ServerTokens Prod'; \
    echo 'ServerSignature Off'; \
    } >> /etc/apache2/apache2.conf

# Copiar arquivos do Nextcloud
COPY nextcloud-files/ /var/www/html/

# Criar diretórios necessários
RUN mkdir -p /var/www/html/data /var/www/html/custom_apps \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Configurar cron para Nextcloud
RUN echo "*/5 * * * * www-data php -f /var/www/html/cron.php" >> /etc/crontab

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/status.php || exit 1

EXPOSE 80

CMD ["apache2-foreground"]
 