Given /^I visit the "([^"]*)" campaign page$/ do |name|
  campaign = Campaign.find_by_name(name)
  campaign.should_not be_nil
  campaign.movement.should_not be_nil
  visit admin_movement_campaign_path(campaign.movement, campaign)
end

Given /^a campaign page "([^"]*)"$/ do |page_name|
  page = ActionPage.find_by_name(page_name)
  page = FactoryGirl.create(:action_page, :name => page_name) if page.nil?
  visit edit_admin_movement_action_page_path(@movement, page)
end

Given /^there is an email "([^"]*)" for the "([^"]*)" campaign$/ do |email_name, campaign_name|
  campaign = Campaign.find_by_name(campaign_name)
  campaign.should_not be_nil
  
  push = FactoryGirl.create(:push, :campaign => campaign, :name => "Push for #{email_name}")
  
  blast = FactoryGirl.create(:blast, :push => push, :name => "Blast for #{email_name}")
  email = FactoryGirl.create(:email, {:blast => blast, :name => email_name, :from => "test@yourdomain.com.au", :subject => "test email", :body => "This is a test"})
end

Given /^there is a push "([^"]*)" for the "([^"]*)" campaign$/ do |push_name, campaign_name|
  campaign = Campaign.find_by_name(campaign_name)
  campaign.should_not be_nil
  
  push = FactoryGirl.create(:push, :campaign => campaign, :name => push_name)
  sleep 2
end

Given /^there is a blast "([^"]*)" for the "([^"]*)" push$/ do |blast_name, push_name|
  push = Push.find_by_name(push_name)
  push.should_not be_nil
  blast = FactoryGirl.create(:blast, :push => push, :name => blast_name)  
end

Given /^there is a blast "([^"]*)" with a non-filtering list for the "([^"]*)" push$/ do |blast_name, push_name|
  push = Push.find_by_name(push_name)
  push.should_not be_nil
  list = List.create!
  blast = FactoryGirl.create(:blast, :push => push, :list => list, :name => blast_name)  
end

Given /^there is an email "([^"]*)" for the "([^"]*)" blast$/ do |email_name, blast_name|
  blast = Blast.find_by_name(blast_name)
  email = FactoryGirl.create(:email, {:blast => blast, :name => email_name, :from => "test@yourdomain.com.au", :subject => "test email", :body => "This is a test"}) 
end

Given /^there are (\d+) members in the "([^"]*)" movement$/ do |member_count, movement_name|
  movement = Movement.find_by_name(movement_name)
  member_count.to_i.times do |n|
    if User.count < member_count.to_i 
      FactoryGirl.create(:user, :email => "user_#{n}@example.com", :movement => movement, :language => movement.default_language)
    end
  end
end

Given /^a proof has been sent for "([^"]*)"$/ do |email_name|
  email = Email.find_by_name(email_name)
  email.should_not be_nil
  email.send_test!
end

Given /^"([^"]*)" has been delivered to (\d+) members$/ do |email_name, member_count|
  email = Email.find_by_name(email_name)
  email.should_not be_nil
  job = BlastJob.new({
                   :no_jobs => 1,
                   :current_job_id => 0,
                   :list => email.blast.list,
                   :email => email,
                   :limit => 5
               })
  job.perform
end
When /^I delete the campaign (.+)$/ do|campaign_name|
  click_link("Delete")
end
When /^I go back to the campaign (.+)$/ do |campaign_name|
  sleep 5
  click_link(campaign_name)
end