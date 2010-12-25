# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Required to use local gems inside the users home directory. Maybe helpful in production server
# without root access. However, for RAILS_GEM_VERSION = '2.3.8' these should to be located before the
# "require File.join(File.dirname(__FILE__), 'boot')" line
if ENV['RAILS_ENV'] == 'production'  # don't bother on dev
  ENV['GEM_PATH'] = File.expand_path('~/.gems') + ':/usr/lib/ruby/gems/1.8'
end

Rails::Initializer.run do |config|
  # config.gem "aws-s3", :lib => "aws/s3"
  # config.gem 'grit'
  # config.gem 'will_paginate'
  # config.gem 'gravtastic', :version => '>= 2.2.0'
  # config.gem 'compass', :version => '>= 0.8.17'
  # config.gem 'progressbar', :version => '>= 0.9.0'
  config.gem 'formtastic'
  
  config.time_zone = 'UTC'
end
