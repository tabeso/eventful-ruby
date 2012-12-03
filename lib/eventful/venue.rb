module Eventful
  class Venue
    include Resource

    def self.all(date = nil)
      feed_for(:venues, :full, date)
    end

    def self.updates(date = nil)
      feed_for(:venues, :updates, date)
    end

    def self.find(id, options = {})
      options.merge!(id: id)
      response = get('venues/get', options)
      venue = instantiate(response.body['venue'])
      respond_with venue, response, with_errors: true
    end
  end
end
