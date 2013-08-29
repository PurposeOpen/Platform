When /^I create a (.+) campaign$/ do |campaign_name|
  within("#navbar") do
    click_link("Campaigns")
  end
  click_link("Create new campaign")
  fill_in("campaign_name",:with =>campaign_name)
  fill_in("campaign_description",:with =>"Regression Test")
  click_button("Create campaign")
end

Then /^I check for the statistics table$/ do
  assert_equal(find(:xpath,"//div[@id='ask-stats']").present?,true)
end

When /^I check for TAF statistics table$/ do
  assert_equal(find(:xpath,"//div[@id='taf-stats']").present?,true)
end