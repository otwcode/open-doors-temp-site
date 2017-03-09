#!/usr/bin/env bash
# Start a given instance of a temporary website using the run-puma script

sitekey=$1
echo "Starting $sitekey"
./stop.sh $sitekey
/sbin/start-stop-daemon --verbose --start --chdir /var/www/opendoors/${sitekey} \
    --chuid opendoors_web \
    --background \
    --exec /usr/local/bin/run-puma -- ${sitekey}
