# require 'simplecov'
# SimpleCov.start

$LOAD_PATH.unshift File.dirname(__FILE__), '../lib'

require 'bundler'
Bundler.require(:default)
require 'minitest/spec'
require 'minitest/autorun'
require 'study'

module Study
  class << self
    # Dirty little helper to reset configuration state
    def reset_config!
      @configured_graphs = nil
      @app_name = nil
      @scope = nil
      @redis = nil
    end
  end
end