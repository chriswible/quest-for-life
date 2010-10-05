# Copyright (c) 2009 Steven Hammond, Cris Necochea, Joe Lind, Jeremy Weiskotten
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.gem 'haml'
  config.gem 'binarylogic-settingslogic', :lib => 'settingslogic', :source => 'http://gems.github.com'
  config.gem 'justinfrench-formtastic', :lib => 'formtastic', :source => 'http://gems.github.com'
  config.gem 'thoughtbot-clearance', :lib => 'clearance', :source => 'http://gems.github.com'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'ruby-openid', :lib => 'openid', :version => '2.1.8'
  config.gem 'chriseppstein-compass', :version => '0.8.10', :lib => 'compass', :source => 'http://gems.github.com'
  config.gem 'jcnetdev-better_partials', :version => '>= 1.1', :lib => 'better_partials', :source => 'http://gems.github.com'
  config.gem 'binarylogic-searchlogic', :version => '2.2.3', :lib => 'searchlogic', :source => 'http://gems.github.com'
  config.gem 'active_hash', :version => '0.8.2', :lib => 'active_hash'
  config.gem 'exceptional', :version => '2.0.7'
  
  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  config.frameworks -= [ :active_resource ]

  # config.action_controller.session = {
  #   :session_key => '_quest_for_life_session',
  #   :secret      => 'cdff9de3750737937a47b94fa3cf4c5b7e09c3c326eac24e1b20652816794aaa'
  # }
  config.action_controller.session_store = :cookie_store
  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  config.active_record.schema_format = :sql
end
