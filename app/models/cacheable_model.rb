module CacheableModel
  def self.included(mod)
    mod.send :extend, ClassMethods
    mod.send :include, InstanceMethods
  end

  module ClassMethods
    # optionally takes a block if you want to find by anything other than the model id.
    def get_from_cache(identifier)
      identifier.downcase! if identifier.is_a?(String)
      model = Rails.cache.read(generate_cache_key(identifier))
      if model.nil?
        model = block_given? ? (yield self, identifier) : find(identifier)
        Rails.cache.write(model.cache_key, model, :expires_in => AppConstants.default_cache_timeout) if model
      end
      model
    end

    #  identifier can be an id, email address, etc...
    def generate_cache_key(identifier)
      "#{name.pluralize.downcase}/#{identifier}"
    end
  end

  module InstanceMethods
    # override if your model uses something different as the cache identifier - e.g.: email addresses, friendly ids...
    def cache_key
      self.class.generate_cache_key(self.id)
    end
  end
end
