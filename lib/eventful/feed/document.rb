require 'fiber'
require 'ox'
require 'zlib'

module Eventful
  module Feed
    class Decoder
      def initialize(io)
        begin
          @stream = Zlib::GzipReader.new(io, encoding: 'binary')
        rescue Zlib::GzipFile::Error => e
          # Fallback to original IO object.
          @stream = io
          @stream.rewind
        end
      end

      def read(length = 0, buffer = '')
        buffer << @stream.read(length).to_s
      end
    end

    ##
    # Handles parsing Eventful's GZip-compressed XML feeds. Provides an
    # enumerator through {#resources}. By default, yields a hash rather than an
    # instance of {Eventful::Resource}.
    #
    # @example Iterating over a feed with hashes.
    #     feed = Eventful::Feed::Document.open('events.xml.gz', :events)
    #     feed.resources.each do |event|
    #       puts event[:name]
    #     end
    #
    # @example Iterating over a feed with resource instances.
    #     feed.resources(load: true).each do |event|
    #       puts event.name
    #     end
    class Document < Ox::Sax
      attr_reader :resource_name

      attr_reader :resource_class

      def self.open(path, resource)
        new(resource).parse(File.open(path, 'rb'))
      end

      def initialize(resource)
        @resource_name = resource.to_s.singularize.to_sym
        @resource_class = "Eventful::#{resource_name.capitalize}".constantize
      end

      def parse(io)
        @parser = Fiber.new do
          begin
            Ox.sax_parse(self, Decoder.new(io))
          ensure
            io.close
          end
        end
        self
      end

      def start_element(name, attrs = [])
        if name == resource_name || in_resource?
          resource_stack << Node.new(name, Hash[*attrs.flatten])
        end
      end

      def text(string)
        return unless in_resource?
        resource_stack.last << string
      end
      alias :cdata :text

      def end_element(name)
        return unless in_resource?

        if name == resource_name
          last = resource_stack.pop
          add_resource(last)
          resource_stack.clear
        elsif resource_stack.size > 1
          last = resource_stack.pop
          resource_stack.last << last
        end
      end

      def in_resource?
        !resource_stack.empty?
      end

      def resource_stack
        @resource_stack ||= []
      end

      def add_resource(node)
        Fiber.yield(node.to_hash[resource_name])
      end

      def resources(options = {})
        Enumerator.new do |objects|
          while data = @parser.resume
            objects << if options[:load]
              resource_class.instantiate(data)
            else
              Hashie::Mash.new(data)
            end
          end
        end
      end
    end
  end
end