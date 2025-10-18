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

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/
helpers do
  def latest_stable_version slug
    data.rubies[slug].stable[:stable].max
  end

  def latest_ruby_version
    latest_stable_version 'ruby'
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

  def badge_color slug
    status = implementation_status(slug).to_sym
    {
      main:        :primary,
      alternative: :info,
      inactive:    :danger
    }[status]
  end

  def versions slug
    implementation = data.rubies[slug]
    return [] if implementation.blank?

    implementation.versions.keys.sort_by { |v| Gem::Version.new(v) }.reverse
  end

  def get_version slug, version
    data.rubies[slug].versions[version]
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings
configure :development do
  set :debug_assets, true
end

# Routes
# /all => implementations#index
proxy '/all', '/implementations/index.html', ignore: true, layout: 'layout'

# /latest => versions#show
proxy '/latest',
      '/implementations/versions/show.html',
      locals: { slug: 'ruby' },
      ignore: true,
      layout: 'layout'

data.implementations.each do |slug, implementation|
  # /:implementation => implementations#show
  # /ruby
  # /jruby
  # /truffleruby
  # /rubinius
  # ...
  proxy slug,
        '/implementations/show.html',
        locals: { slug: slug, implementation: implementation },
        ignore: true,
        layout: 'layout'

  # /:implementation/stable => implementations/versions/show.html
  # /ruby/stable
  # /jruby/stable
  # /truffleruby/stable
  # /rubinius/stable
  # ...
  proxy "/#{slug}/stable",
        '/implementations/versions/show.html',
        locals: { slug: slug },
        ignore: true,
        layout: 'layout'
end

data.rubies.each do |slug, implementation_versions|
  # /:implementation/:version => implementations/versions/show.html
  # /ruby/3.4.7
  # /jruby/10.0.2.0
  # /truffleruby/22.1.0
  # ...
  implementation_versions.versions.each do |version_number, _deatils|
    proxy "/#{slug}/#{version_number}",
          '/implementations/versions/show.html',
          locals: { slug: slug, version_number: version_number },
          ignore: true,
          layout: 'layout'
  end
end
