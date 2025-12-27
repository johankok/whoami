FROM ruby:3.4.8-alpine AS build

RUN apk add --no-cache --update build-base sqlite-dev tzdata

ENV APP_PATH /usr/src/app
ENV APP_USER appuser
ENV APP_GROUP appgroup

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true

RUN addgroup -S $APP_GROUP && adduser -S -s /sbin/nologin -G $APP_GROUP $APP_USER && mkdir ${APP_PATH} && chown -R ${APP_USER}:${APP_GROUP} ${APP_PATH}

USER $APP_USER
WORKDIR $APP_PATH

COPY --chown=$APP_USER:$APP_GROUP Gemfile Gemfile.lock $APP_PATH

RUN bundle config set deployment 'true' \
  && bundle config frozen 1 \
  && bundle config without 'development test' \
  && bundle install --jobs $(nproc) --retry 5 \
  && rm -rf vendor/bundle/ruby/*/cache/

COPY --chown=$APP_USER:$APP_GROUP . $APP_PATH
RUN rm config/credentials.yml.enc && EDITOR=/bin/true bundle exec rails credentials:edit && bundle exec rake assets:precompile

FROM ruby:3.4.8-alpine

RUN apk add --no-cache --update sqlite-libs tzdata

ENV APP_PATH /usr/src/app
ENV APP_USER appuser
ENV APP_GROUP appgroup

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true

RUN addgroup -S $APP_GROUP && adduser -S -s /sbin/nologin $APP_USER

USER $APP_USER

WORKDIR $APP_PATH

COPY --chown=$APP_USER:$APP_GROUP bin/container-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["container-entrypoint.sh"]

COPY --from=build --chown=$APP_USER:$APP_GROUP $BUNDLE_APP_CONFIG $BUNDLE_APP_CONFIG
COPY --from=build --chown=$APP_USER:$APP_GROUP $APP_PATH $APP_PATH

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0" ]

