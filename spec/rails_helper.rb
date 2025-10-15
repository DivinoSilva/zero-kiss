# frozen_string_literal: true

require "dotenv/load"
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Load support files (helpers, custom matchers, etc.)
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Keep schema up to date for tests
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Fixtures (optional)
  config.fixture_paths = [Rails.root.join("spec/fixtures")]

  # Transactions per example
  config.use_transactional_fixtures = true

  # Infer spec type by file location (models, requests, etc.)
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot DSL
  config.include FactoryBot::Syntax::Methods

  # Auth helper (JWT) for request specs and rswag integration specs
  config.include AuthHelpers, type: :request
  config.include AuthHelpers, file_path: %r{spec/integration}
end
