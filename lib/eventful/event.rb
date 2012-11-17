module Eventful
  
  class Event < Client
    
    class << self
      
      def search(options = {})
        response = get('events/search', options)
        events = []
        response.body['search']['events']['event'].each do |event_data|
          events << new(event_data)
        end
        respond_with events, response, success: true
      end
      
    end
    
    attr_accessor :attributes
    
    def initialize(attributes = {})
      @attributes = attributes
    end
    
    def method_missing(meth_name, *attrs, &block)
      if @attributes.has_key?(meth_name.to_s)
        @attributes[meth_name.to_s]
      else
        super
      end
    end
    
  end
  
end