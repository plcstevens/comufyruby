module Comufy
  class Connector
    include Comufy

    # There are a number of options you can pass to change default settings.
    #
    # With regards to the server to connect to, if you pass <tt>staging: true</tt> it'll use the Comufy
    # staging server, otherwise it'll default to using the social server.
    #
    # Concerning authentication, there are a number of ways to connect to the Comufy servers. You can
    # pass in a username and password in the parameters, provide the location of a YAML file where these are
    # specified or read in the <tt>access_token</tt> from your environment path. Please note that you can stop
    # the connector from reading your environment path by setting <tt>no_env</tt> to true. When doing this please
    # ensure your username and password are correct, otherwise you'll not be able to connect to the Comufy servers.
    #
    # The YAML file provided should appear as:
    #   config:
    #     username: username
    #     password: password
    #
    # = Example
    #
    #   # use the staging server
    #   Comufy::Connector.new(staging: true)
    #
    #   # do not use the environment path
    #   Comufy::Connector.new(no_env: true)
    #
    #   # set the username and password yourself
    #   Comufy::Connector.new(username: YOUR_USERNAME, password: YOUR_PASSWORD)
    #
    #   # Or you can read in from a YAML file!
    #
    #   # tell the connector where to find the yaml file to read
    #   Comufy::Connector.new(yaml: PATH_TO_YAML_FILE)
    def initialize params = {}
      params = symbolize_keys(params)
      @config = Config.new(params)
      @logger = Logger.new(STDOUT)
      @logger.level = case params[:logger]
                        when "info" then
                          Logger::INFO
                        when "warn" then
                          Logger::WARN
                        when "debug" then
                          Logger::DEBUG
                        else
                          Logger::DEBUG
    end
      # sanitize all output
      original_formatter = Logger::Formatter.new
      @logger.formatter = proc { |severity, datetime, progname, msg|
        original_formatter.call(severity, datetime, progname, msg.dump)
      }
    end

    # This API call allows you to register a Facebook user of your application into Comufy’s social CRM.
    # If this user was already registered with Comufy, their information will be updated.
    #
    # * (String) +app_name+ - The application you'll be adding the user to.
    # * (String) +uid+ - The Facebook ID of the user you'll be adding.
    # * (Hash) +tags+ - The tags you'll setting for this user.
    #   * (String) +tag_name+ - Must correspond to one of the tag names of the application.
    #   * (String) +value+ - Must be the correct value type for that tag.
    #
    # = Example
    #
    #   connect.store_users(YOUR_APPLICATION_NAME, USER_FACEBOOK_ID, { 'dob' => '1978-10-01 19:50:48' })
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
      if message
        case message['cd']
          when 388 then
            return true
          when 475 then
            @logger.debug(progname = 'Comufy::Connect.store_user') {
              "475 - Invalid parameter provided. - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.store_user') {
              '475 - Invalid parameter provided.'
            }
          when 617 then
            @logger.debug(progname = 'Comufy::Connect.store_user') {
              "617 - Some of the tags passed are not registered. - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.store_user') {
              '617 - Some of the tags passed are not registered.'
            }
          when 632 then
            @logger.debug(progname = 'Comufy::Connect.store_user') {
              "632 - _ERROR_FACEBOOK_PAGE_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.store_user') {
              '632 - _ERROR_FACEBOOK_PAGE_NOT_FOUND'
            }
          else
            @logger.debug(progname = 'Comufy::Connect.store_user') {
              "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.store_user') {
              "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
            }
        end
      else
        @logger.debug(progname = 'Comufy::Connect.store_user') {
          "Authentication failed - data = #{data}."
        }
        @logger.warn(progname = 'Comufy::Connect.store_user') {
          "Authentication failed when sending #{data}. Please get in touch with Comufy if you cannot resolve the problem."
        }
      end
      false
    end

    # TODO: IMPLEMENT METHOD
    def remove_user app_name, uid # :nodoc:
      return false unless get_access_token
      @logger.debug(progname = 'Comufy::Connect.remove_user') {
        'METHOD_NOT_IMPLEMENTED'
      }
      @logger.warn(progname = 'Comufy::Connect.remove_user') {
          'METHOD_NOT_IMPLEMENTED'
      }
      app_name
      uid
      false
    end

    #
    # This API call allows you to register multiple Facebook users of your application into Comufy’s social CRM.
    # If these users were already registered into Comufy, their information will be updated.
    #
    # * (String) +app_name+ - The application you wish to store these users with.
    # * (Hash) +uid_tags+ - The users you wish to add with their corresponding tag data.
    #   * (String) +uid+ - The key is the Facebook ID of the user.
    #   * (Hash) +tags+ - The value is the tags of data to apply for that user.
    #
    # = Example
    #
    #   connect.store_users(
    #     YOUR_APPLICATION_NAME,
    #     { USER_ID => { 'dob' => '1978-10-01 19:50:48' }, OTHER_USER_ID => { 'dob' => '1978-10-01 19:50:48'}}
    #   )
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
      if message
        case message['cd']
          when 388 then
            return true
          when 475 then
            @logger.debug(progname = 'Comufy::Connect.store_users') {
              "603 - Invalid parameter provided. - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.store_users') {
              '475 - Invalid parameter provided.'
            }
          when 617 then
            @logger.debug(progname = 'Comufy::Connect.store_users') {
              "617 - Some of the tags passed are not registered. - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.store_users') {
              '617 - Some of the tags passed are not registered.'
            }
          when 632 then
            @logger.debug(progname = 'Comufy::Connect.store_users') {
              "632 - _ERROR_FACEBOOK_PAGE_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.store_users') {
              '632 - _ERROR_FACEBOOK_PAGE_NOT_FOUND'
            }
          else
            @logger.debug(progname = 'Comufy::Connect.store_users') {
              "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.store_users') {
              "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
            }
        end
      else
        @logger.debug(progname = 'Comufy::Connect.store_users') {
          "Authentication failed - data = #{data}."
        }
        @logger.warn(progname = 'Comufy::Connect.store_users') {
          "Authentication failed when sending #{data}. Please get in touch with Comufy if you cannot resolve the problem."
        }
      end
      false
    end

    # Registering a Facebook application tag allows you to store data-fields about each one of your customers.
    #
    # * (String) +app_name+ - The application you wish to register the tags with.
    # * (Array) +tags+ - The tags you wish to register, each of which must be a (Hash) containing two keys.
    #   * (String) +name+ - The name for the tag.
    #   * (String) +type+ - Must be one of the following: STRING, DATE, GENDER, INT, FLOAT.
    #
    # = Example
    #   connect.register_tags(
    #     YOUR_APPLICATION_NAME,
    #     [{
    #       'name' => 'dob',
    #       'type' => 'DATE'
    #     },
    #     {
    #       'name' => 'height',
    #       'type' => 'FLOAT'
    #     }]
    #   )
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
      tags.each do |tag|
        tag.each do |key, value|
          unless %w(name type).include?(key)
            @logger.warn(progname = 'Comufy::Connect.register_tags') {
              'You must have only two keys called "name" and "type".'
            }
            return false
          end
          if key == "type" and not %w(STRING DATE GENDER INT FLOAT).include?(value)
            @logger.warn(progname = 'Comufy::Connect.register_tags') {
              'Your type must be one of these values: STRING, DATE, GENDER, INT, FLOAT.'
            }
            return false
          end
        end
      end

      data = {
          #token:           @config.access_token,
          tags:            tags,
          cd:              86,
          applicationName: app_name
      }

      message = call_api(data)
      if message
        case message['cd']
          when 386 then
            return true
          when 475 then
            @logger.debug(progname = 'Comufy::Connect.register_tags') {
              "475 - Invalid parameters provided - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.register_tags') {
              '475 - Invalid parameters provided'
            }
          when 603 then
            @logger.debug(progname = 'Comufy::Connect.register_tags') {
              "603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.register_tags') {
              '603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND'
            }
          when 607 then
            @logger.debug(progname = 'Comufy::Connect.register_tags') {
              "607 - _ERROR_UNAUTHORISED_ACTION - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.register_tags') {
              '607 - _ERROR_UNAUTHORISED_ACTION'
            }
          when 618 then
            @logger.debug(progname = 'Comufy::Connect.register_tags') {
              "618 - _ERROR_DOMAIN_APPLICATION_TAG_ALREADY_REGISTERED - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.register_tags') {
              '618 - _ERROR_DOMAIN_APPLICATION_TAG_ALREADY_REGISTERED'
            }
          else
            @logger.debug(progname = 'Comufy::Connect.register_tags') {
              "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.register_tags') {
              "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
            }
        end
      else
        @logger.debug(progname = 'Comufy::Connect.register_tags') {
          "Authentication failed - data = #{data}."
        }
        @logger.warn(progname = 'Comufy::Connect.register_tags') {
          "Authentication failed when sending #{data}. Please get in touch with Comufy if you cannot resolve the problem."
        }
      end
      false
    end

    #
    # This API call will unregister an existing application tag. All data associated with the tag will be lost.
    #
    # * (String) +app_name+ - The application on which to remove the tag.
    # * (String) +tag+ - The tag to remove from the user.
    #
    # = Example
    #   connect.unregister_tag(YOUR_APPLICATION_NAME, 'dob')
    def unregister_tag app_name, tag
      return false unless get_access_token
      if app_name.nil? or app_name.empty?
        @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
          'First parameter must be set to your application name.'
        }
        return false
      end
      if tag.nil? or tag.empty?
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
      if message
        case message['cd']
          when 385 then
            return true
          when 475 then
            @logger.debug(progname = 'Comufy::Connect.unregister_tag') {
              "475 - Invalid parameters provided - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
              '475 - Invalid parameters provided'
            }
          when 603 then
            @logger.debug(progname = 'Comufy::Connect.unregister_tag') {
              "603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
              '603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND'
            }
          when 607 then
            @logger.debug(progname = 'Comufy::Connect.unregister_tag') {
              "607 - _ERROR_UNAUTHORISED_ACTION - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
              '607 - _ERROR_UNAUTHORISED_ACTION'
            }
          when 617 then
            @logger.debug(progname = 'Comufy::Connect.unregister_tag') {
              "617 - _ERROR_DOMAIN_APPLICATION_TAG_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
              '617 - _ERROR_DOMAIN_APPLICATION_TAG_NOT_FOUND'
            }
          else
            @logger.debug(progname = 'Comufy::Connect.unregister_tag') {
              "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
              "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
            }
        end
      else
        @logger.debug(progname = 'Comufy::Connect.unregister_tag') {
          "Authentication failed - data = #{data}."
        }
        @logger.warn(progname = 'Comufy::Connect.unregister_tag') {
          "Authentication failed when sending #{data}. Please get in touch with Comufy if you cannot resolve the problem."
        }
      end
      false
    end

    # Sends a message with the description and content to the facebook id or id's specified, allowing multiple
    # options to be set concerning the privacy, and content of the message.
    #
    # * (String) +app_name+ - The application through the message is sent.
    # * (String) +description+ - Description of the message. Useful to aggregate data in the Comufy dashboard. e.g. "Welcome".
    # * (String) +content+ - The text message content.
    # * (Array) +uids+ - The Facebook IDs of the users to send the message to.
    # * (Hash) +opts+ - Optional settings you can pass.
    #   * (Integer) +delivery_time+ - The scheduled time of delivery defaults to now. (Unix millisecond timestamps)
    #   * (Boolean) +shorten_urls+ - UNTRACKED if false, otherwise defaults to Comufy TRACKED
    #   * (String) +filter+ - filtering condition in CFL.
    #   * (Hash) +message_options+ - options to set for the message especially.
    #     * (String) +name+ - facebook message name.
    #     * (String) +link+ - Facebook message link.
    #     * (String) +caption+ - facebook message caption.
    #     * (String) +description+ - description of the message.
    #     * (String) +picture+ - URL of the image that should appear on the image section of the message.
    #     * (Boolean) +privacy+ -  whether the message should be sent private or not.
    def send_facebook_message app_name, description, content, uids, opts = {}
      return false unless get_access_token
      if app_name.nil? or app_name.empty? or not content.is_a?(String)
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          'First parameter must be set to your application name, as a String.'
        }
        return false
      end
      if description.nil? or description.empty? or not content.is_a?(String)
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          'Second parameter must be set to your facebook description, as a String.'
        }
        return false
      end
      if content.nil? or content.empty? or not content.is_a?(String)
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          'Third parameter must be sent to your facebook content, as a String.'
        }
        return false
      end
      if uids.nil? or uids.empty? or not uids.is_a?(Array)
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          'Fourth parameter must be sent to your facebook uids, as an Array of Strings.'
        }
        return false
      end

      # symbolize the keys!
      opts = symbolize_keys(opts)

      # optional checks
      if opts.has_key?(:filter) and not opts[:filter].is_a?(String)
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          'When including "filter", it must be a String.'
        }
        return false
      end
      if opts.has_key?(:delivery_time) and not opts[:delivery_time].is_a?(Integer)
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          'When including "delivery_time", it must be an Integer, of unix time in milliseconds.'
        }
        return false
      end
      if opts.has_key?(:shorten_urls) and not %w[ true, false ].include?(opts[:shorten_urls])
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          'When including "shorten_urls", it must be an boolean value.'
        }
        return false
      end
      if opts.has_key?(:message_options) and not opts[:message_options].is_a?(Hash)
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          'When including "options", it must be a Hash.'
        }
        return false
      end

      facebook_ids = "FACEBOOK_ID=\"#{uids.join('\" OR FACEBOOK_ID=\"')}\""

      filter = opts[:filter] || String.new()
      delivery_time = opts[:delivery_time]
      shorten_urls =  opts.has_key?(:shorten_urls) ? opts[:shorten_urls] : true
      options = opts[:message_options]

      data = {
          cd:              83,
          applicationName: app_name,
          description:     description,
          content:         content,
          filter:          "#{facebook_ids} #{filter}"
      }

      data[:deliveryTime] = delivery_time if delivery_time
      data[:trackingMode] = "UNTRACKED" unless shorten_urls

      if options
        data[:fbMessagePrivacyMode] = options[:private] ? "PRIVATE" : "PUBLIC" if options.has_key?(:private)
        data[:fbMessageCaption]     = options[:caption]                        if options.has_key?(:caption)
        data[:fbMessageLink]        = options[:link]                           if options.has_key?(:link)
        data[:fbMessageName]        = options[:name]                           if options.has_key?(:name)
        data[:fbMessageDescription] = options[:description]                    if options.has_key?(:description)
        data[:fbMessagePictureUrl]  = options[:picture]                        if options.has_key?(:picture)
        data[:facebookTargetingMode] = "NOTIFICATION"
      end

      message = call_api(data)
      if message
        case message['cd']
          when 383 then
            return true
          when 416 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "416 - _ERROR_MSG_SEND_FAILED - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '416 - _ERROR_MSG_SEND_FAILED'
            }
          when 475 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "475 - Invalid parameters provided - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '475 - Invalid parameters provided'
            }
          when 551 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "551 _ERROR_TAG_VALUE_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '551 - _ERROR_TAG_VALUE_NOT_FOUND'
            }
          when 603 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND'
            }
          when 607 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "607 - _ERROR_UNAUTHORISED_ACTION - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '607 - _ERROR_UNAUTHORISED_ACTION'
            }
          when 617 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "617 - _ERROR_DOMAIN_APPLICATION_TAG_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '617 - _ERROR_DOMAIN_APPLICATION_TAG_NOT_FOUND'
            }
          when 648 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "648 - _ERROR_FACEBOOK_APPLICATION_USER_NOT_FOUND - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '648 - _ERROR_FACEBOOK_APPLICATION_USER_NOT_FOUND'
            }
          when 673 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "673 - Invalid time exception - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '673 - Invalid time exception'
            }
          when 679 then
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "679 - _ERROR_MALFORMED_TARGETING_EXPRESSION - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              '679 - _ERROR_MALFORMED_TARGETING_EXPRESSION'
            }
          else
            @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
              "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
            }
            @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
              "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
            }
        end
      else
        @logger.debug(progname = 'Comufy::Connect.send_facebook_message') {
          "Authentication failed - data = #{data}."
        }
        @logger.warn(progname = 'Comufy::Connect.send_facebook_message') {
          "Authentication failed when sending #{data}. Please get in touch with Comufy if you cannot resolve the problem."
        }
      end
      false
    end

    private

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
              @logger.debug(progname = 'Comufy::Connect.authenticate') {
                "475 - Invalid parameters provided. - data = #{data} - message = #{message}."
              }
              @logger.warn(progname = 'Comufy::Connect.authenticate') {
                '475 - Invalid parameters provided.'
              }
            when 504 then
              @logger.debug(progname = 'Comufy::Connect.authenticate') {
                "504 - FIX. - data = #{data} - message = #{message}."
              }
              @logger.warn(progname = 'Comufy::Connect.authenticate') {
                '504 - FIX.'
              }
            when 651 then
              @logger.debug(progname = 'Comufy::Connect.authenticate') {
                "651 - Invalid username exception. Check that you are login in using the format user@domain. - data = #{data} - message = #{message}."
              }
              @logger.warn(progname = 'Comufy::Connect.authenticate') {
                '651 - Invalid username exception. Check that you are login in using the format user@domain.'
              }
            when 652 then
              @logger.debug(progname = 'Comufy::Connect.authenticate') {
                "652 - Invalid password exception. - data = #{data} - message = #{message}."
              }
              @logger.warn(progname = 'Comufy::Connect.authenticate') {
                '652 - Invalid password exception.'
              }
            when 682 then
              @logger.debug(progname = 'Comufy::Connect.authenticate') {
                "682 - This user is blocked. - data = #{data} - message = #{message}."
              }
              @logger.warn(progname = 'Comufy::Connect.authenticate') {
                '682 - This user is blocked.'
              }
            else
              @logger.debug(progname = 'Comufy::Connect.authenticate') {
                "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
              }
              @logger.warn(progname = 'Comufy::Connect.authenticate') {
                "An error occurred when sending #{data}. Comufy returned #{message}. Please get in touch with Comufy if you cannot resolve the problem."
              }
          end
          # an issue occurred, reset the access token and expiry time.
          @config.access_token = nil
          @config.expiry_time = nil
          false
        end

        # Calls the Comufy backed with the provided set of parameters, which the system will expect
        #
        # @param [Array] params Data to pass to the server
        # @param [Boolean] add_access_token Whether or not the access token should be provided, default is True
        # @return [Hash/Array] The message from the server, or nil if it failed to contact the server
        def call_api data, add_access_token=true
          if add_access_token
            return nil if not get_access_token
            data[:token] = @config.access_token
          end
          json = CGI::escape(data.to_json)
          url = URI.parse("#{@config::base_api_url}#{json}")
          http = Net::HTTP.new(url.host, 443)
          req = Net::HTTP::Get.new(url.to_s)
          http.use_ssl = true
          response = http.request(req)
          JSON.parse(response.read_body) if response.message == 'OK'
        end

        # Checks that the token is not expired, and authenticates if it is
        #
        # @return [Boolean] False when unable to authenticate, true otherwise
        def get_access_token
          return authenticate if has_token_expired
          true
        end

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

  end
end
