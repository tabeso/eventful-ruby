module Eventful
  module Parser
    class Decoder
      attr_reader :stream

      def initialize(io)
        require 'zlib'
        io = StringIO.new(io) if io.is_a?(String)
        @stream = Zlib::GzipReader.new(io, encoding: 'binary')
      rescue Zlib::GzipFile::Error => e
        # Fallback to original IO object.
        @stream = io
        @stream.rewind
      end

      def read(length = 0, buffer = '')
        buffer << @stream.read(length).to_s
      end

      delegate :close, to: :stream
    end # Decoder
  end # Parser
end # Eventful