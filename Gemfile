source 'https://rubygems.org'

ruby file: '.ruby-version'

# middleman static site generator
gem 'middleman'
gem 'middleman-autoprefixer'
gem 'middleman-livereload'
# NOTE: middleman-sprockets 4.1.1 fails to import .scss partials
#       https://github.com/middleman/middleman-sprockets/compare/v4.1.0...v4.1.1
#       Error: File to import not found or unreadable: ./variables.scss.
#               on line 1:1 of stdin >> @import "./variables.scss";
#       I think that #source_file_relative_to_root is where the problem is
gem 'middleman-sprockets', '4.1.1'

# ruby 3.3 deprecations from stdlib, depended on by middleman, et al
gem 'base64'
gem 'bigdecimal'
gem 'csv'
gem 'mutex_m'

# assets
gem 'bootstrap'
gem 'terser'

group :development, :test do
  gem 'dotenv' # reading ENV vars from .env file
  gem 'rubocop', require: false # code style guide and linting
end

# Windows and JRuby does not include zoneinfo files,
# so bundle the tzinfo-data gem and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem 'tzinfo'
  gem 'tzinfo-data'
end

# Performance-booster for watching directories on Windows
gem 'wdm', platforms: %i[mingw x64_mingw mswin]
