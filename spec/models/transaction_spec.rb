# == Schema Information
#
# Table name: transactions
#
#  id              :integer          not null, primary key
#  donation_id     :integer          not null
#  successful      :boolean          default(FALSE)
#  amount_in_cents :integer
#  response_code   :string(255)
#  message         :string(255)
#  txn_ref         :string(255)
#  bank_ref        :integer
#  action_type     :string(255)
#  refunded        :boolean          default(FALSE), not null
#  refund_of_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  settled_on      :date
#  currency        :string(3)
#  fee_in_cents    :integer
#  status_reason   :string(255)
#  invoiced        :boolean          default(TRUE)
#

require "spec_helper"
describe Transaction do    
  describe "activity event" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @content_module = FactoryGirl.create(:donation_module)
      @page = FactoryGirl.create(:action_page)
      @donation = FactoryGirl.create(:donation, :user => @user, :action_page => @page, :content_module => @content_module)
    end
    
    it "is created if successful" do
      UserActivityEvent.should_receive(:action_taken!).with(@user, @page, @content_module, an_instance_of(Transaction), nil)
      Transaction.create!(:donation => @donation, :successful => true)
    end
    
    it "is not created if not successful" do
      UserActivityEvent.should_not_receive(:action_taken!)
      Transaction.create!(:donation => @donation, :successful => false)      
    end
  end
end
