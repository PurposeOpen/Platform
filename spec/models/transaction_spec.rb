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
  describe "refunds" do
    describe "credit card refunds" do
      before(:each) do
        # @donation = FactoryGirl.create(:donation, :amount_in_cents => 2500)
        # @donation.process!
        # ActionMailer::Base.should have(1).deliveries
        # @transaction = @donation.transactions.last
      end
    
      xit "should be able to refund the full amount" do
        @transaction.refund!(@transaction.amount_in_cents)
        @donation.transactions.count.should eql(2)
        @transaction.should be_refunded
              
        refund_transaction = @transaction.refunded_by
        refund_transaction.should be_refund
        refund_transaction.message.should eql("Bogus Gateway: Approved Refund") 
        refund_transaction.amount_in_cents.should == -2500     
        ActionMailer::Base.should have(2).deliveries
      end
      
      xit "should be able to refund a partial amount" do
        @transaction.refund!(50)
        @donation.transactions.count.should eql(2)
        @transaction.should be_refunded
              
        refund_transaction = @transaction.refunded_by
        refund_transaction.should be_refund
        refund_transaction.message.should eql("Bogus Gateway: Approved Refund") 
        refund_transaction.amount_in_cents.should == -50        
        ActionMailer::Base.should have(2).deliveries
      end
      
      xit "should not refund more than the original amount" do
        lambda { @transaction.refund!(@transaction.amount_in_cents + 1) }.should raise_error(Transaction::RefundFailedError)
        @donation.transactions.count.should eql(1)
        @transaction.should_not be_refunded
        ActionMailer::Base.should have(1).deliveries
      end
      
      xit "should record an attempted transaction but not mark as refunded on gateway failure" do
        lambda { @transaction.refund!(ActiveMerchant::Billing::BogusGateway::MAGIC_CENTS_TO_FORCE_FAILURE) }.should raise_error(Transaction::RefundFailedError)
        @donation.transactions.count.should eql(2)
        @transaction.should_not be_refunded
        @donation.transactions.last.message.should == "Bogus Gateway: Failed Refund"
        ActionMailer::Base.should have(1).deliveries        
      end
      
      xit "should not refund a failed transaction" do
        @transaction.update_attributes!(:successful => false)
        lambda { @transaction.refund!(@transaction.amount_in_cents) }.should raise_error(Transaction::RefundFailedError)
        ActionMailer::Base.should have(1).deliveries        
      end
      
      xit "should not refund a transaction twice" do
        @transaction.refund!(100)
        lambda { @transaction.refund!(100) }.should raise_error(Transaction::RefundFailedError)
        ActionMailer::Base.should have(2).deliveries        
      end
    end
  end

  describe "csv data export" do
    it "should use an optimized query to load the transactions from the database" do
      donation = FactoryGirl.create(:donation, :amount_in_cents => 2500)
      transaction1 = Transaction.create!(:donation => donation, :successful => true, :created_at => Date.today)
      transaction2 = Transaction.create!(:donation => donation, :successful => true, :created_at => Date.today)
      transaction3 = Transaction.create!(:donation => donation, :successful => true, :created_at => 2.days.ago)
      other_user = FactoryGirl.create(:user)
      transaction4 = Transaction.create!(:donation => FactoryGirl.create(:donation, :amount_in_cents => 2500, :user => other_user), :successful => true, :created_at => 2.days.from_now)

      transactions = Transaction.filter_by(:from_date =>1.day.ago, :to_date => 1.day.from_now).map(&:txn_id)
      transactions.size.should eql 2
      transactions.should include(transaction1.id)
      transactions.should include(transaction2.id)

      transactions = Transaction.filter_by(:user_id => other_user.id).map(&:user_id)
      transactions.size.should eql 1
      transactions.should include(other_user.id)
    end
  end

  describe "filtering" do
    context "existing transactions" do
      before(:each) do
        # payment_methods = [:eftpos, :cash, :money_order, :bank_cheque, :paypal, :creditcard, :cheque]
        # @transactions = payment_methods.inject([]) do |acc, method|
        #   donation = FactoryGirl.create(:donation, :payment_method => method)
        #   acc << FactoryGirl.create(:transaction, :donation => donation, :successful => false)
        #   acc
        # end
      end
      xit "should allow transactions to be filtered by multiple payment methods" do

        transactions = Transaction.filter_by(:payment_methods => [:eftpos]).all
        transactions.size.should eql 1
        transactions[0].txn_id.should eql @transactions.select { |t| t.donation.payment_method.to_sym == :eftpos }[0].id

        transactions = Transaction.filter_by(:payment_methods => [:paypal, :cheque]).all
        transactions.size.should eql 2
        transactions.map(&:payment_method).should include("paypal")
        transactions.map(&:payment_method).should include("cheque")

        transactions = Transaction.filter_by(:payment_methods => ['']).all
        transactions.size.should eql 7
      end

      xit "should allow transactions to be filtered by status" do
        @transactions.first.update_attribute(:successful, true)
        successful_transaction_1 = @transactions.first
        @transactions.last.update_attribute(:successful, true)
        successful_transaction_2 = @transactions.last

        transactions = Transaction.filter_by({:status => "successful"}).all
        transactions.size.should eql 2
        transactions.select { |transaction| transaction.txn_id == successful_transaction_1.id }.blank?.should be_false
        transactions.select { |transaction| transaction.txn_id == successful_transaction_2.id }.blank?.should be_false
      end

      xit "should allow transactions to be filtered by donor's email" do
        donor = FactoryGirl.create(:user)
        another_donor = FactoryGirl.create(:user)
        @transactions.first.donation.update_attribute(:user, donor)
        transaction_1 = @transactions.first
        @transactions.last.donation.update_attribute(:user, donor)
        transaction_2 = @transactions.last
        @transactions[1].donation.update_attribute(:user, another_donor)

        transactions = Transaction.filter_by({:user_email => donor.email}).all
        transactions.size.should eql 2
        transactions.select { |transaction| transaction.txn_id == transaction_1.id }.blank?.should be_false
        transactions.select { |transaction| transaction.txn_id == transaction_2.id }.blank?.should be_false
      end

      xit "should filter transactions by date" do
        from = 1.month.from_now
        to = 1.month.from_now + 2.days
        transaction_1 = FactoryGirl.create(:transaction, :created_at => from)
        transaction_2 = FactoryGirl.create(:transaction, :created_at => to)

        transactions = Transaction.filter_by({:from_date => (from - 1.day).strftime("%d-%m-%Y"), :to_date => (to + 1.day).strftime("%d-%m-%Y")}).all
        transactions.size.should eql 2
        transactions.select { |transaction| transaction.txn_id == transaction_1.id }.blank?.should be_false
        transactions.select { |transaction| transaction.txn_id == transaction_2.id }.blank?.should be_false
      end
    end


    it "should return transactions within the last month only if no dates are given" do
      transaction_1 = FactoryGirl.create(:transaction, :created_at => 1.week.ago - 1.day)
      transaction_2 = FactoryGirl.create(:transaction, :created_at => 1.day.ago)

      transactions = Transaction.filter_by
      transactions.size.should eql 1
      transactions[0].txn_id.should eql transaction_2.id
    end
  end

  describe "grouping" do
    before(:each) do
      # payment_methods =  Donation::PAYMENT_METHODS
      # @created_at = Date.parse("28-12-2011")
      # @transactions = payment_methods.inject([]) do |acc, method|
      #     donation = FactoryGirl.create(:donation, :payment_method => method, :frequency => :one_off)
      #     acc << FactoryGirl.create(:transaction, :donation => donation, :successful => false, :amount_in_cents => 1000, :created_at => @created_at)
      #     acc
      # end
    end
    xit "should allow transactions to be grouped by year, month, campaign and frequency" do
      donation = FactoryGirl.create(:donation, :payment_method => :cash, :frequency => :one_off)
      FactoryGirl.create(:transaction, :donation => donation, :successful => false, :amount_in_cents => 1000, :created_at => Date.parse("28-12-2012"))

      transactions = Transaction.filter_by(:group_by => [:year_month, :campaign, :frequency]).all
      transactions.size.should eql 2
      transactions[0].year.should eql @created_at.year
      transactions[0].month.should eql @created_at.month
      transactions[0].frequency.should eql "one_off"
      transactions[0].total.should eql 7000
    end
  end
end
