module Eventful
  module Middleware
    class ParseSax < Faraday::Middleware
      CONTENT_TYPE = /\bxml$/

      def initialize(app = nil, options = {})
        super(app)
        @resource = options[:resource]
      end

      def call(env)
        @app.call(env).on_complete do |env|
          if response_type(env) =~ CONTENT_TYPE && parse_response?(env)
            process_response(env)
          end
        end
      end

      def parse(env)
        Parser.parse(env[:body], resource: env[:request].fetch(:resource, @resource))
      end

      def parse_response?(env)
        env[:body].respond_to? :to_str
      end

      def process_response(env)
        env[:raw_body] = env[:body]
        parsed_body = parse(env)
        env[:body] = parsed_body.to_hash
        env[:resources] = parsed_body.resources
      end

      def response_type(env)
        type = env[:response_headers]['Content-Type'].to_s
        type = type.split(';', 2).first if type.index(';')
        type
      end
    end # ParseSax
  end # Middleware
end # Eventful