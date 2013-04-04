# == Schema Information
#
# Table name: list_intermediate_results
#
#  id         :integer          not null, primary key
#  data       :text
#  ready      :boolean          default(FALSE)
#  list_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  rules      :text
#

require 'spec_helper'

describe ListIntermediateResult do
  it "should return summary" do
    list_intermediate_result = create(:list_intermediate_result, data: {})
    list_intermediate_result.data.should == {}
    list_intermediate_result.summary.should == {}
  end

  it "should return user count" do
    create(:list_intermediate_result, data: {:number_of_selected_users => 10}).user_count.should == 10
    create(:list_intermediate_result).user_count.should be_nil
  end
end
