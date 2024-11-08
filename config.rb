# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :sprockets
activate :directory_indexes

configure :development do
  activate :livereload
end

activate :autoprefixer do |prefix|
  prefix.browsers = 'last 2 versions'
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

helpers do
  def latest_ruby_version
    data.rubies.ruby.stable[:stable].max
  end

  def implementation_name slug
    data.implementations[String(slug)]['name']
  end

  def implementation_website slug
    data.implementations[String(slug)]['urls']['website']
  end

  def link_to_implementation_website slug
    link_to implementation_website(slug), implementation_website(slug)
  end

  def implementation_status slug
    data.status.select { |_status, rubies| rubies.include? slug }.keys.first
  end

  def implementation_status_color slug
    status = implementation_status(slug).to_sym
    {
      main:        :primary,
      alternative: :info,
      inactive:    :danger
    }[status]
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  activate :minify_css
  activate :minify_javascript, compressor: Terser.new
  activate :asset_hash
  activate :relative_assets
end

# rubies#index
proxy '/all', '/rubies/index.html', layout: 'layout'

# rubies#show
def ruby_slugs
  path = [__dir__, 'data', 'status.yml'].join '/'
  rubies_by_status = YAML.safe_load_file path
  rubies_by_status.values.flatten
end

ruby_slugs.each do |slug|
  proxy slug, '/rubies/show.html', locals: { slug: slug }, ignore: true, layout: 'layout'
end

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/
