# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Load support files (e.g., FactoryBot config, helpers)
Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

# Keep schema up to date for tests
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Fixtures directory (optional; keep if you use fixtures)
  config.fixture_paths = [Rails.root.join("spec/fixtures")]

  # DB transactions per example
  config.use_transactional_fixtures = true

  # Nice defaults
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot DSL (create, build, etc.)
  config.include FactoryBot::Syntax::Methods
end
