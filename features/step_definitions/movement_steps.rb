Given /^I have movements named "([^"]*)" with the languages "([^"]*)"$/ do |movement_names, language_names|
  movement_names.split(",").each { |name|
    movement = Movement.find_or_create_by_name(name)
    movement.update_attributes(:languages => Language.where(:name => language_names.split(",")), :url => "http://#{name}.com")  
  }
end

Given /^I have a movement named "([^\"]*)" with campaign "([^\"]*)"$/ do |movement_name, campaign_name|
  @movement = Movement.find_by_name(movement_name)
  @movement = Movement.create!(:name => movement_name, :languages => [FactoryGirl.create(:english)], :url => "http://#{movement_name}.com") if @movement.nil?
  MemberCountCalculator.init(@movement, 100)
  @campaign = Campaign.find_by_name(campaign_name)
  @campaign = Campaign.create!(:name => campaign_name, :movement => @movement) if @campaign.nil?
end

When /^I add "([^"]*)" to the list of selected languages$/ do |language|
  with_scope("\"li[title=#{language}]\"") do
    find("a").click
  end
end

When /^I remove "([^"]*)" from the list of selected languages$/ do |language|
  with_scope("\"li[title=#{language}]\"") do
    find("a").click
  end
end

When /^I save the movement$/ do
  click_button("Save Movement")
end

Then /^I should not be able to remove any of the selected languages$/ do
  all("#languages-container ul.selected a").size.should eql 0
end

When /^I should see "([^"]*)" as options for the default language$/ do |language_names|
  with_scope('"select#movement_default_language"') do
    selected_language_names = all("option").map(&:text)
    selected_language_names.should eql language_names.split(",")
  end
end

When /^I choose "([^"]*)" as the default language$/ do |default_language_name|
  select(default_language_name, :from => "movement_default_language")
end

When /^the default language for "([^"]*)" is "([^"]*)"$/ do |movement_name, default_language_name|
  movement = Movement.find_by_name(movement_name)
  movement.default_language = Language.find_by_name(default_language_name)
end

When /^I visit the "([^"]*)" movement page$/ do |movement_name|
  movement = Movement.find_by_name(movement_name)
  visit admin_movement_path(movement)
end
When /^I enter the url as (.+)$/ do|url_name|
  fill_in("movement_url",:with=>url_name)
  sleep 2
end

When /^I create a (.+) movement$/ do |movement_name|
  click_link("New movement")
  sleep 2
  fill_in("movement_name",:with=>'movement_name')
end

When /^I add the language (.+)$/ do |language|
  find(:css,"ul.available li[title='"+language+"'] a.action span") .click
end
When /^I select the default language as (.+)$/ do |default_language|
  find(:css,"select[id=movement_default_language]").select(default_language)
  sleep 10
end
Then /^I check for the movement (.+) and select it$/ do|movement_name|
  movement_link=find(:xpath,"//div[@id='application']//h2//a[text()='"+movement_name+"']")
  page.has_xpath?("//div[@id='application']//h2//a[text()='"+movement_name+"']")
  movement_link.click
end
Then /^I check if I am logged into the platform$/ do
 assert_equal(find(:xpath,"//a[text()='Log Out']").present?,true)
 sleep 60
end
Then /^I check if I am on the movement home page for (.+)$/ do|movement_name|
  breadcrumbs=page.find(:xpath,"//div[@class='breadcrumbs']").text
  breadcrumbs.should have_content(movement_name)
end
Then /^I check for (.+) button$/ do |button_name|
  assert_equal(find(:xpath,"//a[text()='"+button_name+"']").present?,true)
end
When /^I navigate to the (.+) movement$/ do|movement_name|
  find(:xpath,"//i[@class='icon icon-chevron-down']").click()
  find(:xpath,"//li[@class='ui-menu-item']/a[text()='"+movement_name+"']").click

end
Given /^I am in "([^"]*)" homepage$/ do |movement_name|
  movement_slug = movement_name.gsub(" ","-").downcase
  visit ("/admin/movements/#{movement_slug}")
end

When /^then I go to "([^"]*)" homepage$/ do |movement_name|
  movement_slug = movement_name.gsub(" ","-").downcase
  visit ("/admin/movements/#{movement_slug}")
end