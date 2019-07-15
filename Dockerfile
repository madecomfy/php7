FROM ubuntu:bionic

LABEL maintainer "tom@madecomfy.com.au"

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils gcc libsasl2-dev lib32z1-dev libldap2-dev libssl-dev openssl \
    software-properties-common build-essential \
    apt-transport-https git python libglib2.0-dev \
    curl wget git zip unzip libcurl3-openssl-dev

RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get -y update

RUN apt-get install -y \
    php7.3-fpm php7.3-dev php7.3-mysql php7.3-xml \
    php7.3-curl php7.3-intl php-pear php7.3-mbstring php7.3-gd

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv /composer.phar /usr/bin/composer && chmod +x /usr/bin/composer

RUN apt-get install -y python-pip && pip install awscli

RUN pecl install xdebug

RUN apt-get install -y nodejs nodejs-dev node-gyp libssl1.0-dev && \
    apt-get install -y npm && \
    npm install -g yarn && \
    yarn global add gulp-cli && \
    yarn global add webpack

RUN apt-get update && apt-get upgrade -y

RUN mkdir -p /var/www/html

RUN rm -f /etc/php/7.3/fpm/pool.d/*
COPY conf/pool.d/www.conf /etc/php/7.3/fpm/pool.d/www.conf
COPY conf/pool.d/zz-docker.conf /etc/php/7.3/fpm/pool.d/zz-docker.conf
COPY conf/php-fpm.conf /etc/php/7.3/fpm/php-fpm.conf
COPY conf/php.ini /etc/php/7.3/fpm/php.ini
COPY conf/cli.ini /etc/php/7.3/cli/php.ini

RUN service php7.3-fpm start

EXPOSE 9000
CMD ["php-fpm7.3", "--nodaemonize", "--force-stderr"]
