FROM jruby:9.0.4.0
MAINTAINER Kareem Kouddous <kareemknyc@gmail.com>

RUN apt-get update && \
    apt-get -qq -y install software-properties-common && \
    apt-get -qq -y install git && \
    apt-get -qq -y install vim && \
    apt-get -qq -y install htop

WORKDIR /app
ADD . /app
RUN bundle install --without development test

CMD bundle exec ./bin/sorceror-blackhole-events
