class Comufy
  class Config

    attr_reader :user, :password, :base_api_url
    attr_accessor :access_token, :expiry_time

    # Sets the environment settings for Comufy to send and receive messages.
    # @param [Hash] opts - all are optional
    #   [String] username - sets the username
    #   [String] password - sets the password
    #   [Object] no_env - as long as this is a value other than false/nil it'll not use environment values
    def initialize opts = {}
      opts = Comufy.symbolize_keys(opts)

      user =          opts[:user]
      password =      opts[:password]
      no_env =        opts[:no_env]
      yaml_location = opts[:yaml]

      begin
        yaml = YAML.load_file(yaml_location)
        yaml = Comufy.symbolize_keys(yaml)
      rescue
        yaml = Hash.new()
      end

      @access_token = no_env ?  nil : ENV.fetch('COMUFY_TOKEN',       nil)
      @expiry_time =  no_env ?  nil : ENV.fetch('COMUFY_EXPIRY_TIME', nil)

      @base_api_url = 'http://www.sociableapi.com/xcoreweb/client'

      if (user and not password) or (password and not user)
        raise "You must supply both a username and password."
      else
        @user =     user ||     yaml.fetch(:config, {}).fetch('user',     nil)
        @password = password || yaml.fetch(:config, {}).fetch('password', nil)
      end

    end
  end
end
