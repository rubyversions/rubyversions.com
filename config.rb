# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :asset_hash
activate :directory_indexes
activate :relative_assets

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml',  layout: false
page '/*.json', layout: false
page '/*.txt',  layout: false

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

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/
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

  def implementation_versions slug
    data.rubies[slug].versions.keys.sort_by { |v| Gem::Version.new(v) }.reverse
  end

  def get_version slug, version
    data.rubies[slug].versions[version]
  end

  def latest_stable_version slug
    data.rubies[slug].stable[:stable].max
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings
configure :development do
  set :debug_assets, true
end

# rubies#index
proxy '/all', '/implementations/index.html', layout: 'layout'

ready do
  def latest_ruby_version
    data.rubies.ruby.stable[:stable].max
  end

  def latest_stable_version slug
    data.rubies[slug].stable[:stable].max
  end

  def implementation_versions slug
    data.rubies[slug].versions.keys.sort_by { |v| Gem::Version.new(v) }.reverse
  end

  redirect '/latest', to: "/ruby/#{latest_ruby_version}"

  def ruby_slugs
    path = [__dir__, 'data', 'status.yml'].join '/'
    rubies_by_status = YAML.safe_load_file path
    rubies_by_status.values.flatten
  end

  ruby_slugs.each do |slug|
    proxy "/#{slug}", '/implementations/show.html', locals: { slug: slug }, ignore: true, layout: 'layout'

    implementation_versions(slug).each do |version|
      proxy "/#{slug}/#{version}",
            '/implementations/versions/show.html',
            locals: { slug: slug, version: version },
            ignore: true,
            layout: 'layout'
    end

    proxy "/#{slug}/stable", "/#{slug}/#{latest_stable_version(slug)}.html", layout: 'layout', ignore: true
  end
end
