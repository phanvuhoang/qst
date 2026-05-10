#!/bin/bash
set -e
echo "QST Entrypoint - Waiting for MySQL..."
MAX_TRIES=30
TRIES=0
while ! mysql -h "$QST_DB_HOST" -u "$QST_DB_USER" -p"$QST_DB_PASS" -e "SELECT 1" > /dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ $TRIES -ge $MAX_TRIES ]; then
    echo "ERROR: MySQL not available after $MAX_TRIES attempts"
    exit 1
  fi
  echo "Waiting for MySQL... ($TRIES/$MAX_TRIES)"
  sleep 3
done
echo "MySQL ready! Checking database..."
TABLE_COUNT=$(mysql -h "$QST_DB_HOST" -u "$QST_DB_USER" -p"$QST_DB_PASS" "$QST_DB_NAME" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$QST_DB_NAME'" 2>/dev/null || echo "0")
if [ "$TABLE_COUNT" = "0" ]; then
  echo "Initializing QST database from qst.sql..."
  mysql -h "$QST_DB_HOST" -u "$QST_DB_USER" -p"$QST_DB_PASS" "$QST_DB_NAME" < /home/qst.sql
  echo "Database initialized!"
else
  echo "Database already has $TABLE_COUNT tables, skipping init."
fi
echo "Starting Apache..."
exec apache2ctl -D FOREGROUND
