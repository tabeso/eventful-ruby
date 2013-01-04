module Eventful
  module Feed
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
        @text = value.strip
      end

      def children
        @children ||= []
      end

      def to_hash
        if attributes.empty? && children.empty?
          nodes = text.present? ? text : nil
        else
          nodes = [attributes, children].flatten.collect(&:to_hash).inject(&:merge)
          nodes[:__content__] = text if text.present?
        end
        { name => nodes }
      end
    end
  end
end