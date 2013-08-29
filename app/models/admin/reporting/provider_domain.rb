# == Schema Information
#
# Table name: admin_reporting_provider_domains
#
#  id         :integer          not null, primary key
#  domain     :string(255)
#  provider   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Admin::Reporting::ProviderDomain < ActiveRecord::Base
  attr_accessible :domain, :provider
  
  validates_uniqueness_of :domain
end
