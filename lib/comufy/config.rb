module Comufy
  class Config
    include Comufy

    attr_reader :user, :password, :base_api_url
    attr_accessor :access_token, :expiry_time

    # Sets the environment settings for Comufy to send and receive messages.
    # @param [Hash] params - all are optional
    #   [Object] staging - as long as this is a value other than false/nil it'll change the @base_api_url to 'staging'
    #   [String] username - sets the username
    #   [String] password - sets the password
    #   [Object] no_env - as long as this is a value other than false/nil it'll not use environment values
    def initialize params = {}
      params = symbolize_keys(params)

      begin
        yaml_location = params[:yaml] || File.join(File.dirname(__FILE__), "yaml/config.yaml")
        yaml = YAML.load_file(yaml_location)
        yaml = symbolize_keys(yaml)
      rescue
        # TODO: should it check the ENV for the username and password?
        yaml = Hash.new()
      end

      user = params[:user]
      password = params[:password]
      no_env = params[:no_env]
      staging = params[:staging]

      if (user and not password) or (password and not user)
        raise "You must supply both a username and password."
      end

      @user = user || yaml.fetch(:config, {})['user']
      @password = password || yaml.fetch(:config, {})['password']
      @access_token = no_env ? nil : ENV.fetch('COMUFY_ACCESS_TOKEN',  nil)
      @expiry_time = no_env ? nil : ENV.fetch('COMUFY_EXPIRY_TIME',   nil)

      staging ?
          @base_api_url = 'https://staging.comufy.com/xcoreweb/client' :
          @base_api_url = 'https://social.comufy.com/xcoreweb/client'

      # Override for now - we are using our comufy service!
      @base_api_url = 'http://comufy.herokuapp.com/xcoreweb/client'

    end
  end
end
