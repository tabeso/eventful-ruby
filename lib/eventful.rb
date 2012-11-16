require 'eventful/version'

module Eventful
  ENDPOINT = 'http://api.eventful.com/rest/'
  
  class << self
    attr_accessor :api_key
    
  end
  
end

require 'eventful/request'
require 'eventful/response'
require 'eventful/event'
