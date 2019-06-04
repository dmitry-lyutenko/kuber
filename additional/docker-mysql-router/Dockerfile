FROM oraclelinux:7-slim

ARG MYSQL_ROUTER_PACKAGE=mysql-router
ARG MYSQL_SHELL_PACKAGE=mysql-shell

RUN     yum install -y https://repo.mysql.com/mysql-community-minimal-release-el7.rpm \
    &&  yum install -y https://repo.mysql.com/mysql-community-release-el7.rpm \
    && yum-config-manager --enable mysql80-server-minimal \
    && yum install -y $MYSQL_ROUTER_PACKAGE $MYSQL_SHELL_PACKAGE libpwquality \
    && yum clean all

EXPOSE 6446
EXPOSE 64460
EXPOSE 6447
EXPOSE 64470

CMD ["/usr/bin/sleep","30000"]




# docker run --rm --network host -e "MYSQL_CLUSTER_ADMIN_USERNAME=admin" -e "MYSQL_CLUSTER_ADMIN_PASSWORD=_AdminPassword2" router