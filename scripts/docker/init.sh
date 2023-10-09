#!/bin/bash

set -ex

# Change directory to root of the repo
cd "$(dirname "$0")/../.."

filename='database.yml'

# Manual backup as the --backup option is not available for all versions of cp
test -f "config/$filename" && cp "config/$filename" "config/$filename~"
cp "config/docker/$filename" "config/$filename"

docker-compose up -d

sleep 60

#Setting up the rails db
docker-compose run --rm web bundle exec rake db:drop
docker-compose run --rm web bundle exec rake db:create
docker-compose run --rm web bundle exec rake db:schema:load
docker-compose run --rm web bundle exec rake db:migrate

#Makes sure the rails server runs properly
docker-compose run --rm web bundle exec rake app:update:bin

#Needed for the front-end
docker-compose run --rm web bundle exec rake assets:precompile

#Start server on localhost
docker-compose up -d web
