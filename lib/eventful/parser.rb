require 'eventful/parser/decoder'
require 'eventful/parser/document'
require 'eventful/parser/node'

module Eventful
  module Parser
    extend self

    def open(path, options = {})
      stream(File.open(path, 'rb'), options)
    end

    def parse(io, options = {})
      Document.new(options).parse(io)
    end

    def stream(io, options = {})
      Document.new(options.merge(stream: true)).parse(io).resources
    end
  end # Parser
end # Eventful