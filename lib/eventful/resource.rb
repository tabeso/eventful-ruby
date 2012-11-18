require 'hashie'

module Eventful
  class Resource
    extend Request
    include Request

    attr_reader :attributes

    attr_reader :new_record

    def initialize(attributes = nil)
      @attributes = Hashie::Mash.new(attributes) || {}
      @new_record = true
    end

    def init_with(attributes = nil)
      @attributes = Hashie::Mash.new(attributes) || {}
      @new_record = false
      self
    end

    def to_eventful
      self
    end

    def ==(other)
      self.class == other.class && id == other.id
    end

    def ===(other)
      other.class == Class ? self.class === other : self == other
    end

    def new_record?
      @new_record ||= true
    end

    def persisted?
      !new_record?
    end

    def method_missing(method_name, *arguments, &block)
      attributes.send(method_name, *arguments, &block)
    end

    def respond_to?(method_name, include_private = false)
      attributes.respond_to?(method_name, include_private) || super
    end

    def respond_to_missing?(method_name, include_private = false)
      respond_to?(method_name, include_private) || super
    end
  end
end
