source "https://rubygems.org"
ruby "3.3.2"

gem "rails", "~> 7.2.2", ">= 7.2.2.2"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "rack-cors", "~> 2.0"
gem "bootsnap", require: false

gem "debug", platforms: [:mri, :windows]
gem "tzinfo-data", platforms: [:windows, :jruby]

group :development do
  gem "rswag-api", "~> 2.13"
  gem "rswag-ui", "~> 2.13"
  gem "rswag-specs", "~> 2.13"
  gem "brakeman"
  gem "rubocop-rails-omakase"
end

group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
end
