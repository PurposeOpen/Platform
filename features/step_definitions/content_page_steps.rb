Given /^I am an admin for the movement "(.*)"$/ do |movement_name|
  movement = FactoryGirl.create(:movement, :name => movement_name, :languages => [FactoryGirl.create(:english), FactoryGirl.create(:portuguese)])
  movement.default_iso_code = "pt"
  movement.save!
end

Given /^the "([^\"]*)" movement has a content page collection called "([^\"]*)"$/ do |movement_name, collection_name|
  movement = Movement.find_by_name(movement_name)
  movement.content_page_collections << FactoryGirl.create(:content_page_collection, :name => collection_name, :movement => movement)
end

Given /^the "([^"]*)" content page collection contains a content page named "([^"]*)"$/ do |collection_name, page_name|
  collection = ContentPageCollection.find_by_name(collection_name)
  FactoryGirl.create(:content_page, :name => page_name, :content_page_collection => collection)
end

When /^I edit the content page "([^\"]*)"$/ do |content_page_name|
  login
  visit_edit_content_page content_page_name
end

When /^I create a new content page called "([^\"]*)" in the "([^\"]*)" collection$/ do |content_page_name, collection_name|
  login
  visit_content_pages collection_name

  new_content_page_link_for(collection_name).click
  step "I fill in \"Content Page Title\" with \"#{content_page_name}\""
  click_on "Create page"
end

And /^I add a new HTML module to the header container$/ do
  page.find("[data-layout-type='header_content'] .add-module-link.html_module").click
end

Then /^I should see that the "([^\"]*)" collection has a page called "([^\"]*)"$/ do |collection_name, content_page_name|
  visit_content_pages collection_name
  with_scope("\"[data-name='#{collection_name}']\"") do
    page.should have_content content_page_name
  end
end

Then /^I should see that the "([^\"]*)" collection does not have a page called "([^\"]*)"$/ do |collection_name, content_page_name|
  visit_content_pages collection_name
  with_scope("\"[data-name='#{collection_name}']\"") do
    page.should_not have_content content_page_name
  end
end

When /^I fill in the content of the HTML module on the header for "([^"]*)" with "([^"]*)"$/ do |language, html_module_content|
  page.click_on language
  textarea_id = page.find("[data-layout-type='header_content'] label")[:for]
  within_frame("#{textarea_id}_ifr") do
    page.find_by_id('tinymce').click
  end
  evaluate_script %Q{ tinyMCE.activeEditor.execCommand('mceInsertContent', false, '#{html_module_content}'); }
end

Then /^there should be an HTML module for each language on the header of the "([^"]*)" page$/ do |content_page_name|
  content_page = ContentPage.find_by_name(content_page_name)
  content_page.movement.languages.each do |language|
    page.click_on language.name
    page.find("[data-layout-type='header_content'] .content_module").should_not be_nil
  end
end

When /^there should be an HTML module with content "([^"]*)" on the header of the "([^"]*)" page in "([^"]*)"$/ do |html_module_content, content_page_name, language|
  page.click_on language
  textarea_id = page.find("[data-layout-type='header_content'] label")[:for]
  within_frame("#{textarea_id}_ifr") do
    page.find_by_id('tinymce').click
  end
  evaluate_script("tinyMCE.activeEditor.getContent();").should eql html_module_content
end

def login
  step "I am logged into the platform as a platform admin"
end

def visit_content_pages(content_pages_collection_name)
  visit admin_movement_content_pages_path(ContentPageCollection.find_by_name(content_pages_collection_name).movement)
end

def visit_edit_content_page(content_page_name)
  content_page = ContentPage.find_by_name(content_page_name)
  visit edit_admin_movement_content_page_path(content_page.content_page_collection.movement, content_page)
end

def new_content_page_link_for(collection_name)
  page.find(:css, "[data-name='#{collection_name}']").find(:css, "[rel='new_content_page']")
end