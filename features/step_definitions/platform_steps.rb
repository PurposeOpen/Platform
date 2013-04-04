# encoding: utf-8

Then /^I should not be able to set the platform admin role$/ do
  within('#edit_user') do
    page.find('#user_is_admin')['disabled'].should eql 'disabled'
  end
end

Then /^I should only see "([^"]*)" as navigation links$/ do |list_of_links|
  expected_links = list_of_links.split(",").map(&:strip)
  rendered_links = []

  all("#navbar li a").each do |a|
    rendered_links << a.text
  end
  rendered_links.should =~ expected_links
end

When /^I visit the health check dashboard for the movement "([^"]*)"$/ do |movement_name|
  movement = Movement.find_by_name movement_name
  visit awesomeness_dashboard_path(movement)
end

Then /^I should see the following services statuses$/ do |table|
  within("div#service-statuses ul") do
    table.hashes.each_with_index do |row, idx|
      find(".#{row["service"]}").text.should =~ /#{row["status"]}/
    end
  end
end

Then /^I should be able to view (.+)$/ do |page_name|
  visit path_to(page_name)
  page.should_not have_content("Access Denied")
end

Then /^I should not be able to view (.+)$/ do |page_name|
  visit path_to(page_name)
  page.should have_content("Access Denied")
end

Then /^the breadcrumbs should match "([^"]*)"$/ do |breadcrumbs|
  expected = breadcrumbs.split(",").map{ |c| c.strip }.join(" » ")
  find(".breadcrumbs").text.strip.should eql expected
end


When /^I should see (.*) links$/ do |menu_items|
  expected_links = menu_items.split(",")
  expected_links.each do |each_link|
    page.should have_content(each_link)
  end
end

