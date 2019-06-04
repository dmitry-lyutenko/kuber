#!/bin/sh

DATA_DIR="/data"
CMD="mysqld"
MYSQL_RANDOM_ROOT_PASSWORD=$(pwmake $(dd if=/dev/random bs=1 count=1 2>/dev/null))

if [ -z "$MYSQL_CLUSTER_ADMIN_USERNAME" ]; then
  echo "Error. Please set MYSQL_CLUSTER_ADMIN_USERNAME"
	exit 1
fi

if [ -z "$MYSQL_CLUSTER_ADMIN_PASSWORD" ]; then
  echo "Error. Please set MYSQL_CLUSTER_ADMIN_PASSWORD"
	exit 1
fi

# Create datadir
mkdir $DATA_DIR
chown mysql:mysql $DATA_DIR

# Init and get root temporary password ( !!! tee )
$CMD --datadir $DATA_DIR --initialize --user=mysql 2>&1 | tee /tmp/mysql.init
mysql_root_temporary_password=$(grep temporary\ password /tmp/mysql.init | awk '{print $13}')

if [ -z "$mysql_root_temporary_password" ]; then
  exit 1
  echo "Error. Failed init."
fi

# Run mysql and store PID
$CMD --datadir $DATA_DIR --user=mysql --bind-address=127.0.0.1 & mysqld_pid="$!"

# Waiting mysql
status=255
while [ $status -gt 0 ]; do
    echo Waiting mysql
    sleep 2
    `2>/dev/null echo "" > /dev/tcp/127.0.0.1/3306 || exit 1`
    status=$?
done

# Alter root password
mysql -u root --password="$mysql_root_temporary_password" --connect-expired-password \
      -NBe "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_RANDOM_ROOT_PASSWORD';"

mysql -u root --password="$MYSQL_RANDOM_ROOT_PASSWORD" \
      -NBe "CREATE USER $MYSQL_CLUSTER_ADMIN_USERNAME IDENTIFIED WITH mysql_native_password BY '$MYSQL_CLUSTER_ADMIN_PASSWORD';
            GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_CLUSTER_ADMIN_USERNAME ' WITH GRANT OPTION;"

echo -e "[client]\nuser=root\npassword=\"$MYSQL_RANDOM_ROOT_PASSWORD\"" > /root/.my.cnf

HOSTNAME=$(hostname)

echo "$MYSQL_CLUSTER_ADMIN_PASSWORD" | \
mysqlsh -e "dba.configureLocalInstance('$MYSQL_CLUSTER_ADMIN_USERNAME@$HOSTNAME:3306');" --passwords-from-stdin


kill $mysqld_pid

while [ $(ls /proc/$mysqld_pid > /dev/null 2>/dev/null; echo $?) -eq 0 ]; do
  sleep 1
done

exec $CMD --datadir $DATA_DIR --user=mysql

