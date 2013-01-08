module Eventful
  class Image
    include Resource

    URL_PATTERN = %r{^(https?://.*evcdn\.com/images/)(thumb|small|medium)}

    protected

    def self.deserialize_attributes(attrs = {})
      return attrs unless attrs[:url]
      attrs[:original] = {
        url: attrs[:url].gsub(URL_PATTERN, '\1original')
      }
      attrs
    end
  end
end