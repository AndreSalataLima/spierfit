source "https://rubygems.org"

ruby "3.4.2"

gem "rails", "~> 8.0.2"
gem "pg", "~> 1.1"                  # Keep pg here for all environments (including production)
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "sprockets-rails"
gem "tailwindcss-rails"
gem "devise"
gem "hotwire-rails"
gem "httparty"
gem "rest-client"
gem "dotenv-rails"                  # Only keep dotenv-rails once here
gem "chartkick"
gem "groupdate", ">= 6.5.1"
gem "clockwork"
gem "redis"                         # Only keep redis here once for all environments
gem "rack-cors", require: 'rack/cors'
gem "font-awesome-sass"
gem "haml-rails"
gem "terser"
gem 'bootsnap', '>= 1.4.4', require: false
gem 'benchmark'
gem 'devise_token_auth'



group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails'    # Use RSpec for testing
  # gem 'bullet'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

group :development do
  gem "web-console"     # For console access on error pages
  # gem 'rack-mini-profiler'
  gem "kamal"
end

gem "tzinfo-data", platforms: %i[windows jruby]
gem "ffi", "< 1.17.0"
