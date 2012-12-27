module Eventful
  module Configurable
    extend ActiveSupport::Concern

    module ClassMethods

      def option(name, options = {})
        option_name = name.to_sym
        defaults[option_name] = options[:default]

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{option_name}
            settings[:#{option_name}]
          end

          def #{option_name}=(value)
            settings[:#{option_name}] = value
          end

          def #{option_name}?
            !!#{option_name}
          end
        RUBY
      end

      def defaults
        @defaults ||= {}
      end
    end

    def initialize(options = {})
      settings.replace(self.class.defaults)

      options.each do |option, value|
        self[option] = value
      end
    end

    def [](option)
      settings[option.to_sym]
    end

    def []=(option, value)
      send(:"#{option}=", value)
    end

    def ==(other)
      to_hash == other.to_hash
    end

    def merge!(hash)
      hash.each do |option, value|
        self[option] = value
      end

      self
    end

    def merge(hash)
      self.class.new(to_hash.merge(hash))
    end

    def reset!
      settings.replace(self.class.defaults)
    end

    def settings
      @settings ||= {}
    end
    alias :to_hash :settings
  end
end