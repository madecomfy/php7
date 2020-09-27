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
    php7.4-fpm php7.4-dev php7.4-mysql php7.4-xml \
    php7.4-curl php7.4-intl php-pear php7.4-mbstring php7.4-gd

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '795f976fe0ebd8b75f26a6dd68f78fd3453ce79f32ecb33e7fd087d39bfeb978342fb73ac986cd4f54edd0dc902601dc') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv /composer.phar /usr/bin/composer && chmod +x /usr/bin/composer

RUN apt-get install -y python-pip && pip install awscli

RUN pecl install pcov

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs nodejs-dev node-gyp libssl1.0-dev && \
    apt-get install -y npm && \
    npm install -g yarn

RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/local/bin/cc-test-reporter \
    && chmod +x /usr/local/bin/cc-test-reporter

RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y

RUN mkdir -p /var/www/html

RUN rm -f /etc/php/7.4/fpm/pool.d/*
COPY conf/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY conf/pool.d/zz-docker.conf /etc/php/7.4/fpm/pool.d/zz-docker.conf
COPY conf/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf
COPY conf/php.ini /etc/php/7.4/fpm/php.ini
COPY conf/cli.ini /etc/php/7.4/cli/php.ini

RUN service php7.4-fpm start

EXPOSE 9000
CMD ["php-fpm7.4", "--nodaemonize", "--force-stderr"]
