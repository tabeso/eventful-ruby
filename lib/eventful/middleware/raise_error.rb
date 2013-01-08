module Eventful
  module Middleware
    class RaiseError < Faraday::Response::Middleware
      def on_complete(env)
        return unless env[:body].respond_to?(:each_key) && env[:body][:error]

        klass = case env[:body][:error][:string]
        when /Not found/i     then NotFoundError
        when /Access denied/i then PermissionsError
        else                       UnrecognizedError
        end

        raise klass, env
      end
    end
  end
end