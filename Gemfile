source "https://rubygems.org"
ruby "3.3.2"

gem "active_model_serializers", "~> 0.10"
gem "bootsnap", require: false
gem "debug", platforms: [:mri, :mingw, :x64_mingw, :mswin]
gem "dotenv-rails", groups: [:development, :test]
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "rack-cors", "~> 2.0"
gem "rails", "~> 7.2.2", ">= 7.2.2.2"

group :development, :test do
  gem "rswag-api", "~> 2.13"
  gem "rswag-ui",  "~> 2.13"
  gem "rswag-specs","~> 2.13"

  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
end

group :development do
  gem "brakeman"
  gem "rubocop-rails-omakase"
end
