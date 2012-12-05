module Eventful

  class APIError < StandardError; end

  class NotFoundError < APIError; end

end