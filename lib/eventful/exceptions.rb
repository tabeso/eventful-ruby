module Eventful

  class APIError < StandardError; end

  class NotFoundError < APIError; end

  class PermissionsError < APIError; end

end