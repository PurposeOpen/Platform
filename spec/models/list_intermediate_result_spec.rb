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

  context "update results from sent email" do
  	before do
  		@english = create(:english)
	  	@email = create(:email, :language => @english)
  	end

  	it "should update results when list targets a single language" do	    
	    list_intermediate_result = create(:list_intermediate_result, data: { :number_of_selected_users => 200, :number_of_selected_users_by_language => { 'English' => 200 }})

	    list_intermediate_result.update_results_from_sent_email!(@email, 100)

	    list_intermediate_result.user_count.should == 100
	    list_intermediate_result.summary[:number_of_selected_users_by_language]['English'].should == 100
	  end

	  it "should update results when list targets multiple laguages" do
	    list_intermediate_result = create(:list_intermediate_result, data: { :number_of_selected_users => 200, :number_of_selected_users_by_language => { 'English' => 100, 'Spanish' => 100 }})
	    
	    list_intermediate_result.update_results_from_sent_email!(@email, 100)

	    list_intermediate_result.user_count.should == 100
	    list_intermediate_result.summary[:number_of_selected_users_by_language]['English'].should == 0
	    list_intermediate_result.summary[:number_of_selected_users_by_language]['Spanish'].should == 100
	  end
  end
  
end
