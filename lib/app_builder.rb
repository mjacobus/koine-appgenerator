
module Koine
  class AppBuilder < Rails::AppBuilder

    def install_rspec
      say "installing rspec"
      template_dir('spec')
      template '.rspec'

      configure_rspec
    end

    def require_test_gems
      inject_into_file 'spec/rails_helper.rb', after: "require 'rspec/rails'" do <<-RUBY

require 'capybara/rspec'
require 'webmock/rspec'
require 'shoulda/matchers'
RUBY
      end
    end

    def configure_rspec
      require_test_gems

      inject_into_file 'spec/rails_helper.rb', after: /^end$/ do <<-RUBY


Dir[Rails.root.join('spec/support/**/*.rb')].each do |file|
  begin
    require file
  rescue NameError => e
    puts "Could not load file \#{file}: \#{e.message}"
  end
end

RSpec.configure do |config|
  # config.include Records
  # config.include Devise::TestHelpers, type: :controller
  # config.include Formulaic::Dsl, type: :feature
  # config.include CapybaraHelper, type: :feature
end

Capybara.configure do |config|
  config.always_include_port = true
  config.app_host = 'http://example.com'
end

# Capybara.javascript_driver = :webkit
WebMock.disable_net_connect!(allow_localhost: true)

RUBY
      end
    end

    def configure_generators
      config = <<-RUBY
    config.generators do |generate|
      generate.decorator false
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs true
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
      generate.fixture_replacement :machinist
    end

      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end
  end
end