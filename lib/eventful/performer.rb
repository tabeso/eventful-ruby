module Eventful
  class Performer
    include Resource

    def self.all(date = nil)
      feed_for(:performers, :full, date)
    end

    def self.updates(date = nil)
      feed_for(:performers, :updates, date)
    end

    def self.find(id, options = {})
      options.merge!(id: id)
      response = get('performers/get', options)
      performer = instantiate(response.body['performer'])
      respond_with performer, response
    end
  end
end
