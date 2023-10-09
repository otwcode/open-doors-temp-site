FROM ruby:2.7.3

# Install additional packages
RUN apt-get update             &&  \
    apt-get install -y             \
        build-essential            \   
        g++                        \
        gcc                        \
        git                        \
        default-mysql-client       \
        make                       \
        software-properties-common \
        zlib1g-dev                 \
        curl                       \
        ca-certificates

# Install nodejs
RUN curl -L https://deb.nodesource.com/setup_14.x | bash && \
	apt-get install -y nodejs

# Clean and mount repository at /tempsite
RUN rm -rf /tempsite && mkdir -p /tempsite
WORKDIR /tempsite
VOLUME /tempsite

# Install ruby packages
COPY Gemfile .
COPY Gemfile.lock .
RUN gem install bundler -v 1.17.3 && bundle install

# Install nodejs packages
COPY package.json .
RUN npm install yarn -g && npm install

# Default commands to run in a new container
EXPOSE 3010
CMD ["bundle", "exec", "rails", "server", "-p", "3010", "-b", "0.0.0.0"]
