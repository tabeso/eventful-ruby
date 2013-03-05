require 'excon'

module Eventful
  class Feed
    ##
    # @return [String]
    #   The URL of the feed archive.
    attr_accessor :url

    def initialize(resource, limit = :updates, date = nil)
      @url = build_request_url(resource, limit, date || 1.day.ago)
      @resource = resource
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
      io_read, io_write = IO.pipe.collect(&:binmode)
      streamer = lambda do |chunk, remaining_bytes, total_bytes|
        io_write << chunk
      end
      stream = Thread.new { Excon.get(url, response_block: streamer) }
      parser = Thread.new { Parser.stream(io_read, resource: @resource, &block) }
      [stream, parser].each(&:join)
      self
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

      "%s%s-%s-%s-%s.xml.gz" % [Eventful.feed_endpoint, Eventful.feed_key,
        date.strftime('%Y%m%d'), limit, resource.to_s.demodulize.downcase.pluralize]
    end
  end # Feed
end # Eventful