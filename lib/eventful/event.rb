module Eventful
  
  class Event
    
    class << self
      
      def search(options = {})
        [].tap do |c|
          c.extend Response
          c << new
        end
      end
      
    end
    
  end
  
end