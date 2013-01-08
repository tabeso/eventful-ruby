module Eventful
  class Venue
    include Resource

    def self.all(date = Date.yesterday)
      feed(:full, date)
    end

    def self.updates(date = Date.yesterday)
      feed(:updates, date)
    end

    def self.find(id, options = {})
      options.merge!(id: id)
      response = get('venues/get', options)
      venue = instantiate(response.body['venue'])
      respond_with venue, response
    end
  end
end
