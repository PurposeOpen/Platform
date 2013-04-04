module ActsAsUserStampable
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def acts_as_user_stampable
      self.send :include, InstanceMethods
      self.send :before_create, :stamp_created_by
      self.send :before_save, :stamp_updated_by
    end
  end

  module InstanceMethods
    def stamp_created_by
      self.created_by = username_or_nil if self.respond_to? :created_by
    end

    def stamp_updated_by
      self.updated_by = username_or_nil if self.respond_to? :updated_by
    end

    def username_or_nil
      PlatformUser.current_user.try(:full_name)
    end
  end
end

ActiveRecord::Base.send :include, ActsAsUserStampable
