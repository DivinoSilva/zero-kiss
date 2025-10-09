FROM ruby:3.3.2

ENV BUNDLE_PATH=/gems \
    BUNDLE_WITHOUT="production"

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY . /app

EXPOSE 3000
CMD ["bash", "-lc", "bundle exec puma -C config/puma.rb"]
