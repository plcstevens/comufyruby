require "comufy/version"
require "comufy/config"
require "comufy/connector"

require 'yaml'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'
require 'logger'

module Comufy

  def self.connect params = {}
    # initialise the connector and keep hold of the parameters
    @params ||= params
    @connector ||= self::Connector.new(@params)

    # if you pass in different parameters, recreate the object
    if @params != params
      @params = params
      @connector = self::Connector.new(@params)
    end
    @connector
  end

  # Based on Rails implementation, ensures all strings are converted
  # into symbols.
  def symbolize_keys hash
    return hash unless hash.is_a?(Hash)
    hash.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
  end
end
