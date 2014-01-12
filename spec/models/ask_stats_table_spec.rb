require "spec_helper"

describe AskStatsTable do
  it "should extract all the ask modules from a set of action sequences and map them to rows" do
    campaign = FactoryGirl.create(:campaign)
    3.times do |i|
      seq = FactoryGirl.create(:action_sequence, :campaign => campaign, :name => "Dummy Action Sequence Name-#{i}")
      seq.action_pages << page = FactoryGirl.create(:action_page, :action_sequence => seq, :name => "Page-#{i}")
      page.content_modules << FactoryGirl.create(:html_module)
      page.content_modules << FactoryGirl.create(:donation_module)
    end

    stats = Campaign.find_by_sql(campaign.build_stats_query)
    table = AskStatsTable.new(stats)
    table.rows.count.should == 3
    first_row = table.rows.first
    first_row.shift

    first_row[0].should =~ /Dummy Action Sequence Name/
    first_row[1].should =~ /Page/
    first_row[2].should == "Donation module"
    first_row[3].should == 0
    first_row[4].should == 0
  end

  context 'multi-lingual campaigns (more than one actionable module on a page),' do
    it "should report the number of actions for an action page" do
      english = FactoryGirl.create(:english)
      portuguese = FactoryGirl.create(:portuguese)
      user = FactoryGirl.create(:user)

      page = FactoryGirl.create(:action_page, :name => 'multi-lingual page')
      campaign = page.action_sequence.campaign
      en_petition_module = FactoryGirl.create(:petition_module, :language => english, :pages => [page])
      pt_petition_module = FactoryGirl.create(:petition_module, :language => portuguese, :pages => [page])

      en_petition_module.take_action(user, {}, page)
      pt_petition_module.take_action(user, {}, page)

      stats = Campaign.find_by_sql(campaign.build_stats_query)
      table = AskStatsTable.new(stats)

      table.rows.count.should == 1
      first_row = table.rows.first
      first_row.shift

      first_row[0].should =~ /Dummy Action Sequence Name/
      first_row[1].should =~ /multi-lingual page/
      first_row[2].should == "Petition module"
      first_row[3].should == 2
      first_row[4].should == 0
    end

    it "should report the number of actions for a join page" do
      english = FactoryGirl.create(:english)
      portuguese = FactoryGirl.create(:portuguese)

      movement = FactoryGirl.create(:movement, :languages => [english, portuguese])
      campaign = FactoryGirl.create(:campaign, :movement => movement)
      action_sequence = FactoryGirl.create(:action_sequence, :campaign => campaign, :name => 'join sequence')
      page = FactoryGirl.create(:action_page, :name => 'multi-lingual join page', :action_sequence => action_sequence)

      en_join_module = FactoryGirl.create(:join_module, :language => english, :pages => [page])
      pt_join_module = FactoryGirl.create(:join_module, :language => portuguese, :pages => [page])

      en_user = FactoryGirl.build(:user, :language => english, :movement => movement)
      pt_user = FactoryGirl.build(:user, :language => portuguese, :movement => movement)

      en_user.take_action_on!(page)
      pt_user.take_action_on!(page)

      stats = Campaign.find_by_sql(campaign.build_stats_query)
      table = AskStatsTable.new(stats)

      table.rows.count.should == 1
      first_row = table.rows.first
      first_row.shift

      first_row[0].should =~ /join sequence/
      first_row[1].should =~ /multi-lingual join page/
      first_row[2].should == "Join module"
      first_row[3].should == 0
      first_row[4].should == 2
    end

    it "should report the average and total donation amounts per page" do
      english = FactoryGirl.create(:language)
      portuguese = FactoryGirl.create(:language)

      movement = FactoryGirl.create(:movement, :languages => [english, portuguese])
      campaign = FactoryGirl.create(:campaign, :movement => movement)
      action_sequence = FactoryGirl.create(:action_sequence, :campaign => campaign, :name => 'Action Sequence Name')
      page = FactoryGirl.create(:action_page, :name => 'Page Name', :action_sequence => action_sequence)

      en_donation_module = FactoryGirl.create(:donation_module, :language => english, :pages => [page])
      pt_donation_module = FactoryGirl.create(:donation_module, :language => portuguese, :pages => [page])

      mailer = mock
      mailer.stub(:deliver)
      PaymentMailer.stub(:confirm_purchase) { mailer }

      en_user = FactoryGirl.build(:user, :language => english, :movement => movement)
      pt_user = FactoryGirl.build(:user, :language => portuguese, :movement => movement)
      en_user.take_action_on!(page, {:payment_method => :paypal, :confirmed => true, :amount => 1000, :currency => :usd, :frequency => :one_off, :transaction_id => '1', :order_id => '1'})
      en_user.take_action_on!(page, {:payment_method => :paypal, :confirmed => true, :amount => 1500, :currency => :usd, :frequency => :one_off, :transaction_id => '2', :order_id => '2'})
      en_user.take_action_on!(page, {:payment_method => :paypal, :confirmed => true, :amount => 250, :currency => :usd, :frequency => :one_off, :transaction_id => '3', :order_id => '3'})
      pt_user.take_action_on!(page, {:payment_method => :credit_card, :confirmed => true, :amount => 900, :currency => :usd, :frequency => :one_off, :transaction_id => '4', :order_id => '4'})
      pt_user.take_action_on!(page, {:payment_method => :credit_card, :confirmed => true, :amount => 3050, :currency => :usd, :frequency => :one_off, :transaction_id => '5', :order_id => '5'})

      stats = Campaign.find_by_sql(campaign.build_stats_query)
      table = AskStatsTable.new(stats)

      table.rows.count.should == 1
      first_row = table.rows.first
      first_row.shift

      first_row[0].should =~ /Action Sequence Name/
      first_row[1].should =~ /Page Name/
      first_row[2].should == 'Donation module'
      first_row[3].should == 5
      first_row[4].should == 0
      first_row[5].should == "$67.00"
      first_row[6].should == "$13.40"
    end
  end

end
