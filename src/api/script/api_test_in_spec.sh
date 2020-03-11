#!/bin/bash -e

### define some variables
BASE_DIR=$PWD
TEMP_DIR=$BASE_DIR/tmp
MYSQL_BASEDIR=$TEMP_DIR/mysql/
MYSQL_DATADIR=$MYSQL_BASEDIR/data
MYSQL_EXTRA_CONF=$TEMP_DIR/my.cnf.add
MEMCACHED_PID_FILE=$TEMP_DIR/memcached.pid
MYSQL_SOCKET_DIR=`mktemp -d`
MYSQL_SOCKET=$MYSQL_SOCKET_DIR/mysql.socket

MYSQL_SERVER=
for dir in /usr/bin /usr/sbin /usr/libexec; do
  if [ -x "$dir/mysqld" ]; then
    MYSQL_SERVER="$dir/mysqld"
    break
  fi
done
if [ -z "$MYSQL_SERVER" ]; then
  echo mysqld not found >&2
  exit 1
fi

cat << EOF > $MYSQL_EXTRA_CONF
[mysqld]
plugin-load-add = auth_socket.so
EOF

MEMCACHED_SERVER=
for dir in /usr/bin /usr/sbin /usr/libexec; do
  if [ -x "$dir/memcached" ]; then
    MEMCACHED_SERVER="$dir/memcached"
    break
  fi
done
if [ -z "$MEMCACHED_SERVER" ]; then
  echo memcached not found >&2
  exit 1
fi

MYSQLD_USER=`whoami`
if [[ $EUID == 0 ]];then
  MYSQLD_USER=mysql
  MEMCACHED_USER="-u memcached"
fi

### define some function
kill_memcached() {
  if [[ -f  $MEMCACHED_PID_FILE ]];then
    MEMCACHED_PID=$(cat $MEMCACHED_PID_FILE)
    if [[ $MEMCACHED_PID ]];then
      kill  $MEMCACHED_PID;
    fi
  fi
}

### do testing now

rm -rf $MYSQL_DATADIR $MYSQL_SOCKET
mkdir -p $MYSQL_BASEDIR
chown -R $MYSQLD_USER $MYSQL_BASEDIR
mysql_install_db --user=$MYSQLD_USER --datadir=$MYSQL_DATADIR --auth-root-authentication-method=socket --auth-root-socket-user=$MYSQLD_USER --defaults-extra-file=$MYSQL_EXTRA_CONF
$MYSQL_SERVER --defaults-extra-file=$MYSQL_EXTRA_CONF --user=$MYSQLD_USER --datadir=$MYSQL_DATADIR --skip-networking --socket=$MYSQL_SOCKET --pid-file=$TEMP_DIR/mysqld.pid &
sleep 2

##################### api

# setup files
cp config/options.yml{.example,}
cp config/thinking_sphinx.yml{.example,}
touch config/test.sphinx.conf
cat > config/database.yml <<EOF
development:
  adapter:  mysql2
  host:     localhost
  database: api_25
  username: $MYSQLD_USER
  encoding: utf8
  socket:   $MYSQL_SOCKET
test:
  adapter:  mysql2
  host:     localhost
  database: api_test
  username: $MYSQLD_USER
  encoding: utf8
  socket:   $MYSQL_SOCKET
  # disable timeout, required on SLES 11 SP3 at least
  connect_timeout:

EOF

$MEMCACHED_SERVER $MEMCACHED_USER -l 127.0.0.1 -d -P $MEMCACHED_PID_FILE || exit 1

# migration test
export RAILS_ENV=development
bundle.ruby2.5 exec rake.ruby2.5 db:create || exit 1
mv db/structure.sql db/structure.sql.git
xzcat test/dump_2.5.sql.xz | mysql  -u $MYSQLD_USER --socket=$MYSQL_SOCKET
bundle.ruby2.5 exec rake.ruby2.5 db:migrate:with_data db:structure:dump db:drop || exit 1
./script/compare_structure_sql.sh db/structure.sql.git db/structure.sql || exit 1

# entire test suite
export RAILS_ENV=test
bundle.ruby2.5 exec rake.ruby2.5 db:create db:setup || exit 1

for suite in "rake.ruby2.5 test:api" "rake.ruby2.5 test:spider" "rspec"; do
  rm -f log/test.log
  bundle.ruby2.5 exec rails assets:precompile

  # Configure the frontend<->backend connection settings
  if [ "$suite" = "rspec" ]; then
    perl -pi -e 's/source_host: localhost/source_host: backend/' config/options.yml
    perl -pi -e 's/source_port: 3200/source_port: 5352/' config/options.yml
  else
    perl -pi -e 's/source_host: backend/source_host: localhost/' config/options.yml
    perl -pi -e 's/source_port: 5352/source_port: 3200/' config/options.yml
  fi
  if ! (set -x; bundle.ruby2.5 exec $suite); then
    # dump log only in package builds
    [[ -n "$RPM_BUILD_ROOT" ]] && cat log/test.log
    kill_memcached
    exit 1
  fi
done

kill_memcached

#cleanup
/usr/bin/mysqladmin -u $MYSQLD_USER --socket=$MYSQL_SOCKET shutdown || true
rm -rf $MYSQL_DATADIR $MYSQL_SOCKET_DIR

exit 0
