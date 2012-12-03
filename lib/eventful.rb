require 'active_support/core_ext'
require 'active_support/inflector'
require 'active_support/time_with_zone'

require 'eventful/version'
require 'eventful/exceptions'

module Eventful
  API_ENDPOINT = 'http://api.eventful.com/rest/'
  FEED_ENDPOINT = 'http://static.eventful.com/images/export/'

  class << self
    attr_accessor :api_key
    attr_accessor :feed_key
  end
end

require 'eventful/request'
require 'eventful/response'
require 'eventful/resource'
require 'eventful/event'
require 'eventful/performer'
require 'eventful/venue'
require 'eventful/feeds'
