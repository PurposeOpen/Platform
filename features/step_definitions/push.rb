When /^I add create a (.+) push$/ do |push_name|
  click_link("Add a push")
  fill_in("push_name",:with=>push_name)
  click_button("Create push")
end
When /^I add a (.+) blast$/ do |blast_name|
  click_link("Add a blast")
  fill_in("blast_name",:with=>blast_name)
  click_button("Create blast")
  sleep 2
end
When /^I add new email (.+) to the blast$/ do|email_name|
  page.execute_script('$("ul.actions li ul li a")[0].click()')
  sleep 2
  fill_in("email_name",:with=>email_name)
end

When /^I enter the details of the email$/ do
  fill_in("email_from",:with=>"noreply@yourdomain.com")
  fill_in("email_reply_to",:with=>"noreply@yourdomain.com")
  fill_in("email_subject",:with=>"Test Email")
  page.execute_script('$("iframe")[0].contentDocument.documentElement.innerHTML="<html>This is creating a new test blast email</html>"')
  sleep 5
  click_button("Save")
  sleep 5
end

When /^(?:|I )write in "([^"]*)" with "([^"]*)"$/ do |field, value|
  page.execute_script('$("iframe")[0].contentDocument.documentElement.innerHTML="<html>#{value}</html>"')
end

Then /^I goto the push (.+)$/ do |push_name|
  click_link(push_name)
end

When /^I Save push$/ do
  find(:xpath)
end

When /^I enter the new name as (.+) for the same push$/ do |push_name|
  fill_in("push_name",:with=>push_name)
end

When /I expand Add an Email to click New Email/ do
  page.execute_script('$("ul.actions li ul li a")[0].click()')
  sleep 2
end

Given /^there is a push "([^"]*)" in the "([^"]*)" campaign$/ do |push_name, campaign_name|
  campaign = Campaign.find_by_name(campaign_name)
  campaign.should_not be_nil

  FactoryGirl.create(:push, :campaign => campaign, :name => push_name)
end

When /^I click Rename for the push "([^"]*)"$/ do |push_name|
  push = Push.find_by_name(push_name)
  push.should_not be_nil
  rename_link_selector = "#push-#{push.id} a.right"
  page.find(rename_link_selector).click()
end

When /^I press Save Push button$/ do
  click_button("Save push")
end

Then /^I should see "([^"]*)" in the Pushes listing$/ do |push_name|
  within(:css, "#pushes_list") do
    page.should have_content(push_name)
  end
end

When /^I check for Add an email$/ do
  find(:xpath,"//ul[@class='actions']/li/span[@class='button']").should have_content("Add an email")
end