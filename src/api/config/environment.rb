# Be sure to restart your web server when you modify this file.

# Load the rails application
require_relative 'application'

path = Rails.root.join('config', 'options.yml')

begin
  ruby_maj = RUBY_VERSION.split('.')[0].to_i
  ruby_min = RUBY_VERSION.split('.')[1].to_i
  if ruby_maj > 3 || (ruby_maj == 3 && ruby_min >= 1)
    load_opts = {aliases: true}
  else
    load_opts = {}
  end
  config = YAML.load_file(path, **load_opts)
  if config.key?(Rails.env)
    CONFIG = config[Rails.env]
  else
    # FIXME: Remove with the next stable release (v2.10 or v3.0)
    puts "DEPRECATED: Please update your options.yml by running 'rake migrate_options_yml'"
    CONFIG = config
  end
rescue Exception
  puts "Error while parsing config file #{path}"
  # rubocop:disable Style/MutableConstant
  CONFIG = {}
  # rubocop:enable Style/MutableConstant
end

CONFIG['schema_location'] ||= "#{File.expand_path('public/schema')}/"
CONFIG['global_write_through'] ||= true
CONFIG['proxy_auth_mode'] ||= :off
CONFIG['frontend_ldap_mode'] ||= :off

# Initialize the rails application
OBSApi::Application.initialize!
