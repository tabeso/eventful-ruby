module Eventful
  module Response
    attr_accessor :resource

    attr_accessor :collection

    def self.extended(base)
      base.class_eval do
        alias :raw_body :body
        def body
          (resource? || collection?) ? env[:resources] : env[:body]
        end

        alias :original_inspect :inspect
        def inspect
          if resource? || collection?
            resource_or_collection.inspect
          else
            original_inspect
          end
        end
      end
    end

    def success?
      !(raw_body.respond_to?(:has_key?) && raw_body.has_key?(:error))
    end

    def resource?
      !!resource
    end

    def collection?
      !!collection
    end

    def method_missing(method_name, *arguments, &block)
      resource_or_collection.send(method_name, *arguments, &block)
    end

    def respond_to?(method_name, include_private = false)
      resource_or_collection.respond_to?(method_name, include_private) || super
    end

    def respond_to_missing?(method_name, include_private = false)
      respond_to?(method_name, include_private) || super
    end

    protected

    def resource_or_collection
      if resource?
        body.first
      else
        body
      end
    end
  end
end