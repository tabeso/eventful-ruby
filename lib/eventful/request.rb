module Eventful
  ##
  # Used by {Client} to execute HTTP requests against APIs.
  module Request
    extend ActiveSupport::Concern

    included do
      delegate(*ClassMethods.public_instance_methods, to: 'self.class')
    end

    module ClassMethods
      ##
      # Builds and returns a `Faraday::Connection` for executing HTTP requests.
      #
      # @return [Faraday::Connection]
      def connection
        @connection ||= Faraday::Connection.new(Eventful.api_endpoint) do |conn|
          conn.headers = {
            accept: 'text/xml, application/xml',
            user_agent: user_agent
          }

          conn.options[:request] = {
            open_timeout: Eventful.http_open_timeout,
            timeout: Eventful.http_read_timeout
          }

          conn.response :raise_eventful_error
          conn.response :eventful_parse_sax, resource: self

          conn.use :eventful_wrap_error

          conn.adapter(Eventful.faraday_adapter)
        end
      end

      ##
      # Builds and executes a `GET` request to the specified path with the
      # provided options.
      #
      # @param [String] path
      # @param [Hash] options
      # @return [Faraday::Response]
      def get(path = nil, options = {})
        options[:app_key] ||= Eventful.api_key
        connection.get(path, options)
      end

      ##
      # Builds and executes a `POST` request to the specified path with the
      # provided options.
      #
      # @param [String] path
      # @param [Hash] options
      # @return [Faraday::Response]
      def post(path = nil, options = {})
        connection.post(path, options)
      end

      ##
      # Builds and executes a `PUT` request to the specified path with the
      # provided options.
      #
      # @param [String] path
      # @param [Hash] options
      # @return [Faraday::Response]
      def put(path = nil, options = {})
        connection.put(path, options)
      end

      ##
      # Builds and executes a `DELETE` request to the specified path with the
      # provided options.
      #
      # @param [String] path
      # @param [Hash] options
      # @return [Faraday::Response]
      def delete(path = nil, options = {})
        connection.delete(path, options)
      end

      ##
      # Returns the provided object and attaches the response, additionally
      # specifying whether the request returned a successful response.
      def respond_with(object, options = {}, &block)
        object.tap do |o|
          o.extend(Response)
          o.resource = options[:resource] || false
          o.collection = options[:collection] || false
          yield(o) if block_given?
        end
      end

      ##
      # Returns a formatted string to be used as the user agent when making
      # requests.
      #
      # @return [String]
      #   A user agent describing the environment
      #
      # @example
      #     client.user_agent
      #     # => "eventful-ruby/0.1.0 (Rubygems; Ruby 1.9.3 x86_64-darwin11.4.0)"
      def user_agent
        'eventful-ruby/%s (Rubygems; Ruby %s %s)' % [Eventful::VERSION, RUBY_VERSION, RUBY_PLATFORM]
      end
    end # ClassMethods
  end # Request
end # Eventful