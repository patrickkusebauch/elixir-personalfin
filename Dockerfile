# Elixir + Phoenix

FROM elixir:latest

# Install debian packages
RUN apt-get update
RUN apt-get install --yes build-essential inotify-tools postgresql-client

# Install Phoenix packages
RUN mix local.hex --force
RUN mix local.rebar --force
RUN wget https://github.com/phoenixframework/archives/raw/master/phx_new.ez && mix archive.install ./phx_new.ez

# Install node
RUN apt-get install --yes nodejs npm

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    bzip2 \
    libfontconfig

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && mkdir /tmp/phantomjs \
  && curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    | tar -xj --strip-components=1 -C /tmp/phantomjs \
  && cd /tmp/phantomjs \
  && mv bin/phantomjs /usr/local/bin

ENV OPENSSL_CONF=/dev/null
RUN phantomjs --wd &

WORKDIR /app
EXPOSE 4000
