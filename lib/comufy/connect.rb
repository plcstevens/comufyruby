module Comufy
  class Connect

    def initialize params = {}
      @config = Config.new(params)
      if params.has_key?('debug')
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
      else
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::WARN
      end
      # sanitize all output
      original_formatter = Logger::Formatter.new
      @logger.formatter = proc { |severity, datetime, progname, msg|
        original_formatter.call(severity, datetime, progname, msg.dump)
      }
    end

    def store_user app_name, uid, tags
      return false unless get_access_token
      if app_name.nil? or app_name.empty?
        @logger.warn("Comufy::Connect.store_user the first parameter must be set to your application name")
        return false
      end
      if uid.nil? or uid.empty?
        @logger.warn("Comufy::Connect.store_user the second parameter must be a valid Facebook user ID")
        return false
      end
      if tags.nil? or not tags.is_a?(Array)
        @logger.warn("Comufy::Connect.store_user the third parameter must be an associative array")
        return false
      end

      data = {
          token:           @config.access_token,
          cd:              '88',
          applicationName: app_name,
          accounts:        [{
                                account: { fbId: uid },
                                tags:    tags
                            }]
      }

      message = call_api(data)
      case message['cd']
        when 338 then
          return true
        when 617 then
          @logger.warn("Comufy::Connect.store_user error: Some of the tags passed are not registered.")
        when 475 then
          @logger.warn("Comufy::Connect.store_user error: Invalid parameter provided")
        else
          # TODO : handle debug message output when this occurs.
          @logger.warn("Comufy::Connect.store_user An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem.")
      end
      false
    end

    def remove_user uid
      return false unless get_access_token
      if uid.nil? or uid.empty?
        @logger.warn("Comufy::Connect.remove_user the first parameter must be a valid Facebook user ID")
        return false
      end

      data = {
          token:    @config.access_token,
          cd:       176,
          accounts: [{ account: { fbId: uid } }]
      }

      message = call_api(data)
      case message['cd']
        when 388 then
          return true
        when 475 then
          @logger.warn("Comufy::Connect.remove_user Invalid parameters provided")
        else
          # TODO : handle debug message output when this occurs.
          @logger.warn("Comufy::Connect.remove_user An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem.")
      end
      false
    end

    def register_tags app_name, tags
      return false unless get_access_token
      if app_name.nil? or app_name.empty?
        @logger.warn("Comufy::Connect.register_tags the first parameter must be set to your application name")
        return false
      end
      if tags.nil? or not tags.is_a?(Array)
        @logger.warn("Comufy::Connect.register_tags the third parameter must be an associative array")
        return false
      end

      data = {
          token:           @config.access_token,
          cd:              86,
          tags:            tags,
          applicationName: app_name
      }

      message = call_api(data)
      case message['cd']
        when 386 then
          return true
        when 618 then
          # TODO: respond
        when 475 then
          # TODO: respond
        else
          # TODO: respond
      end
    end

    # Use the configured username and password to get and set the access token and expiry time, if it fails,
    # it means the user likely has their username/password wrong.
    #
    # @return [Boolean] True when successful, false in all other cases.
    def authenticate
      data = {
          cd:       131,
          user:     @config.username,
          password: @config.password
      }

      message = call_api(data, false)
      case message['cd']
        when 235 then
          @config.access_token = message['tokenInfo']['token']
          @config.expiry_time = message['tokenInfo']['expiryTime']
          return true
        when 651 then
          @logger.warn("Comufy::Connect.authenticate Invalid username exception. Check that you are login in using the format user@domain.")
        when 652 then
          @logger.warn("Comufy::Connect.authenticate Invalid password exception.")
        when 682 then
          @logger.warn("Comufy::Connect.authenticate This user is blocked.")
        else
          # TODO : handle debug message output when this occurs.
          @logger.warn("Comufy::Connect.authenticate An error occurred when sending #{data.inspect}. Comufy returned #{message.inspect}. Please get in touch with Comufy if you cannot resolve the problem.")
      end
      # an issue occurred, reset the access token and expiry time.
      @config.access_token = nil
      @config.expiry_time = nil
      false
    end
    private :authenticate

    # Calls the Comufy backed with the provided set of parameters, which the system will expect
    #
    # @param [Array] params Data to pass to the server
    # @param [Boolean] add_access_token Whether or not the access token should be provided, default is True
    # @return [Hash/Array] The message from the server, or nil if it failed to contact the server
    def call_api data, add_access_token=true
      if add_access_token
        return nil if not get_access_token
        data['token'] = @config.access_token
      end
      json = CGI::escape(data.to_json)
      url = URI.parse("#{@config::base_api_url}#{json}")
      http = Net::HTTP.new(url.host, 443)
      req = Net::HTTP::Get.new(url.to_s)
      http.use_ssl = true
      response = http.request(req)
      JSON.parse(response.read_body) if response.message == 'OK'
    end
    private :call_api

    # Checks that the token is not expired, and authenticates if it is
    #
    # @return [Boolean] False when unable to authenticate, true otherwise
    def get_access_token
      return authenticate if has_token_expired
      true
    end
    private :get_access_token

    # If the expiry time is set, and hasn't been reached, return false, otherwise
    # reset the access_token and expiry time,
    #
    # @return [Boolean] True if expired, otherwise false
    def has_token_expired
      return false if @config.expiry_time != nil and Time.at(@config.expiry_time) > Time.now
      @config.expiry_time = nil
      @config.access_token = nil
      true
    end
    private :has_token_expired

  end
end
