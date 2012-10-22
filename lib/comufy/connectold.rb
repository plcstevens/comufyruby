module Comufy
#  class Connect
#
#    #
#    #
#    #
#    def initialize *params
#      @config = Config.new(params)
#    end
#
#    #
#    #
#    #
#    # @param [String] application_name
#    # @param [Array] user_details
#    # @param [Boolean] add_new_tags
#    # @return [Boolean]
#    def add_user application_name, user_details, add_new_tags=False
#      return False unless get_access_token
#      current_tags = get_tags(application_name)
#      user_details[:tags].keys().each do |key|
#        unless current_tags.include?(key)
#          #TODO: Add code to create a new tag for the application entry
#          if add_new_tags
#            puts "Need to implement this bit"
#          else
#            puts 'removing user '
#            user_details[:tags].delete(key)
#          end
#        end
#      end
#
#      data = {
#          cd:              88,
#          applicationName: application_name,
#          accounts:        [user_details]
#      }
#      success, message = send_api_call( data )
#
#      message[:cd] == 388 if success
#    end
#
#    #
#    #
#    #
#    # @param [String] application_name
#    # @param [Array] users_details
#    # @return [Array]
#    def add_users application_name, users_details
#      return [[], users_details] unless get_access_token
#      current_tags = get_application_tags(application_name)
#      sent_details = []
#      not_sent_details = []
#      while len(users_details) > 0
#        #TODO: MAGIC NUMBER: 50 is defined by Comufy's API as the maximum number of users that can be sent in a single registration/update request
#        if len(users_details) > 50
#          to_send = users_details.slice(0..50)
#          users_details = users_details(50..-1)
#        else
#          to_send = users_details
#          users_details = []
#        end
#
#        data = {
#            cd:              88,
#            applicationName: application_name,
#            accounts:        to_send
#        }
#
#        success, message = send_api_call( data )
#
#        if success
#          #TODO: MAGIC NUMBER: 388 is the OK response from Comufy's API
#          if message.get(u'cd') == 388
#            sent_details.push( to_send )
#          else
#            not_sent_details.push( to_send )
#          end
#        else
#          not_sent_details.push( to_send )
#        end
#      end
#      [sent_details, not_sent_details]
#    end
#
#    #
#    #
#    #
#    # @param [String] application_name
#    # @return [Array]
#    def get_users application_name
#      data = {
#          cd:               82,
#          since:            1314835200000,
#          fetchMode:        'STATS_ONLY',
#          filter:           '',
#          applicationName:  application_name
#      }
#      success, message = send_api_call( data )
#
#      if success
#        [True, message]
#      else
#        [False, None]
#      end
#    end
#
#    #
#    #
#    #
#    # @param [String] application_name
#    # @param [String] description
#    # @param [String] content
#    # @param [Array] fb_ids
#    # @param [String] privacy_mode
#    # @param [Boolean] notification
#    # @return [Array]
#    def send_message application_name, description, content, fb_ids, privacy_mode="PRIVATE", notification=False
#      unless %w(PRIVATE PUBLIC).include?(privacy_mode)
#        raise Exception('PrivacyMode must be on of PRIVATE or PUBLIC')
#      end
#
#      fb_ids = [fb_ids] unless fb_ids.class == Array
#      data = {
#          cd:                   83,
#          content:              content,
#          description:          description,
#          fbMessagePrivacyMode: privacy_mode,
#          applicationName:      application_name,
#          # This results in FACEBOOK_ID=123 OR FACEBOOK_ID=234 etc, no or's if only 1 element
#          filter:               'FACEBOOK_ID="%s"'%(' OR FACEBOOK_ID='.join(fb_ids))
#      }
#      data[:facebookTargetingMode] = "NOTIFICATION" if notification
#
#      success, message = send_api_call( data )
#      [success, message]
#    end
#
#
#    #
#    #
#    #
#    # @param [String] application_name
#    # @param [Array] tags
#    # @return [Array]
#    def register_facebook_tag application_name, tags
#      allowed_types = [:STRING, :DATE, :GENDER, :INT, :FLOAT]
#      tags.each do |tag|
#        puts 'Name parameter is required for tag pair' unless tag.has_key(:name)
#        puts "Incorrect type: #{tag[:type]}, must be one of #{allowed_types}" unless allowed_types.include?(tag[:type]) if tag.has_key('type')
#      end
#      data = {
#          cd:              '86',
#          tags:            tags,
#          applicationName: application_name
#      }
#
#      success, message = send_api_call(data)
#      case success
#        when 386 then
#          [True, message]
#        when 607 then
#          [False, 'Unauthorised action']
#        when 603 then
#          [False, 'Application name not found']
#        when 618 then
#          [False, 'Application tag already registered']
#        else
#          # TODO: handle case where something else comes back!
#      end
#    end
#
#    #
#    #
#    #
#    # @param [String] application_name
#    # @param [String] tag
#    # @return [Array]
#    def unregister_facebook_tag application_name, tag
#      data = {
#          cd:              '85',
#          tag:             tag,
#          applicationName: application_name
#      }
#
#      success, message = send_api_call(data)
#      [success, message]
#    end
#
#    #
#    #
#    #
#    # @param [String] application_name
#    # @return [Array] Returns the tags of an applicant
#    def get_tags application_name
#      return False unless get_access_token
#      data = { cd: 101 }
#      success, message = send_api_call( data )
#      if success
#        if message[:cd] == 219 # TODO: MAGIC NUMBER: 219 is the OK response from the Comufy API's for this particular command
#          application = message[:applications].select { |application| application[:name] == application_name }
#          if application.empty?
#            raise Exception("
#              Exception: File=connect.rb,
#              Function = get_application_tags,
#              Message = Unable to find the application in the list of registered application on Comufy
#            ")
#          else
#            return application[:tags].map { |tag| tag[:name] }
#          end
#        else
#          raise Exception("
#            Exception: File=connect.rb,
#            Function = get_application_tags,
#            Message = Comufy returned an error code, Code=#{message[:cd]}
#                          ")
#        end
#      else
#        raise Exception("
#          Exception: File=connect.rb,
#          Function = get_application_tags,
#          Message = Comufy API query was unsuccessful
#        ")
#      end
#    end
#
#    #
#    #
#    #
#    # @param [Array] data
#    # @param [Boolean] add_access_token
#    # @return [Array]
#    def send_api_call data, add_access_token=true
#      if add_access_token
#        return [false, nil] if not get_access_token
#        data[:token] = @config.access_token
#      end
#
#      json = CGI::escape(data.to_json)
#      url = URI.parse("#{@config::base_api_url}#{json}")
#      http = Net::HTTP.new(url.host, 443)
#      req = Net::HTTP::Get.new(url.to_s)
#      http.use_ssl = true
#      response = http.request(req)
#
#      if response.message == 'OK' # TODO: remove magic string
#        message = JSON.parse(response.read_body)
#        [true, message]
#      else
#        [false, nil]
#      end
#    end
#    private :send_api_call
#
#    #
#    #
#    #
#    # @return [Boolean]
#    def authenticate_app
#      data = {
#          cd:       131,
#          user:     @config.username,
#          password: @config.password
#      }
#      success, message = send_api_call(data, false)
#      if success
#        if message['cd'] == 235
#          @config.access_token = message['tokenInfo']['token']
#          @config.expiry_time = message['tokenInfo']['expiryTime']
#          true
#        else
#          @config.access_token = nil
#          @config.expiry_time = nil
#          false
#        end
#      else
#        false
#      end
#    end
#
#    #
#    #
#    #
#    # @return [Boolean]
#    def get_access_token
#      return authenticate_app if has_token_expired
#      true
#    end
#    private :get_access_token
#
#    #
#    #
#    #
#    # @return [Boolean]
#    def has_token_expired
#      return false if @config.expiry_time != nil and Time.at(@config.expiry_time) > Time.now
#      @config.expiry_time = nil
#      @config.access_token = nil
#      true
#    end
#    private :has_token_expired
#
#  end
end
