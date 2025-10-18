source 'https://rubygems.org'

ruby file: '.ruby-version'

# middleman static site generator
gem 'middleman'
gem 'middleman-livereload'

group :development, :test do
  gem 'dotenv' # reading ENV vars from .env file
  gem 'herb' # HTML+ERB linting
  gem 'rubocop', require: false # code style guide and linting
end

# Windows and JRuby does not include zoneinfo files,
# so bundle the tzinfo-data gem and associated library.
platforms :windows, :jruby do
  gem 'tzinfo'
  gem 'tzinfo-data'
  # Performance-booster for watching directories on Windows
  gem 'wdm', platforms: :windows
end
