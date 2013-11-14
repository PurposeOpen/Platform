module SerializedOptions

  def self.included(klass)
    klass.class_eval do
      serialize :options, JSON

      validate :symbol_string_key_collision?
    end
    klass.send :extend, ClassMethods
    klass.send :include, InstanceMethods
  end


  module ClassMethods
    def option_fields(*fields)
      fields = fields.map(&:to_sym)
      fields.each do |field|
        define_method "#{field}" do
          read_option_field_value field
        end
        define_method "#{field}=" do |value|
          write_option_field_value field, value
        end
      end
    end
  end


  module InstanceMethods
    def write_option_field_value(field, value)
      existing_options = self.options.clone

      begin
        self.options[field] = value
        self.options = self.options
      rescue
        self.options = existing_options
      end
    end

    def read_option_field_value(field)
      self.options[field]
    end

    def options
      @options ||= begin
        result = read_attribute(:options)

        if result.blank?
          result = {}
          write_attribute(:options, result)
        end

        result.with_indifferent_access
      end
    end

    def options=(hash)
      hash = hash.to_h
      write_attribute(:options, hash)
      @options = hash.with_indifferent_access
    end

    def options_with_discerning_access
      result = read_attribute(:options)
      result.blank? ? {} : result
    end

    def symbol_string_key_collision?
      key_names = options_with_discerning_access.keys.collect { |key| key.to_sym }

      unless key_names.length == key_names.uniq.length
        errors.add(:options, "a string key and symbol key in the options hash have the same 'name'")
      end
    end
  end

end
