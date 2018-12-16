# Base image
FROM ruby:2.3.7-alpine
MAINTAINER OTW Open Doors

# Set up environment variables that will be available to the instance
ENV APP_HOME /production
ENV RAILS_ENV production

# Installation of dependencies
RUN apk add --update --no-cache \
    # for Nokogiri
    build-base \
    # for MySQL
    mariadb-dev \
    # for Raindrops
    linux-headers \
    # for assets compilation
    tzdata \
    # Node
    nodejs \
    npm \
    yarn \
    # Databases
    redis

# Create a directory for our application
# and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add our Gemfile
# and install gems

ADD Gemfile* $APP_HOME/
RUN bundle install

# Copy over our application code
ADD . $APP_HOME
RUN npm install --only=production
RUN yarn install
RUN bundle exec rake assets:precompile

# Run our app
EXPOSE 3000
CMD bundle exec rails s -b '0.0.0.0'