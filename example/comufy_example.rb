require 'comufy'

USERNAME = ARGV[0]
PASSWORD = ARGV[1]
APPLICATION_NAME = ARGV[2]
FACEBOOK_USER_ID = ARGV[3]

connect = Comufy.new(logger: "debug", user: 'USERNAME', password: 'PASSWORD')
tag = Array[{name: :other_details, type: Comufy::STRING_TYPE}]
puts connect.register_tags(APPLICATION_NAME, tag)

# register a tag!
#tag = Array[Hash[:name, :other_details, :type, Comufy::Connector::STRING_TYPE]]
#puts connect.register_tags(APPLICATION_NAME, tag)

# lets save a new user or if the user exists, update these tag details
#tags = Hash[:other_details, 'test_details']
#puts connect.store_user(APPLICATION_NAME, FACEBOOK_USER_ID, tags)

# send a message to the user!
#description = "description for you!"
#content = "Content of the message goes here"
#message_options = Hash.new
#message_options[:private] = true
#message_options[:link] = "www.example.com"
#message_options[:name] = "test_name"
#message_options[:description] = "test_description"
#puts connect.send_facebook_message(
#    APPLICATION_NAME, description, content, %w(FACEBOOK_USER_ID), message_options: message_options
#)
