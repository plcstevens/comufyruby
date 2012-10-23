module Comufy
  class Connect

    # Initialises the connection, setting up the configuration settings.
    #
    # SERVER
    # Pass :debug => true to run in debug mode, using the staging server
    # If you do not pass :debug => true it'll use the social server.
    #
    # USER INFORMATION
    # Pass :username => 'username' AND :password => 'password' to use that username and password.
    # Otherwise it'll read the username/password from the yaml/config.yaml file you should
    # supply in the format below.
    # config:
    #   username: username
    #   password: password
    #
    # If you pass :no_env => true, it'll set the access_token and expiry_time to nil, otherwise it'll
    # attempt to find them in your environment path. Note if you pass this, ensure you have your username
    # and password correctly set as these are required to get the access_token.
    #
    # @param [Hash] params
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

    #
    # This API call allows you to register a Facebook user of your application into Comufy’s social CRM.
    # If this user was already registered into Comufy, their information will be updated.
    #
    # Example:
    # connect.store_users('Facebook Application Name', '1010101', { 'dob' => '1978-10-01 19:50:48' })
    #
    def store_user app_name, uid, tags
      return false unless get_access_token
      if app_name.nil? or app_name.empty?
        @logger.warn(progname = 'Comufy::Connect.store_user') {
          'First parameter must be set to your application name.'
        }
        return false
      end
      if uid.nil? or uid.empty?
        @logger.warn(progname = 'Comufy::Connect.store_user') {
          'Second parameter must be a valid Facebook user ID.'
        }
        return false
      end
      if tags.nil? or not tags.is_a?(Hash)
        @logger.warn(progname = 'Comufy::Connect.store_user') {
          'Third parameter must be a hash of tag information for this uid.'
        }
        return false
      end

      data = {
          #token:           @config.access_token,
          cd:              '88',
          applicationName: app_name,
          accounts:        [{
                                account: { fbId: uid },
                                tags:    tags
                            }]
      }

      message = call_api(data)
      case message['cd']
        when 388 then
          return true
        when 475 then
          @logger.warn(progname = 'Comufy::Connect.store_user') {
            '475 - Invalid parameter provided.'
          }
        when 617 then
          @logger.warn(progname = 'Comufy::Connect.store_user') {
            '617 - Some of the tags passed are not registered.'
          }
        when 632 then
          @logger.warn(progname = 'Comufy::Connect.store_user') {
            '632 - _ERROR_FACEBOOK_PAGE_NOT_FOUND'
          }
        else
          # TODO : handle debug message output when this occurs.
          @logger.warn(progname = 'Comufy::Connect.store_user') {
            "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
          }
      end
      false
    end

    #
    # This API call allows you to register a Facebook user of your application into Comufy’s social CRM.
    # If this user was already registered into Comufy, their information will be updated.
    #
    # Example:
    # connect.store_users(
    #   'Facebook Application Name',
    #   { '1010101' => { 'dob' => '1978-10-01 19:50:48' }, '2020202' => { 'dob' => '1978-10-01 19:50:48'}}
    # )
    #
    def store_users app_name, uid_tags
      return false unless get_access_token
      if app_name.nil? or app_name.empty?
        @logger.warn(progname = 'Comufy::Connect.store_users') {
          'First parameter must be set to your application name.'
        }
        return false
      end
      if uid_tags.nil? or not uid_tags.is_a?(Hash)
        @logger.warn(progname = 'Comufy::Connect.store_users') {
          'Second parameter must be a hash where a key is a Facebook user ID and its value a hash of tags.'
        }
        return false
      end

      data = {
          #token:           @config.access_token,
          cd:              '88',
          applicationName: app_name,
          accounts:        uid_tags.map { |uid, tags| Hash[:account, { fbId: uid }, :tags, tags] }
      }

      message = call_api(data)
      case message['cd']
        when 388 then
          return true
        when 475 then
          @logger.warn(progname = 'Comufy::Connect.store_users') {
            '475 - Invalid parameter provided.'
          }
        when 617 then
          @logger.warn(progname = 'Comufy::Connect.store_users') {
            '617 - Some of the tags passed are not registered.'
          }
        when 632 then
          @logger.warn(progname = 'Comufy::Connect.store_users') {
            '632 - _ERROR_FACEBOOK_PAGE_NOT_FOUND'
          }
        else
          # TODO : handle debug message output when this occurs.
          @logger.warn(progname = 'Comufy::Connect.store_users') {
            "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
          }
      end
      false
    end

    # Registering a Facebook application tag allows you to store data-fields about each one of your customers.
    #
    # Example:
    # connect.register_tags(
    #   'Facebook Application Name',
    #   [{
    #     'name' => 'dob',
    #     'type' => 'DATE'
    #   },
    #   {
    #     'name' => 'height',
    #     'type' => 'FLOAT'
    #   }]
    # )
    #
    def register_tags app_name, tags
      return false unless get_access_token
      if app_name.nil? or app_name.empty?
        @logger.warn(progname = 'Comufy::Connect.register_tags') {
          'First parameter must be set to your application name.'
        }
        return false
      end
      if tags.nil? or not tags.is_a?(Array)
        @logger.warn(progname = 'Comufy::Connect.register_tags') {
          'Second parameter must be an array containing hashes.'
        }
        return false
      end

      data = {
          #token:           @config.access_token,
          tags:            tags,
          cd:              86,
          applicationName: app_name
      }

      message = call_api(data)
      case message['cd']
        when 386 then
          return true
        when 475 then
          @logger.warn(progname = 'Comufy::Connect.register_tags') {
            '475 - Invalid parameters provided'
          }
        when 603 then
          @logger.warn(progname = 'Comufy::Connect.register_tags') {
            '603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND'
          }
        when 607 then
          @logger.warn(progname = 'Comufy::Connect.register_tags') {
            '607 - _ERROR_UNAUTHORISED_ACTION'
          }
        when 618 then
          @logger.warn(progname = 'Comufy::Connect.register_tags') {
            '618 - _ERROR_DOMAIN_APPLICATION_TAG_ALREADY_REGISTERED'
          }
        else
          # TODO : handle debug message output when this occurs.
          @logger.warn(progname = 'Comufy::Connect.register_tags') {
            "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
          }
      end
      false
    end

    #
    # This API call will unregister an existing application tag. All data associated with the tag will be lost.
    #
    # Example:
    # connect.register_tags('Facebook Application Name', 'dob')
    #
    def unregister_tag app_name, tag
      if app_name.nil? or app_name.empty?
        @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
          'First parameter must be set to your application name.'
        }
        return false
      end
      if tags.nil? or tag.empty?
        @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
          'Second parameter must be set to the tag.'
        }
        return false
      end

      data = {
          #token:           @config.access_token,
          tag:             tag,
          cd:              85,
          applicationName: app_name
      }

      message = call_api(data)
      case message['cd']
        when 385 then
          return true
        when 475 then
          @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
            '475 - Invalid parameters provided'
          }
        when 603 then
          @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
            '603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND'
          }
        when 607 then
          @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
            '607 - _ERROR_UNAUTHORISED_ACTION'
          }
        when 617 then
          @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
            '617 - _ERROR_DOMAIN_APPLICATION_TAG_NOT_FOUND'
          }
        else
          # TODO : handle debug message output when this occurs.
          @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
            "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
          }
      end
      false
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
        when 475 then
          @logger.warn(progname = 'Comufy::Connect.authenticate') {
            '475 - Invalid parameters provided'
          }
        when 651 then
          @logger.warn(progname = 'Comufy::Connect.authenticate') {
            '651 - Invalid username exception. Check that you are login in using the format user@domain.'
          }
        when 652 then
          @logger.warn(progname = 'Comufy::Connect.authenticate') {
            '652 - Invalid password exception.'
          }
        when 682 then
          @logger.warn(progname = 'Comufy::Connect.authenticate') {
            '682 - This user is blocked.'
          }
        else
          # TODO : handle debug message output when this occurs.
          @logger.warn(progname = 'Comufy::Connect.authenticate') {
            "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
          }
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
