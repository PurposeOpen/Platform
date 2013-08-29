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

require 'spec_helper'

describe Admin::Reporting::ProviderDomain do
  pending "add some examples to (or delete) #{__FILE__}"
end
