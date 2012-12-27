require 'faraday_middleware'

module Eventful
  ##
  # Used by {Client} to execute HTTP requests against APIs.
  module Request
    extend ActiveSupport::Concern

    included do
      # raise ClassMethods.public_instance_methods.inspect
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
          conn.response :xml, content_type: /\bxml$/
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
      def respond_with(object, response = nil, options = {}, &block)
        detect_and_raise_error(response.body) if options[:with_errors]

        object.tap do |o|
          o.extend(Response)
          o.raw_response = response                                    # because they always return 200 >_<
          o.success = options.has_key?(:success) ? options[:success] : !response.body.has_key?('error')
          yield(o) if block_given?
        end
      end

      def detect_and_raise_error(body)
        return false unless body['error']

        klass = case body['error']['string']
        when /Not found/i     then NotFoundError
        when /Access denied/i then PermissionsError
        else                       APIError
        end

        raise klass, "#{body['error']['string']} - #{body['error']['description']}"
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
    end
  end
end
