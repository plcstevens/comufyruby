module Comufy
  class Config

    attr_reader :username, :password, :base_api_url, :logger
    attr_accessor :access_token, :expiry_time

    # Sets the environment settings for Comufy to send and receive messages.
    # @param [Hash] params - all are optional
    #   [Object] staging - as long as this is a value other than false/nil it'll change the @base_api_url to 'staging'
    #   [String] username - sets the username
    #   [String] password - sets the password
    #   [Object] no_env - as long as this is a value other than false/nil it'll not use environment values
    def initialize params = {}
      @base_api_url = 'https://social.comufy.com/xcoreweb/client?request='
      @base_api_url = 'https://staging.comufy.com/xcoreweb/client?request=' if params[:staging]

      yaml = YAML.load_file(File.join(File.dirname(__FILE__), "yaml/config.yaml"))
      if params.has_key?(:username) and params.has_key?(:password)
        @username = params[:username]
        @password = params[:password]
        @access_token = nil
        @expiry_time = nil
      elsif params[:no_env]
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
