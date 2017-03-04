#!/usr/bin/env bash
# Kill a given instance of a temporary website - this may leave workers still running

sitekey=$1
kill -9 $(ps -ef | grep "puma 3.6.2 (unix:///var/www/opendoors/$sitekey" | awk '{print $2}')
