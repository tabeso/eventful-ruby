require 'active_support/core_ext'
require 'active_support/inflector'
require 'active_support/time_with_zone'


require 'eventful/version'
require 'eventful/exceptions'
require 'eventful/middleware'
require 'eventful/config'

module Eventful
  extend self

  def configure
    block_given? ? yield(config) : config
  end

  def config
    @config ||= Config.new
  end

  delegate(*Config.public_instance_methods(false), to: :config)
end

require 'eventful/request'
require 'eventful/response'
require 'eventful/resource'
require 'eventful/event'
require 'eventful/performer'
require 'eventful/venue'
require 'eventful/feeds'