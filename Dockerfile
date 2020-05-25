FROM ruby:2.6

#RUN bundle config --global frozen 1
WORKDIR /usr/src/app
COPY . .
RUN bundle install
COPY ./data/dotgodigorc /root/.godigorc
CMD ["/bin/sh"]