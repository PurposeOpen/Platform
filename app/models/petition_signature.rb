# == Schema Information
#
# Table name: petition_signatures
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  content_module_id  :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  page_id            :integer          not null
#  email_id           :integer
#  dynamic_attributes :text
#  comment            :string(255)
#

class PetitionSignature < ActiveRecord::Base
  include ActsAsUserResponse
  after_create :create_activity_event

  MAX_COMMENT_LENGTH = 200
  
  validate :required_dynamic_attributes_are_present, unless: "self.content_module.custom_fields.blank?"
  validates_length_of :comment, maximum: MAX_COMMENT_LENGTH
  
  has_dynamic_attributes
    
  def required_dynamic_attributes_are_present
    fails = 0
    self.content_module.custom_fields.select{|v|v[:required]}.each do |required|
      if self.read_dynamic_attribute(required[:name]).blank?
        self.errors[required[:name].to_sym] << "is required"
        fails + 1
      end
    end
    return false if fails > 0
  end
  
end
