require 'faraday_middleware'
require 'eventful/middleware/raise_error'

Faraday.register_middleware :response,
  raise_eventful_error: lambda { Eventful::Middleware::RaiseError }