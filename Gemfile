source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

# jekyll static site generator
gem 'env'
gem 'middleman'
gem 'middleman-autoprefixer'
gem 'middleman-livereload'
gem 'middleman-sprockets'

# # ruby 3.3 deprecations from stdlib, depended on by middleman, et al
gem 'base64'
gem 'bigdecimal'
gem 'csv'
gem 'mutex_m'

# assets
gem 'bootstrap'
gem 'terser'

group :development, :test do
  # codestyle guide and linting
  gem 'rubocop', require: false
end

# Windows and JRuby does not include zoneinfo files,
# so bundle the tzinfo-data gem and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem 'tzinfo'
  gem 'tzinfo-data'
end

# Performance-booster for watching directories on Windows
gem 'wdm', platforms: %i[mingw x64_mingw mswin]
