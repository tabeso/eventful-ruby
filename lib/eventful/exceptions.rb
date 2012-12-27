module Eventful
  class Error < StandardError; end

  class ClientError < Error
    attr_reader :response
    attr_reader :message
    alias :to_s :message

    def initialize(env_or_message = nil)
      if env_or_message.respond_to?(:each_key)
        @response = env_or_message
        @message = "#{env_or_message[:body]['error']['string']} - #{env_or_message[:body]['error']['description']}"
      else
        @message = env_or_message
      end
    end
  end

  class TimeoutError < ClientError; end
  class UnrecognizedError < ClientError; end

  class APIError < ClientError; end
  class NotFoundError < APIError; end
  class PermissionsError < APIError; end
end