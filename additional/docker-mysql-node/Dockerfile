FROM oraclelinux:7-slim

ARG MYSQL_SERVER_PACKAGE=mysql-community-server-minimal
ARG MYSQL_SHELL_PACKAGE=mysql-shell

RUN     yum install -y https://repo.mysql.com/mysql-community-minimal-release-el7.rpm \
    &&  yum install -y https://repo.mysql.com/mysql-community-release-el7.rpm \
    && yum-config-manager --enable mysql80-server-minimal \
    && yum install -y $MYSQL_SERVER_PACKAGE $MYSQL_SHELL_PACKAGE libpwquality \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY entrypoint.sh /entrypoint.sh
COPY my.cnf /etc/my.cnf

EXPOSE 3306
EXPOSE 33060

ENTRYPOINT ["/entrypoint.sh"]

