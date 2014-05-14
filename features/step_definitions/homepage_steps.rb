Given /^I visit the "([^"]*)" homepage form$/ do |name|
  movement = Movement.find_by_name(name)
  movement.should_not be_nil
  visit admin_movement_homepages_path(movement)
end

When /^I visit the "([^"]*)" homepage for "([^"]*)"$/ do |homepage_name, language_name|
  movement = Movement.find_by_name(homepage_name)
  language = Language.find_by_name(language_name)
  visit edit_admin_movement_homepages_path(movement)
end

When /^I fill in the "(..)" homepage form with:$/ do |iso_code, table|
  page.click_on "homepage_#{iso_code}_link"
  table.hashes.each do |item|
    item.each do |field, value|
      fill_in("homepage_content_#{iso_code}_#{field}", with: value)
    end
  end
end