require 'comufy'

APPLICATION_NAME = ""
FACEBOOK_USER_ID = ""

connect = Comufy.connect

# register a tag!
tag = Hash[:dob, 'DATE']
connect.register_tags(APPLICATION_NAME, tag)

# lets save a new user!
tags = Hash[:dob, '1978-10-01 19:50:48']
connect.store_user(APPLICATION_NAME, FACEBOOK_USER_ID, tags)

# send a message to the user!
description = ""
content = ""
Comufy::Connector.send_facebook_message(
    APPLICATION_NAME, description, content, %w(FACEBOOK_USER_ID),
  message_options: {
    private: true, link: 'www.example.com', name: 'test', description: 'description'
  }
)
