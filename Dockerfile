FROM ruby:2.6.0-alpine as builder

WORKDIR /usr/src/app

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev mysql-dev" \
    RUBY_PACKAGES="ruby-io-console ruby-json yaml"

RUN \
  apk --update --upgrade add $BUILD_PACKAGES $RUBY_PACKAGES $DEV_PACKAGES

COPY Gemfile* ./
RUN bundle install
COPY . .


FROM ruby:2.6.0-alpine as prod
WORKDIR /usr/src/app

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true

RUN apk add --no-cache \
        mysql-dev \
        tzdata

COPY --from=builder /usr/src/app .
COPY --from=builder /usr/local/bundle /usr/local/bundle

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]