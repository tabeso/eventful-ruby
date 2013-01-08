module Eventful
  module Parser
    class Node
      attr_accessor :name

      attr_accessor :attributes

      attr_reader :text

      def initialize(name, attributes = {})
        @name = name.to_sym
        @attributes = attributes
      end

      def <<(node)
        if node.is_a?(String)
          self.text = node
        else
          children << node
        end
      end

      def text=(value)
        @text = value.strip.force_encoding('UTF-8')
      end

      def children
        @children ||= []
      end

      def to_hash
        if attributes.empty? && children.empty?
          nodes = text.present? ? text : nil
        else
          nodes = [attributes, children_to_hash].inject(&:merge)
          nodes[:__content__] = text if text.present?
        end

        # Normalize collections
        if nodes.is_a?(Hash) && nodes.size == 1 && name.to_s.singularize == nodes.keys.first.to_s
          if nodes.values.first.kind_of?(Array)
            { name => nodes.values.first }
          else
            { name => nodes.values }
          end
        else
          { name => nodes }
        end
      end

      private

      def children_to_hash
        hash = children.inject({}) do |h, node|
          # Convert multiple occurances to arrays
          if h[node.name]
            unless h[node.name].kind_of?(Array)
              h[node.name] = [h[node.name]]
            end
            h[node.name] << node.to_hash[node.name]
          else
            begin
              h[node.name] = node.to_hash[node.name]
            rescue => e
              binding.pry
            end
          end
          h
        end
      end
    end # Node
  end # Parser
end # Eventful