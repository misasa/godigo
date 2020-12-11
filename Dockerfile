FROM ruby:2.7

RUN gem install bundler -v 2.1.2
WORKDIR /usr/src/app
COPY . .
RUN bundle install
RUN rm -r pkg | bundle exec rake build *.gemspec
RUN gem install pkg/*.gem
ARG UID=1001
ARG GID=1001
RUN addgroup -gid ${GID} medusa && useradd -m --shell /bin/sh --gid ${GID} --uid ${UID} medusa 
USER medusa
WORKDIR /home/medusa
