Given /^I visit the "([^"]*)" action sequence page$/ do |sequence_name|
  action_sequence = ActionSequence.find_by_name(sequence_name)
  visit admin_movement_action_sequence_path(action_sequence.campaign.movement, action_sequence)
end

Given /^I visit the "([^"]*)" page$/ do |name|
  page = ActionPage.find_by_name(name)
  page.should_not be_nil
  #visit page_path(page.action_sequence.campaign, page.action_sequence, page)

  visit "/#{page.slug}"
end

Given /^I visit the admin "([^"]*)" page$/ do |name|
  page = ActionPage.find_by_name(name)
  page.should_not be_nil
  visit edit_admin_movement_action_page_path(page.action_sequence.campaign.movement, page)
end

When /^I follow "([^"]*)" for "([^"]*)" action sequence$/ do |link_name, sequence_name|
  action_sequence = ActionSequence.find_by_name(sequence_name)
  selector = "\"#action-sequence-#{action_sequence.id}\""
  with_scope(selector) do
    click_link(link_name)
  end
end

Then /"(.*)" should appear before "(.*)"/ do |first_example, second_example|
  page.body.should =~ /#{first_example}.*#{second_example}/m
end

# Testing modal window
When /^(?:|I )follow "([^"]*)"(?: for the action sequence "([^"]*)")? and click "([^"]*)"$/ do |link, name, action|
  action_sequence = ActionSequence.find_by_name(name)
  action_sequence.should_not be_nil
  selector = "#action-sequence-#{action_sequence.id}"
  with_scope(selector) do
    prepare_dialog_box(action)
    click_link(link)
  end
end

When /^(?:|I )follow "([^"]*)"(?: for the page "([^"]*)")? and click "([^"]*)"$/ do |link, name, action|
  page = ActionPage.find_by_name(name)
  page.should_not be_nil
  selector = "#page_#{page.id}"
  with_scope(selector) do
    prepare_dialog_box(action)
    click_link(link)
  end
end

Given /^a campaign page entitled "([^"]*)" with required (.*)$/ do |page_name, user_detail|
  FactoryGirl.create(:action_page, :name => page_name, :required_user_details => {user_detail => :required})
end

Given /^a campaign page entitled "([^"]*)"$/ do |page_name|
  FactoryGirl.create(:action_page, :name => page_name)
end

When /^I navigate back to the Action Sequence "([^"]*)"$/ do |action_sequence_name|
  steps(%Q(
    Given I am on the admin static pages page 
    Then I follow "#{action_sequence_name}"
  ))
end

When /^"([^"]*)" should no longer be listed as a action sequence$/ do |action_sequence_name|
  ActionSequence.find_by_name(action_sequence_name).should be_nil
end

When /^I should see language tabs for "([^"]*)"$/ do |language_names|
  language_names.split(",").map{|l| l.strip}.each do |expected_language|
    with_scope("\"#language_tabs\"") do
      page.should have_content expected_language
    end
  end
end
When /^I preview the petition page$/ do |page_name|
 page.find(:xpath,"//a[@id='preview']").click
 if find(:xpath,"//ul[@class='action_sequence_breadcrumb']//a").text== page_name
   assert("The page has been previewed")
 else
   click_link("Log Out")
 end
end
Then /^I check for errors$/ do
  sleep 2
  p page.has_xpath?("//ul[@class='module_errors error']")
 if page.has_xpath?("//ul[@class='module_errors error']")==true
   click_link("Log Out")
   assert("Page has been saved with errors")
 end

end

When /^I preview the petition page for (.+) page$/ do|module_name|
  find(:xpath,"//a[@id='preview']").click()
 # p find(:css,"//div[@id='page-en']//ul[@class='action_sequence_breadcrumb']/li/a")
 page.has_css?("ul.action_sequence_breadcrumb li a.current")
end

When /^I create a new unsubscribe page named "([^"]*)"$/ do |page_name|
  fill_in "action_page_name", :with => page_name
  click_link("Add a page")
end
