require 'faraday_middleware'
require 'eventful/middleware/parse_sax'
require 'eventful/middleware/raise_error'
require 'eventful/middleware/wrap_error'

Faraday.register_middleware :response,
  eventful_parse_sax: lambda { Eventful::Middleware::ParseSax }

Faraday.register_middleware :response,
  raise_eventful_error: lambda { Eventful::Middleware::RaiseError }

Faraday.register_middleware \
  eventful_wrap_error: lambda { Eventful::Middleware::WrapError }