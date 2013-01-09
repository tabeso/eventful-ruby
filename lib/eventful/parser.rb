require 'eventful/parser/decoder'
require 'eventful/parser/document'
require 'eventful/parser/node'

module Eventful
  module Parser
    extend self

    def open(path, options = {}, &block)
      stream(File.open(path, 'rb'), options, &block)
    end

    def parse(io, options = {})
      Document.new(options).parse(io)
    end

    def stream(io, options = {}, &block)
      Document.new(options).callback(&block).parse(io)
    end
  end # Parser
end # Eventful