FROM ubuntu:trusty
MAINTAINER Elliot Wright <elliot@elliotwright.co>

ENV MYSQL_UID 1000
ENV MYSQL_DATABASE docker
ENV MYSQL_USER docker
ENV MYSQL_PASS docker
ENV TERM dumb

COPY ./provisioning/docker-entrypoint.sh /

# Install MariaDB
RUN \
    useradd -u 1000 -m -s /bin/bash mysql && \
    apt-get update && \
    { \
        echo mysql-server mysql-server/root_password password 'unused'; \
        echo mysql-server mysql-server/root_password_again password 'unused'; \
    } | debconf-set-selections && \
    apt-get install -y \
        mysql-server \
        pwgen && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql && \
    mkdir -p /var/lib/mysql && \
    chown -R mysql: /var/lib/mysql && \
    chmod +x /docker-entrypoint.sh

# Configure MariaDB
RUN \
  sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf && \
  sed -Ei 's/#bind-address\s+=\s+127.0.0.1/bind-address=0.0.0.0/g' /etc/mysql/my.cnf

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /var/lib/mysql

EXPOSE 3306

CMD ["mysqld"]
