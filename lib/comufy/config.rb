module Comufy
  class Config
    include Comufy

    attr_reader :username, :password, :base_api_url
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
        yaml_location = params[:yaml_location] || File.join(File.dirname(__FILE__), "yaml/config.yaml")
        yaml = YAML.load_file(yaml_location)
        yaml = symbolize_keys(yaml)
      rescue
        # TODO: should it check the ENV for the username and password?
        yaml = Hash.new()
      end

      @username = params[:username] || yaml.fetch(:config, {})['username']
      @password = params[:password] || yaml.fetch(:config, {})['password']
      @access_token = params[:no_env] ? nil : ENV.fetch('access_token',  nil)
      @expiry_time = params[:no_env] ? nil : ENV.fetch('expiry_time',   nil)

      params[:staging] ?
          @base_api_url = 'https://staging.comufy.com/xcoreweb/client?request=' :
          @base_api_url = 'https://social.comufy.com/xcoreweb/client?request='

    end
  end
end
