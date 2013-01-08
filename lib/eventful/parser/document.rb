require 'ox'

module Eventful
  module Parser
    class SyntaxError < RuntimeError; end

    class Document < Ox::Sax
      def initialize(options = {})
        @stream = true if options[:stream]

        if options[:resource]
          @resource_class = options[:resource]
          @resource_name = options[:resource].to_s.demodulize.downcase.to_sym
        end

        unless resource?
          raise ArgumentError, "Option `:resource' is required when streaming."
        end
      end

      def parse(io)
        if stream?
          require 'fiber'
          @parser = Fiber.new { parse!(io) }
        else
          parse!(io)
        end
        self
      end

      def parse!(io)
        decoder = Decoder.new(io)
        Ox.sax_parse(self, decoder, convert_special: true)
        self
      ensure
        decoder.close
      end

      def stream?
        @stream
      end

      def resource?
        @resource_class && @resource_name
      end

      def stack
        @stack ||= []
      end

      def resources
        if stream?
          Enumerator.new do |objects|
            while @parser.alive?
              object = @parser.resume
              objects << object unless object == self
            end
          end
        else
          @resources ||= []
        end
      end

      def nodes
        stack.empty? ? nil : stack.first
      end

      def to_hash
        nodes.nil? ? {} : nodes.to_hash
      end

      def start_element(name)
        stack << Node.new(name)
      end

      def attr(name, value)
        return if stack.empty?
        stack.last.attributes[name] = value
      end

      def text(value)
        stack.last << value
      end
      alias :cdata :text

      def end_element(name)
        node = stack.pop

        if resource? && name == @resource_name
          add_resource(node)
          (stack.empty? ? stack : stack.last) << node unless stream?
        else
          (stack.empty? ? stack : stack.last) << node
        end
      end

      def error(message, line, column)
        raise SyntaxError, "#{message} at line #{line}, column #{column}"
      end

      protected

      def add_resource(node)
        object = @resource_class.instantiate(node.to_hash[@resource_name])

        if stream?
          Fiber.yield(object)
        else
          resources << object
        end
      end
    end
  end # Parser
end # Eventful