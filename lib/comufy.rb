require 'yaml'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'
require 'logger'

module Comufy

  # TODO: Documentation
  def self.connect params = {}
    Connector.new(params)
  end

  autoload :Version,    "comufy/version"
  autoload :Config,     "comufy/config"
  autoload :Connector,  "comufy/connector"

  # Based on Rails implementation, ensures all strings are converted
  # into symbols.
  def symbolize_keys hash
    hash.each_with_object( {} ) { |(k,v), h| h[k.to_sym] = v }
  end
end
