module SerializedOptions
  def self.included(mod)
    mod.class_eval do
      serialize :options, JSON
    end
    mod.send :extend, ClassMethods
    mod.send :include, InstanceMethods
  end

  module ClassMethods
    # expose serialized options as attributes
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
      self.options = {} if self.options.blank?
      self.options[field.to_s] = value
      self.updated_at = Time.now
    end

    def read_option_field_value(field)
      self.options = {} if self.options.blank?
      self.options[field.to_s]
    end

    #def options
    #  @options ||= begin
    #    result = read_attribute(:options)
    #    p "unserializing: #{result.unserialize}"
    #    p "unserializing-1: #{result}"
    #    p "read_attribute: #{result.inspect}"
    #    if result.respond_to?(:unserialized_value) && result.unserialized_value.nil?
    #      result.value = {}
    #    end
    #    if result.nil?
    #      write_attribute(:options, result = {})
    #    end
    #    result
    #    p "RETURNING #{result.inspect}"
    #    result
    #  end
    #end
  end
end
