require "spec_helper"

describe ListCutter::EmailActionRule do
  before(:each) do
    @blast = create(:blast)
    @email1 = create(:email, :blast => @blast)
    @movement = @blast.push.campaign.movement
    @user = create(:user, :movement => @movement)
    @user1 = create(:user, :movement => @movement)
    @user2 = create(:user, :movement => @movement)
    @email2 = create(:email, :blast => @blast)
  end

  context 'to_relation' do
    let(:list) {create(:list, :blast => @blast)}

    before(:each) do
      Push.log_activity!(UserActivityEvent::Activity::EMAIL_CLICKED, @user, @email1)
      Push.log_activity!(UserActivityEvent::Activity::EMAIL_CLICKED, @user1, @email2)
      Push.log_activity!(UserActivityEvent::Activity::EMAIL_SENT, @user2, @email2)
    end

    it "should return the users who received the given emails" do
      rule = ListCutter::EmailActionRule.new(:email_ids => [@email1.id, @email2.id], :action => UserActivityEvent::Activity::EMAIL_CLICKED.to_s, :movement => @movement)
      rule.to_relation.all.should =~ [@user, @user1]
    end
  end

  it "should return human readable form of conditions" do
    ListCutter::EmailActionRule.new(action: "sent", email_ids: [@email1.id], not: false).to_human_sql.should == "Email status is Sent for email any of these #{@email1.name}"
    ListCutter::EmailActionRule.new(action: "sent", email_ids: [@email1.id], not: true).to_human_sql.should == "Email status is not Sent for email any of these #{@email1.name}"
  end
end
