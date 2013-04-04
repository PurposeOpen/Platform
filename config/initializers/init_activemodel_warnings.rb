ActiveRecord::Base.class_eval do
  include ActiveModel::Warnings
  after_initialize ->{self.skip_warnings = true}

  def valid_with_warnings?
    self.skip_warnings = false
    is_valid = self.valid?
    self.skip_warnings = true
    is_valid
  end
end
