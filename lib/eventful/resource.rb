require 'hashie'

module Eventful
  module Resource
    extend ActiveSupport::Concern

    included do
      include Request
      attr_reader :attributes
    end

    ##
    # Instantiates a new Resource, setting the provided attributes, if given.
    # If no attributes are provided, it defaults to an empty `Hash`.
    #
    # @examples Create a new Event
    #     Event.new(title: 'Super Fun Time')
    #
    # @params [Hash] attrs
    #   The attributes to set up the resource with.
    def initialize(attrs = nil)
      @attributes = Hashie::Mash.new(attrs || {})
      @new_record = true
    end

    module ClassMethods
      ##
      # Instantiates a new object when loaded from an API response.
      #
      # @params [Hash] attrs
      #   The hash of attributes to instantiate with.
      #
      # @return [Resource]
      #   A new resource.
      def instantiate(attrs = nil)
        attributes = initialize_attributes(attrs)

        resource = allocate
        resource.instance_variable_set(:@attributes, attributes)
        resource
      end

      protected

      ##
      # Deserializes a hash of attributes and returns them as a `Hashie::Mash`.
      #
      # @param [Hash] attrs
      #   The attributes to prepare.
      #
      # @return [Hashie::Mash]
      #   The intialized attributes.
      def initialize_attributes(attrs = nil)
        attributes = deserialize_attributes(attrs || {})
        Hashie::Mash.new(attributes)
      end

      ##
      # Override to provide custom serialization. Useful for undoing previously
      # deserialized attributes (see {.deserialize_attributes} when sending
      # changes back to the API.
      #
      # @param [Hashie::Mash] attrs
      #   The attributes to serialize.
      #
      # @return [Hash]
      #   The serailzed attributes.
      def serialize_attributes(attrs = {})
        attrs
      end

      ##
      # Override to provide custom deserialization. Useful for typecasting
      # results and maintaining sanity.
      #
      # @param [Hashie::Mash] attrs
      #   The attributes to deserialize.
      #
      # @return [Hash]
      #   The deserialized attributes.
      def deserialize_attributes(attrs = {})
        attrs
      end

      def feed_for(resource, limit = :updates, date = nil)
        Eventful::Feed::Request.new(resource, limit, date)
      end
    end

    def to_eventful
      self
    end

    def inspect
      inspection = attributes.to_a.collect { |attr|
        "#{attr[0]}: #{inspect_attribute(attr[1])}"
      }.compact.join(', ')

      "#<#{self.class.name} #{inspection}>"
    end

    def inspect_attribute(value)
      if value.is_a?(String) && value.length > 50
        "#{value[0..50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      else
        value.inspect
      end
    end

    def ==(other)
      self.class == other.class && id == other.id
    end

    def ===(other)
      other.class == Class ? self.class === other : self == other
    end

    def new_record?
      @new_record ||= false
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
