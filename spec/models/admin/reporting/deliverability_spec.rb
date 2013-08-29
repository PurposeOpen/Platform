# == Schema Information
#
# Table name: admin_reporting_deliverabilities
#
#  id          :integer          not null, primary key
#  target_date :date
#  report      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Admin::Reporting::Deliverability do
  pending "add some examples to (or delete) #{__FILE__}"
end
