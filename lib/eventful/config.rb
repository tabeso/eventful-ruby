require 'eventful/configurable'

module Eventful
  class Config
    include Configurable

    option :api_endpoint, default: 'http://api.eventful.com/rest/'
    option :feed_endpoint, default: 'http://static.eventful.com/images/export/'
    option :http_open_timeout, default: 10
    option :http_read_timeout, default: 15
    option :api_key
    option :feed_key

    def logger
      @logger ||= rails_logger || default_logger
    end

    def logger=(logger)
      @logger = logger
    end

    def faraday_adapter
      @faraday_adapter ||= begin
        require 'faraday'
        Faraday.default_adapter
      end
    end

    def faraday_adapter=(adapter)
      @faraday_adapter = adapter
    end

    private

    def default_logger
      Logger.new($stdout).tap do |log|
        log.level = Logger::INFO
      end
    end

    def rails_logger
      Rails.logger if defined?(Rails) && Rails.respond_to?(:logger)
    end
  end
end