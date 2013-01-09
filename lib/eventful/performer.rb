module Eventful
  class Performer
    include Resource

    def self.all(date = Date.yesterday)
      feed(:full, date)
    end

    def self.updates(date = Date.yesterday)
      feed(:updates, date)
    end

    def self.find(id, options = {})
      options.merge!(id: id)
      response = get('performers/get', options)
      performer = instantiate(response.body['performer'])
      respond_with performer, response
    end

    protected

    def self.deserialize_attributes(attrs = {})
      {
        id: attrs[:id],
        url: attrs[:url],
        name: attrs[:name],
        short_bio: attrs[:short_bio],
        long_bio: attrs[:long_bio],
        withdrawn: attrs[:withdrawn] == '1',
        tags: attrs[:tags] ? attrs[:tags].collect { |t| t[:title] } : [],
        images: deserialize_images(attrs),
        links: attrs[:links] ? attrs[:links] : [],
        created_at: attrs[:created],
        updated_at: attrs[:modified]
      }
    end

    private

    def self.deserialize_images(attrs)
      return [] unless attrs[:images] || attrs[:image]
      attrs[:images] ||= [attrs[:image]]
      attrs[:images].collect { |image| Image.instantiate(image) }.select do |image|
        image.url.present?
      end
    end
  end
end
