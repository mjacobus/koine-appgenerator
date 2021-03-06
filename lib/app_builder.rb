module Koine
  class AppBuilder < Rails::AppBuilder

    def set_up_test_environment
      say "installing rspec"
        gem_group(:test) do
          gem 'rspec-rails', '~> 3.1.0'
          gem 'coveralls', require: false
          gem 'simplecov', require: false
          gem 'capybara'
          # gem 'capybara-webkit', '>= 1.0.0'
          gem 'database_cleaner'
          # gem 'launchy'
          gem 'shoulda-matchers', require: false
          gem 'simplecov', require: false
          gem 'timecop'
          gem 'webmock'
          gem 'machinist'
          gem 'spring-commands-rspec'
        end
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
      configure_coverage
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

    def configure_coverage
      first_line = 'ENV["RAILS_ENV"]'
      inject_into_file 'spec/rails_helper.rb', before: first_line do <<-RUBY

require 'simplecov'
SimpleCov.start 'rails'

RUBY
      end

      run "echo coveralls >> .gitignore"
    end

    def travis
      template '.travis.yml.erb', '.travis.yml'
    end

    def coveralls
      template '.coveralls.yml'
    end

    def readme
      template 'README.md.erb', 'README.md'
    end

    def disable_turbolinks
      replace_in_file 'app/assets/javascripts/application.js',
        /\/\/= require turbolinks\n/,
        ''
      replace_in_file 'Gemfile', /^.*turbolinks.*$/, ''
    end

    def set_home_page
      template_dir "app/views/pages"
      template "app/controllers/pages_controller.rb"

      unless options[:skip_rspec]
        template "spec/controllers/pages_controller_spec.rb"
      end

      route 'root to: "pages#show", id: "home"'
    end

    def remove_comments_from_routes_file
      replace_in_file 'config/routes.rb',
        /.draw do.*end/m,
        ".draw do\nend"
    end

    def set_up_smtp
      template 'config/initializers/smtp_initializer.rb'
      template 'config/smtp.yml.erb', 'config/smtp.yml'
      template 'config/smtp.yml.erb', 'config/smtp.yml.dist'
      git_ignore 'config/smtp.yml'
    end

    def configure_action_mailer
      action_mailer_host 'development', "#{app_name}.local"
      action_mailer_host 'test', 'www.example.com'
      action_mailer_host 'staging', "staging.#{app_name}.com"
      action_mailer_host 'production', "#{app_name}.com"
    end

    def setup_staging_environment
      template 'config/environments/staging.rb.erb',
        'config/environments/staging.rb'
    end

    def raise_on_delivery_errors
      replace_in_file 'config/environments/development.rb',
        'raise_delivery_errors = false',
        'raise_delivery_errors = true'
    end

    def raise_on_unpermitted_params
      raise_on_unpermitted_params_on('development')
      raise_on_unpermitted_params_on('test')
    end

    def configure_time_zone
      config = <<-RUBY
    config.active_record.default_timezone = :utc

RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def raise_on_unpermitted_params_on(environment)
      action_on_unpermitted_parameters = <<-RUBY


  # Raise an ActionController::UnpermittedParameters exception when
  # a parameter is not explcitly permitted but is passed anyway.
  config.action_controller.action_on_unpermitted_parameters = :raise

RUBY

      inject_into_file(
        "config/environments/#{environment}.rb",
        action_on_unpermitted_parameters,
        before: "\nend"
      )
    end

    def customize_error_pages
      meta_tags =<<-EOS
  <meta charset='utf-8' />
  <meta name='ROBOTS' content='NOODP' />
      EOS

      %w(500 404 422).each do |page|
        inject_into_file "public/#{page}.html", meta_tags, :after => "<head>\n"
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def copy_locale_files
      remove_file 'config/locales/en.yml'
      copy_dir 'config/locales'
      copy_file 'config/locales/en.yml.erb', 'config/locales/en.yml', force: true
    end

    def install_zurb_fundation
      generate "foundation:install"

      # application layout
      template 'app/views/layouts/application.html.erb.erb',
        'app/views/layouts/application.html.erb',
        force: true
    end

    def set_up_assets
      # css
      template_file = 'app/assets/stylesheets/application.css.scss.erb'
      file          = template_file.gsub('.erb', '')
      remove_file file.gsub('.scss', '')

      copy_file template_file, file

      # js
      template_file = 'app/assets/javascripts/application.js.erb'
      file          = template_file.gsub('.erb', '')
      remove_file file.gsub('.scss', '')

      copy_file template_file, file
    end
  end
end
