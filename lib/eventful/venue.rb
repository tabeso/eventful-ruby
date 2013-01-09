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

    def hidden?
      !(display?)
    end

    def withdrawn?
      !!(withdrawn)
    end

    protected

    def self.deserialize_attributes(attrs = {})
      {
        id: attrs[:id],
        url: attrs[:url],
        name: attrs[:name],
        description: attrs[:description],
        category: attrs[:venue_type],
        display: attrs[:display] != '0',
        street_address: attrs[:address],
        city: attrs[:city],
        region: attrs[:region],
        postal_code: attrs[:postal_code],
        country: attrs[:country],
        time_zone: attrs[:tz_olson_path],
        latitude: attrs[:latitude].to_f,
        longitude: attrs[:longitude].to_f,
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
