module Comufy
  class Config
    attr_reader :username, :password, :base_api_url, :logger
    attr_accessor :access_token, :expiry_time

    # Sets the environment settings for Comufy to send and receive messages.
    # @param [Hash] params
    def initialize params = {}
      if params.has_key?(:debug)
        @base_api_url = 'https://staging.comufy.com/xcoreweb/client?request='
      else
        @base_api_url = 'https://social.comufy.com/xcoreweb/client?request='
      end

      yaml = YAML.load_file(File.join(File.dirname(__FILE__), "yaml/config.yaml"))
      if params.has_key?(:username) and params.has_key?(:password)
        @username = params[:username]
        @password = params[:password]
        @access_token = nil
        @expiry_time = nil
      elsif params.has_key?(:no_env)
        @username = yaml.fetch('config', {}).fetch('username', nil)
        @password = yaml.fetch('config', {}).fetch('password', nil)
        @access_token = nil
        @expiry_time = nil
      else
        @username = yaml.fetch('config', {}).fetch('username', nil)
        @password = yaml.fetch('config', {}).fetch('password', nil)
        @access_token = ENV.fetch('access_token',  nil)
        @access_token = ENV.fetch('expiry_time',   nil)
      end
    end
	end
end
