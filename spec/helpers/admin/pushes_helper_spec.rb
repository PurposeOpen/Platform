require "spec_helper"

describe Admin::PushesHelper do
  it "should return a valid link for an existing list" do
    list = create(:list)
    blast = list.blast

    expected_url = admin_movement_list_cutter_edit_path(:movement_id => blast.push.campaign.movement, :list_id => blast.list)
    expected_html = %Q{<a href="#{expected_url}">Recipients</a>}

    helper.link_to_create_or_update(blast).should == expected_html
  end

  it "should return a link to create a new list" do
    blast = create(:blast)

    expected_url = admin_movement_list_cutter_new_path(:movement_id => blast.push.campaign.movement, :blast_id => blast)
    expected_html = %Q{<a href="#{expected_url}">Recipients</a>}

    helper.link_to_create_or_update(blast).should == expected_html
  end

  it "should return a formatted member count for a list" do
    list = create(:list, saved_intermediate_result: create(:list_intermediate_result, :data => {:number_of_selected_users => 521}))
    helper.member_count(list.blast).should == "(521 members)"
  end
  
  it "should return empty string for member count when no list" do
    blast = create(:blast)
    helper.member_count(blast).should == ""
  end

  it "should return a metric for a given email" do
    UserActivityEvent.stub_chain(:emails_sent, :where, :count).and_return(253)
    helper.email_stat(:emails_sent, 5).should === 253
  end

  it "shoud return a count for the number of members a blast has been sent to" do
    list = create(:list)
    blast = list.blast
    blast.should_receive(:latest_sent_user_count).and_return(342)
    helper.blast_sent_count(blast).should == 342
  end

  it "should properly display the last updated at message for stats" do
    time = 10.hours.ago
    helper.last_updated_at_msg(time).should eql "Last updated #{time_ago_in_words(time)}"
    helper.last_updated_at_msg(nil).should eql "Stats haven't been updated yet"
  end
end
