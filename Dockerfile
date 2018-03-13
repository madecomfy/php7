FROM ubuntu:trusty

LABEL maintainer "tom@madecomfy.com.au"

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils gcc libsasl2-dev lib32z1-dev libldap2-dev libssl-dev openssl \
    python-software-properties software-properties-common build-essential \
    apt-transport-https git python libglib2.0-dev \
    curl wget git zip unzip libcurl3-openssl-dev

RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update

RUN apt-get install -y --force-yes \
    php7.2-fpm php7.2-dev php7.2-mysql php7.2-xml \
    php7.2-curl php7.2-intl php-pear php7.2-mbstring php7.2-gd

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv /composer.phar /usr/bin/composer && sudo chmod +x /usr/bin/composer

RUN apt-get install -y python-pip && pip install awscli

RUN pecl install xdebug

RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    apt-get install -y nodejs && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn && \
    yarn global add gulp-cli && \
    yarn global add webpack

RUN apt-get update && apt-get upgrade --force-yes -y

RUN mkdir -p /var/www/html

RUN rm -f /etc/php/7.2/fpm/pool.d/*
COPY conf/pool.d/www.conf /etc/php/7.2/fpm/pool.d/www.conf
COPY conf/pool.d/zz-docker.conf /etc/php/7.2/fpm/pool.d/zz-docker.conf
COPY conf/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY conf/php.ini /etc/php/7.2/fpm/php.ini
COPY conf/cli.ini /etc/php/7.2/cli/php.ini

RUN service php7.2-fpm start

EXPOSE 9000
CMD ["php-fpm7.2", "--nodaemonize", "--force-stderr"]
