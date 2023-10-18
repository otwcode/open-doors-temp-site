#!/bin/bash
set -ex

# Change directory to root of the repo
cd "$(dirname "$0")/../.."

# Change MySQL password
read -sp 'Please set the new MySQL password: ' MYSQL_PASS

cp scripts/docker/docker-compose-template.yml docker-compose.yml
sed -i'' -e "s/change_me/$MYSQL_PASS/g" docker-compose.yml

cp scripts/docker/secrets.yml config/secrets.yml
sed -i'' -e "s/change_me/$MYSQL_PASS/g" config/secrets.yml

for file in 'database.yml' 'cable.yml'
do
  # Manual backup as the --backup option is not available for all versions of cp
  test -f "config/$file" && cp "config/$file" "config/$file~"
  cp "scripts/docker/$file" "config/$file"
done

docker-compose up -d

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

#Create sample SQL file
SQL_FILE="scripts/docker/archive_config.sql"
cp scripts/ansible/templates/archive_config.sql.j2 $SQL_FILE

sed -i'' -e 's/{{ sitekey }}/opendoorstempsite/g' $SQL_FILE
sed -i'' -e 's/{{ name }}/Open Doors Temp Site/g' $SQL_FILE
sed -i'' -e 's/ariana/local/g' $SQL_FILE

#Auto-load sample SQL file
docker-compose exec -T web mysql -h db -uroot -p$MYSQL_PASS opendoorstempsite < $SQL_FILE