FROM ruby:3.3.2

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN mkdir -p log tmp tmp/pids

EXPOSE 3000
CMD ["bash", "-lc", "bundle exec puma -C config/puma.rb"]
