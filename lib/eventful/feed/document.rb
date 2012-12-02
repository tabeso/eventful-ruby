require 'nokogiri'

module Eventful
  module Feed
    class Document < Nokogiri::XML::SAX::Document
      attr_reader :resource_name

      attr_reader :resource_class

      def initialize(resource)
        @resource_name = resource.to_s.singularize
        @resource_class = "Eventful::#{resource_name.capitalize}".constantize
      end

      def start_element(name, attrs = [])
        if name == resource_name || in_resource?
          resource_stack << Node.new(name, Hash[*attrs.flatten])
        end
      end

      def characters(string)
        return unless in_resource?
        resource_stack.last.add_node(string) unless string.strip.length == 0 || resource_stack.empty?
      end
      alias :cdata_block :characters

      def end_element(name)
        return unless in_resource?

        if name == resource_name
          last = resource_stack.pop
          resources << build_resource(last)
          resource_stack.clear
        elsif resource_stack.size > 1
          last = resource_stack.pop
          resource_stack.last.add_node last
        end
      end

      def in_resource?
        !resource_stack.empty?
      end

      def resource_stack
        @resource_stack ||= []
      end

      def resources
        @resources ||= []
      end

      private

      def build_resource(node)
        data = node.to_hash[resource_name]
        resource_class.instantiate(data)
      end
    end
  end
end