# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

class TaxDeductibleTafDonationModule < TafDonationModule

  DONATION_CLASSIFICATION = '501(c)3'

  def self.label
    "#{DONATION_CLASSIFICATION} - #{name.titleize}"
  end

  def self.classification
  	DONATION_CLASSIFICATION
  end

  def classification
    TaxDeductibleTafDonationModule.classification
  end

end
