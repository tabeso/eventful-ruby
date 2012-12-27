module Eventful

  class Event
    include Resource

    class << self

      ##
      # Queries Eventful API for events and returns an array of {Event}s if
      # there are any results.
      #
      # @example Search events happening in the next 30 days
      #     Eventful::Event.search(date: Date.today..(Date.today + 30))
      #
      # @example Search events within 10 miles of The Beat Coffeehouse
      #     Eventful::Event.search(location: '36.1689485, -115.1396775', within: 10)
      #
      # @param [Hash] options
      #   Search parameters to pass to Eventful API.
      #
      # @option options [String] :keywords
      #   The search keywords.
      #
      # @option options [String,Array<Float>] :location
      #   A location name to use in filtering search results. Locations can be
      #   specified as "San Diego", "Las Vegas, NV", "London, United Kingdom",
      #   and "Calgary, Alberta, Canada". Postal codes and venue IDs can be
      #   specified. When coordinates are provided, `:within` is **required**
      #   in order to set a search radius.
      #
      # @option options [Date,String,Range] :date
      #   Limit results to a date range. Can be specified with the following
      #   labels: "All", "Future", "Past", "Today", "Last Week", "This Week",
      #   "Next Week", and months by name, e.g. "October". Exact ranges can
      #   be specified:
      #
      # @option options [String] :category
      #   Limit results by a category ID.
      #
      # @option options [Integer] :within
      #   Limit search to a radius when searching with coordinates.
      #
      # @option options [Symbol] :units
      #   Specify units for provided search radius (see `:within` option). Can
      #   be either `:mi` or `:km`. Defaults to `:mi`.
      #
      # @option options [Boolean] :count_only
      #   When `true`, only total items and search time are included in the
      #   result.
      #
      # @option options [Symbol] :sort_order
      #   Can be `:popularity`, `:date`, or `:relevance`. Defaults
      #   to `:relevance`.
      #
      # @option options [Symbol] :sort_direction
      #   Can be `:ascending` or `:descending`. Default varies by `:sort_order`.
      #
      # @option options [Integer] :page_size
      #
      # @option options [Integer] :page_number
      #
      # @option options [Symbol] :mature
      #   Can be `:all`, `:normal`, or `:safe`. Defaults to `:all`.
      #
      # @option options [Array<Symbol>] :include
      #   Include optional sections in results. Sections are: `:categories`,
      #   `:price`, and `:links`.
      #
      # @return [Array<Event>]
      #   The event search results.
      def search(options = {})
        if options[:date].respond_to?(:strftime)
          options[:date] = options[:date].strftime('%Y%m%d00')
        elsif options[:date].respond_to?(:first) && options[:date].respond_to?(:last)
          options[:date] = "#{options[:date].first.strftime('%Y%m%d00')}-#{options[:date].last.strftime('%Y%m%d00')}"
        end

        if options[:include].respond_to?(:collect)
          options[:include] = options[:include].collect(&:to_s).join(',')
        end

        response = get('events/search', options)

        events = response.body['search']['events']['event'].map do |event_data|
          instantiate(event_data)
        end

        respond_with events, response
      end

      def find(id, options= {})
        options.merge!(id: id)
        response = get('events/get', options)
        event = instantiate(response.body['event'])
        respond_with event, response
      end

      def all(date = nil)
        feed_for(:events, :full, date)
      end

      def updates(date = nil)
        feed_for(:events, :updates, date)
      end

    end

  end

end
