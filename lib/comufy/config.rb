class Comufy
  class Config

    attr_reader :user, :password, :base_api_url
    attr_accessor :access_token, :expiry_time

    # Sets the environment settings for Comufy to send and receive messages.
    # @param [Hash] opts - all are optional
    #   [String]  username - sets the username
    #   [String]  password - sets the password
    #   [String]  token    - sets the access token
    #   [String]  time     - sets the expiry time
    #   [String]  url      - sets the url
    #   [String]  yaml     - the absolute path to the yaml file to read, all previously mentioned options are valid
    def initialize opts = {}
      opts = Comufy.symbolize_keys(opts)

      begin
        yaml_location = opts.delete(:yaml)
        yaml          = YAML.load_file(yaml_location)
        yaml          = Comufy.symbolize_keys(yaml)
      rescue
        yaml = Hash.new()
      end

      @user         = yaml.delete(:user)      || opts.delete(:user)     || ENV.fetch('COMUFY_USER',         nil)
      @password     = yaml.delete(:password)  || opts.delete(:password) || ENV.fetch('COMUFY_PASSWORD',     nil)
      @access_token = yaml.delete(:token)     || opts.delete(:token)    || ENV.fetch('COMUFY_TOKEN',        nil)
      @expiry_time  = yaml.delete(:time)      || opts.delete(:time)     || ENV.fetch('COMUFY_EXPIRY_TIME',  nil)
      @base_api_url = yaml.delete(:url)       || opts.delete(:url)      || ENV.fetch('COMUFY_URL',          'http://www.sociableapi.com/xcoreweb/client')
    end
  end
end
