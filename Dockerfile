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
    php -r "if (hash_file('SHA384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv /composer.phar /usr/bin/composer && chmod +x /usr/bin/composer

RUN apt-get install -y python-pip && pip install awscli

RUN pecl install pcov

RUN apt-get install -y nodejs nodejs-dev node-gyp libssl1.0-dev && \
    apt-get install -y npm && \
    npm install -g yarn && \
    yarn global add gulp-cli && \
    yarn global add webpack

RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/local/bin/cc-test-reporter \
    && chmod +x /usr/local/bin/cc-test-reporter

RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y

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
