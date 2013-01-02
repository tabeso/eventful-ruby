require 'em-http'

module Eventful
  module Feed
    class Request
      ##
      # @return [String]
      #   The URL of the feed archive.
      attr_reader :url

      ##
      # @return [Document]
      #   The actual feed parser.
      attr_reader :document

      def initialize(resource, limit = :updates, date = nil)
        @url = build_request_url(resource, limit, date || 1.day.ago)
        @document = Document.new(resource)
      end

      ##
      # Executes the request and yields each resources to `&block`. Requests are
      # streamed and decompressed on-the-fly to avoid saving to disk.
      #
      # @example Finding updated events for today
      #     Eventful::Feed::Request.new(:events, :updates, Date.today).execute do |event|
      #       puts event.title
      #     end
      #
      # @example Finding all events for this week (alt. syntax)
      #     Eventful::Feed::Request.new(:events, :full).each do |event|
      #       puts event.title
      #     end
      def execute(&block)
        EventMachine.run do
          io_read, io_write = IO.pipe

          EventMachine.defer(proc {
            document.parse(io_read).resources.each do |resource|
              yield(resource)
            end
          }, proc {
            io_write.close
            EventMachine.stop
          })

          http = EventMachine::HttpRequest.new(url).get
          http.stream do |chunk|
            io_write << chunk
          end
        end
      end
      alias :each :execute

      private

      ##
      # Builds a request URL using the configured feed endpoint, key, date,
      # limit, and resource.
      def build_request_url(resource, limit, date)
        if limit == :full
          # TODO: Find a better solution for calculating/specifying dates.
          # Eventful likes to upload full archives every Saturday.
          until date.saturday?
            date -= 1.day
          end
        end

        "#{Eventful.feed_endpoint}#{Eventful.feed_key}-#{date.strftime('%Y%m%d')}-#{limit.to_s}-#{resource.to_s}.xml.gz"
      end
    end
  end
end