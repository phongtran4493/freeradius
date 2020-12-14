FROM ubuntu:20.04

ENV TZ=Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
 && apt-get update -y \
 && apt-get upgrade -y \
 && apt-get install --yes --no-install-recommends \
                    apt-utils \
                    tzdata \
                    apache2 \
                    libapache2-mod-php \
                    cron \
                    freeradius-config \
                    freeradius-utils \
                    freeradius \
                    freeradius-common \
                    freeradius-mysql \
                    net-tools \
                    php \
                    php-common \
                    php-gd \
                    php-curl \
                    php-mail \
                    php-mail-mime \
                    php-db \
                    php-mysql \
                    mariadb-client \
                    libmysqlclient-dev \
                    supervisor \
                    unzip \
                    wget \
 && rm -rf /var/lib/apt/lists/*
 
RUN ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/ \
 && update-ca-certificates -f \
 && mkdir -p /tmp/pear/cache \
 && wget http://pear.php.net/go-pear.phar \
 && php go-pear.phar \
 && rm go-pear.phar \
 && pear channel-update pear.php.net \
 && pear install -a -f DB \
 && pear install -a -f Mail \
 && pear install -a -f Mail_Mime


COPY ./supervisor-apache2.conf /etc/supervisor/conf.d/apache2.conf
COPY ./supervisor-freeradius.conf /etc/supervisor/conf.d/freeradius.conf
#COPY ./freeradius/eap /etc/freeradius/3.0/mods-available/eap
#COPY ./freeradius/mschap /etc/freeradius/3.0/mods-available/mschap
COPY freeradius-default-site /etc/freeradius/3.0/sites-available/default
COPY  ./supervisor.conf /etc/supervisor.conf
COPY ./initDB.sh /opt/initDB.sh
#COPY ./init.sh /opt/init.sh

ENV DALO_VERSION 1.1-3

RUN wget https://github.com/lirantal/daloradius/archive/"$DALO_VERSION".zip \
 && unzip "$DALO_VERSION".zip \
 && rm "$DALO_VERSION".zip \
 && mv daloradius-"$DALO_VERSION" /var/www/html/daloradius \
 && chown -R www-data:www-data /var/www/html/daloradius \
 && chmod 664 /var/www/html/daloradius/library/daloradius.conf.php \
 &&  chmod +x /opt/initDB.sh

EXPOSE 1812 1813 80


CMD ["sh", "/opt/initDB.sh"]
