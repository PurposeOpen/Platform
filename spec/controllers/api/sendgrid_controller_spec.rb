require 'spec_helper'

describe Api::SendgridController do
  let(:walkfree)        { FactoryGirl.create(:movement, :name => 'WalkFree') }
  let(:allout)          { FactoryGirl.create(:movement, :name => 'AllOut') }
  let(:therules)        { FactoryGirl.create(:movement, :name => 'therules') }
  let(:walkfree_member) { FactoryGirl.create(:user, :email => 'member@movement.com',:movement => walkfree) }
  let(:allout_member)   { FactoryGirl.create(:user, :email => 'member@movement.com', :movement => allout) }
  before do
    User.stub(:find_by_movement_id_and_email).and_return(FactoryGirl.build(:user, :movement => walkfree))
    User.stub(:find_by_movement_id_and_email).with(walkfree.id, 'member@movement.com').and_return(walkfree_member)
    User.stub(:find_by_movement_id_and_email).with(allout.id, 'member@movement.com').and_return(allout_member)
    User.stub(:find_by_movement_id_and_email).with(therules.id, 'member-not-found@movement.com').and_return(nil)
  end

  context '#event_handler' do
    it 'should always respond success' do
      post :event_handler, :movement_id => allout.id
      response.code.should == '200'
    end

    context 'with a bounce event' do
      it 'should permanently unsubscribe the member from a specific movement' do
        post :event_handler, :movement_id => allout.id, :email => 'member@movement.com', :event => 'bounce'
        walkfree_member.should be_member
        walkfree_member.can_subscribe?.should be_true

        allout_member.should_not be_member
        allout_member.can_subscribe?.should be_false
      end

      it 'should return 200 if member is nil' do
        post :event_handler, :movement_id => therules.id, :email => 'member-not-found@movement.com', :event => 'bounce'
        response.code.should == '200'
      end
    end

    context 'with a spamreport event' do
      let(:spammed_email) { FactoryGirl.create(:email) }
      before { Email.stub(:find).with(spammed_email.id.to_s).and_return(spammed_email) }

      it 'should permanently unsubscribe the member from a specific movement' do
        UserActivityEvent.stub(:email_spammed!).with(allout_member, spammed_email)
        post :event_handler, :movement_id => allout.id, :email => 'member@movement.com', :event => 'spamreport', :email_id => spammed_email.id
        walkfree_member.should be_member
        walkfree_member.can_subscribe?.should be_true

        allout_member.should_not be_member
        allout_member.can_subscribe?.should be_false
      end

      it 'should report an email spammed event' do
        UserActivityEvent.should_receive(:email_spammed!).with(allout_member, spammed_email)
        post :event_handler, :movement_id => allout.id, :email => 'member@movement.com', :event => 'spamreport', :email_id => spammed_email.id
      end

      it 'should return 200 if member is nil' do
        post :event_handler, :movement_id => therules.id, :email => 'member-not-found@movement.com', :event => 'spamreport'
        response.code.should == '200'
      end
    end
  end
end
