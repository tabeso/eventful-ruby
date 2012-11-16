module Eventful
  module Response
    attr_accessor :raw_response
    attr_writer   :success

    def success?
      !!@success
    end
  end
end