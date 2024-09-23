require 'yaml'
require 'env'

# CONSTANTS
RUBIES = {
  'jruby'               => 'https://www.jruby.org',
  'mruby'               => 'https://mruby.org',
  'ruby'                => 'https://ruby-lang.org',
  'truffleruby'         => 'https://www.graalvm.org/ruby/',
  'truffleruby-graalvm' => 'https://www.graalvm.org/ruby',
  'rubinius'            => 'https://github.com/rubinius'
}.freeze

if ENV['POSTMODERN_RUBY_VERSIONS_REPO_PATH'].nil?
  puts <<~ERROR_MESSAGE.strip
    !!! ENV['POSTMODERN_RUBY_VERSIONS_REPO_PATH'] must be set
    !!! You can use a .env file:
    !!!     dotenv ruby ./script/seeds.rb
    !!! Or inline with './script/seed' command:
    !!!     POSTMODERN_RUBY_VERSIONS_REPO_PATH=/path/to/repo ./script/seed
  ERROR_MESSAGE
  puts
  exit 1
end
POSTMODERN_RUBY_VERSIONS_REPO_PATH = ENV['POSTMODERN_RUBY_VERSIONS_REPO_PATH'].freeze

POSTMODERN_RUBY_FILES = {
  checksums: {
    md5:    'checksums.md5',
    sha1:   'checksums.sha1',
    sha256: 'checksums.sha256',
    sha512: 'checksums.sha512'
  },
  stable:    'stable.txt',
  versions:  'versions.txt'
}.freeze

# TEMP: what’s a better name?
UNWANTED_FILE_FRAGMENTS = %w[
  graalvm-ce- graalvm-jdk- truffleruby-jvm- darwin- java11- java8-
  aarch64- -aarch64
  amd64- -amd64
  linux- _linux -linux
  bin- _bin -bin
  src- dist- pkg/
  _x64 -x64
  _macos -macos
  .bz2 .gz .tar .zip .xz
].freeze

# Helper methods
def postmodern_ruby_file_path ruby, name
  file_name =
    if name.is_a? Hash
      puts caller
      puts "hash: for #{ruby}, #{name.values.first}"
      puts name
      puts

      POSTMODERN_RUBY_FILES[:checksums][name.values.first]
    else
      puts "in the else: for #{ruby}, #{name}"
      POSTMODERN_RUBY_FILES[name]
    end

  [POSTMODERN_RUBY_VERSIONS_REPO_PATH, String(ruby), file_name].join '/'
end

def data_yaml_file_path ruby, release
  yaml_path = ['data', 'rubies', ruby].join '/'
  file_name = [release, 'yml'].join '.'

  [yaml_path, file_name].join '/'
end

def write_yaml_data_file ruby, release, data
  # build file name and path for the yaml data file
  yaml_content = data.to_yaml
  file_path    = data_yaml_file_path ruby, release

  # write the yaml data file
  File.write file_path, yaml_content
end

def stable_versions ruby
  stable_versions_file_path = postmodern_ruby_file_path ruby, :stable
  File.readlines(stable_versions_file_path).map(&:chomp)
end

def checksums ruby, release
  output = {}

  POSTMODERN_RUBY_FILES[:checksums].each_key do |checksum|
    checksum_file_path = postmodern_ruby_file_path ruby, { checksum: }
    checksums_in_this_file = []

    File.readlines(checksum_file_path).each do |checksum_line|
      signature, release_file_name = checksum_line.chomp.split

      stripped_file_name = release_file_name.sub "#{ruby}-", ''
      UNWANTED_FILE_FRAGMENTS.each do |fragment|
        stripped_file_name = stripped_file_name.sub fragment, ''
      end

      if stripped_file_name == release
        checksums_in_this_file << { 'signature' => signature, 'file' => release_file_name }
      end

      output[checksum.to_s] = checksums_in_this_file
    end
  end

  output
end

# big loop
RUBIES.each do |ruby, website|
  versions_file_path = postmodern_ruby_file_path ruby, :versions

  # save the data file for stable version/s of this ruby
  write_yaml_data_file ruby, :stable, { 'name' => ruby, 'stable' => stable_versions(ruby) }

  File.readlines(versions_file_path).each do |version_line|
    release = version_line.chomp

    # build content for data file for each release of this ruby
    data = {
      'name'      => ruby,
      'version'   => release,
      'website'   => website,
      'checksums' => checksums(ruby, release)
    }

    # save the data file for each release of this ruby
    write_yaml_data_file ruby, release, data
  end
end
