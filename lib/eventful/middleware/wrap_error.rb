module Eventful
  module Middleware
    class WrapError < Faraday::Middleware
      def call(env)
        begin
          @app.call(env)
        rescue Faraday::Error::TimeoutError
          raise TimeoutError, $!
        end
      end
    end
  end
end