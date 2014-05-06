require "spec_helper"

describe ListCutter::OriginatingActionRule do
  it "should validate itself" do
    rule = ListCutter::OriginatingActionRule.new
    rule.valid?.should be_false
    rule.errors.messages.should == {page_ids: ["Please select one or more pages"], movement_id:["Please specify the movement"]}
  end

  context "to_relation" do
    it "should return all the users subscribed through the given action pages" do
      @movement = create(:movement)
      @user1 = create(:user, movement: @movement)
      @user2 = create(:user, movement: @movement)
      @user3 = create(:user, movement: @movement)
      @user4 = create(:user, movement: @movement)
      @petition_module1 = create(:petition_module)
      @join_module = create(:join_module)
      @petition_module2 = create(:petition_module)
      @donation_module = create(:donation_module)
      @email_targets_module = create(:email_targets_module)
      @page1 = create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: @movement)))
      @page2 = create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: @movement)))

      @content1 = create(:content_module_link, content_module: @join_module, page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: @movement))))
      @content2 = create(:content_module_link, content_module: @petition_module1, page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: @movement))))
      @content3 = create(:content_module_link, content_module: @email_targets_module, page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: @movement))))
      @content4 = create(:content_module_link, content_module: @donation_module, page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: @movement))))
      @content5 = create(:content_module_link, content_module: create(:tell_a_friend_module), page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: @movement))))
      @content6 = create(:content_module_link, content_module: create(:petition_module), page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: create(:movement)))))

      user_activity_event1 = create(:subscribed_activity, user: @user1, page: @content1.page, content_module: @content1.content_module, movement_id: @movement.id)
      user_activity_event2 = create(:subscribed_activity, user: @user2, page: @content2.page, content_module: @content2.content_module, movement_id: @movement.id)
      user_activity_event3 = create(:subscribed_activity, user: @user3, page: @content2.page, content_module: @content2.content_module, movement_id: @movement.id)
      user_activity_event4 = create(:subscribed_activity, user: @user4, page: @content3.page, content_module: @content3.content_module, movement_id: @movement.id)

      ListCutter::OriginatingActionRule.new(
        page_ids: [@content1.page.id.to_s, @content2.page.id.to_s], 
        movement_id: @movement.id
      ).to_relation.all.should match_array([@user1, @user2, @user3])
    end
  end

  describe "to_human_sql" do
    it "should return human readable form of conditions" do
      movement = create(:movement)
      page1 = create(:action_page, name: "Page1", action_sequence: create(:action_sequence, campaign: create(:campaign, movement: movement)))
      page2 = create(:action_page, name: "Page2", action_sequence: create(:action_sequence, campaign: create(:campaign, movement: movement)))
      ListCutter::OriginatingActionRule.new(page_ids: [page1.id, page2.id], movement_id: movement.id, not: false).to_human_sql.should == "Originating Action is any of these: Page1, Page2"
      ListCutter::OriginatingActionRule.new(page_ids: [page1.id, page2.id], movement_id: movement.id, not: true).to_human_sql.should == "Originating Action is not any of these: Page1, Page2"
    end
  end
end