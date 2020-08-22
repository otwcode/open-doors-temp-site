# Base image for build
FROM ruby:alpine3.12 AS build-env
MAINTAINER OTW Open Doors

ARG SITEKEY

# Set up environment variables that will be available to the instance
ENV APP_HOME=/production
ENV RAILS_ENV production
ENV NODE_ENV production
ENV BUNDLE_APP_CONFIG="$APP_HOME/.bundle"

# Create a directory for our application
# and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Installation of dependencies
RUN apk add --update --no-cache \
    # for Nokogiri
    build-base \
    # for MySQL gem
    mariadb-dev \
    # for Raindrops
    linux-headers \
    # for assets compilation
    tzdata \
    # Node
    python2 \
    nodejs-current \
    npm \
    yarn

# Add the Gemfile and install gems
ADD Gemfile* package.json yarn.lock $APP_HOME/
RUN bundle lock
RUN bundle config --global frozen 1 && \
    bundle config set path 'vendor/bundle' && \
    bundle config set without 'development:test:assets' && \
    bundle install && \
    rm -rf vendor/bundle/ruby/2.7.0/cache/*.gem && \
    find vendor/bundle/ruby/2.7.0/gems/ -name "*.c" -delete && \
    find vendor/bundle/ruby/2.7.0/gems/ -name "*.o" -delete

# Copy over the application code and compile Node code
RUN yarn install --production
COPY . $APP_HOME
#RUN sed -i "s/  public_output_path: react\/packs/  public_output_path: $SITEKEY\/react\/packs/g" $APP_HOME/config/webpacker.yml
#RUN sed -i "s/opendoorstempsite/$SITEKEY/g" $APP_HOME/app/javascript/config.js

#RUN bundle exec rails webpacker:install:erb
RUN bundle exec rake assets:precompile

# Configure databases
RUN sed -i "s/opendoorstempsite/$SITEKEY/g" $APP_HOME/config/config.yml
RUN mv $APP_HOME/config/database-docker.yml $APP_HOME/config/database.yml
RUN mv $APP_HOME/config/cable-docker.yml $APP_HOME/config/cable.yml


# Remove folders not needed in resulting image
RUN rm -rf tmp/cache vendor/assets spec

# Base image
FROM ruby:alpine3.12
MAINTAINER OTW Open Doors

ARG SITEKEY
ARG APP_HOME=/production

ENV RAILS_ENV production
ENV BUNDLE_APP_CONFIG="$APP_HOME/.bundle"
ENV SITEKEY SITEKEY

# Install runtime packages
RUN apk add --update --no-cache \
    # for MySQL
    mariadb-dev \
#    # for assets compilation
    tzdata \
    nodejs-current

COPY --from=build-env $APP_HOME $APP_HOME
WORKDIR $APP_HOME

# Direct logs to stdout so they're visible outside the container
RUN ln -sf /proc/1/fd/1 $APP_HOME/log/production.log

# Configure bundler and start the app
RUN ls $APP_HOME
RUN bundle config set path 'vendor/bundle'
ENTRYPOINT ["bundle", "exec"]
EXPOSE 3011
CMD bundle exec rails s -b 0.0.0.0 -p 3011