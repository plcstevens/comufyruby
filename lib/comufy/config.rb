module Comufy
  class Config
    include Comufy

    attr_reader :username, :password, :base_api_url, :logger
    attr_accessor :access_token, :expiry_time

    # Sets the environment settings for Comufy to send and receive messages.
    # @param [Hash] params - all are optional
    #   [Object] staging - as long as this is a value other than false/nil it'll change the @base_api_url to 'staging'
    #   [String] username - sets the username
    #   [String] password - sets the password
    #   [Object] no_env - as long as this is a value other than false/nil it'll not use environment values
    def initialize params = {}
      params = symbolize_keys(params)
      yaml = YAML.load_file(File.join(File.dirname(__FILE__), "yaml/config.yaml"))
      yaml = symbolize_keys(yaml)

      puts params.inspect
      puts yaml.inspect

      staging = params[:staging]
      no_env =  params[:no_env]

      @username = params[:username] || yaml.fetch(:config, {})['username']
      @password = params[:password] || yaml.fetch(:config, {})['password']
      @access_token = nil
      @expiry_time = nil

      unless no_env
        @access_token = ENV.fetch('access_token',  nil)
        @expiry_time = ENV.fetch('expiry_time',   nil)
      end

      staging ?
          @base_api_url = 'https://staging.comufy.com/xcoreweb/client?request=' :
          @base_api_url = 'https://social.comufy.com/xcoreweb/client?request='

    end
  end
end
