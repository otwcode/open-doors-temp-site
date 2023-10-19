FROM node:14

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
        npm

# Install ruby
RUN git clone https://github.com/rbenv/ruby-build.git && \
    PREFIX=/usr/local ./ruby-build/install.sh && \
    ruby-build -v 2.7.3 /usr/local

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
RUN npm install

# Default commands to run in a new container
EXPOSE 3010
CMD ["bundle", "exec", "rails", "server", "-p", "3010", "-b", "0.0.0.0"]