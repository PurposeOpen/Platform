require 'spec_helper'

describe Api::SendgridController do
  let(:walkfree)        { FactoryGirl.create(:movement, :name => 'WalkFree') }
  let(:allout)          { FactoryGirl.create(:movement, :name => 'AllOut') }
  let(:therules)        { FactoryGirl.create(:movement, :name => 'therules') }
  let(:walkfree_member) { FactoryGirl.create(:user, :email => 'member@movement.com',:movement => walkfree) }
  let(:allout_member)   { FactoryGirl.create(:user, :email => 'member@movement.com', :movement => allout) }
  let(:default_email) { FactoryGirl.create(:email) }
  before do
    User.stub(:find_by_movement_id_and_email).and_return(FactoryGirl.build(:user, :movement => walkfree))
    User.stub(:find_by_movement_id_and_email).with(walkfree.id, 'member@movement.com').and_return(walkfree_member)
    User.stub(:find_by_movement_id_and_email).with(allout.id, 'member@movement.com').and_return(allout_member)
    User.stub(:find_by_movement_id_and_email).with(therules.id, 'member-not-found@movement.com').and_return(nil)
    Email.stub(:find).with(default_email.id.to_s).and_return(default_email)
  end

  context '#event_handler' do
    it 'should always respond success' do
      post :event_handler, :movement_id => allout.id, :email_id => default_email.id, :event=>'nothing'
      response.code.should == '200'
    end

    it 'should raise an error if member is nil' do
      expect {
        post :event_handler, :movement_id => therules.id, :email => 'member-not-found@movement.com', :event => 'nothing', :email_id=>default_email.id
      }.to raise_error
    end
    
    it 'should raise an error if email_id is nil' do
      expect {
        post :event_handler, :movement_id => therules.id, :email => 'member-not-found@movement.com', :event => 'nothing'
      }.to raise_error
    end    

    context 'with a bounce event' do
      it 'should register a new user activity for bounce but not unsubscribe' do
        UserActivityEvent.should_receive(:email_bounced!).with(allout_member, default_email,"Blocked")        
        post :event_handler, :movement_id => allout.id, :email => 'member@movement.com', :event => 'bounce', :email_id=>default_email.id, :reason=>"Blocked"        
        allout_member.should be_member
        allout_member.can_subscribe?.should be_true        
      end
    end

    context 'with a spamreport event' do
      let(:spammed_email) { FactoryGirl.create(:email) }
      before { Email.stub(:find).with(spammed_email.id.to_s).and_return(spammed_email) }

      it 'should permanently unsubscribe the member from a specific movement' do
        UserActivityEvent.should_receive(:email_spammed!).with(allout_member, spammed_email)
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
      xit 'should return 200 if member is nil' do
        post :event_handler, :movement_id => therules.id, :email => 'member-not-found@movement.com', :event => 'spamreport'
        response.code.should == '200'
      end
    end
    
    context 'with an unsubscribe event' do 
      it 'should unsubscribe the user and register an unsubscribe event' do 
        UserActivityEvent.should_receive(:unsubscribed!).with(allout_member, default_email,nil)
        post :event_handler, :movement_id => allout.id, :email => allout_member.email, :event => 'unsubscribe', :email_id => default_email.id        
        allout_member.should_not be_member
        allout_member.can_subscribe?.should be_true
      end    
    end
    
    context 'with a dropped event' do 
      context 'that is Spam Reporting Address' do 
        it 'should unsubscribe the user but not attribute to the current email blast' do 
          reason='Spam Reporting Address'
          UserActivityEvent.should_receive(:unsubscribed!).with(allout_member,nil,reason)
          #allout_member.should_receive(:permanently_unsubscribe!).with(nil,reason)
          post :event_handler, :movement_id => allout.id, :email => allout_member.email, :event => 'dropped', :email_id => default_email.id, :reason=>reason

          allout_member.should_not be_member
          allout_member.can_subscribe?.should be_false                      
        end
      end
      
      context 'that is Invalid' do 
        it 'should unsubscribe the user but not attribute to the current email blast' do 
          reason='Invalid'
          UserActivityEvent.should_receive(:unsubscribed!).with(allout_member,nil,reason)
          #allout_member.should_receive(:permanently_unsubscribe!).with(nil,reason)
          post :event_handler, :movement_id => allout.id, :email => allout_member.email, :event => 'dropped', :email_id => default_email.id, :reason=>reason

          allout_member.should_not be_member
          allout_member.can_subscribe?.should be_false
        end      
      end
    end
  end
end
