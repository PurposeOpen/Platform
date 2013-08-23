When /^(?:|I )follow "([^"]*)" for the HTML module "([^"]*)"/ do |link, name|
  htmlmodule = HtmlModule.find_by_content(name)
  htmlmodule.should_not be_nil
  selector = "\"#content_module_#{htmlmodule.id}\""
  with_scope(selector) do
    click_link(link)
  end
end

When /^(?:|I )follow "([^"]*)" for the Accordion module "([^"]*)"/ do |link, name|
  accordion_module = AccordionModule.find_by_content(name)
  accordion_module.should_not be_nil
  selector = "#content_module_#{accordion_module.id}"
  with_scope(selector) do
    click_link(link)
  end
end

When /^(?:|I )follow "([^"]*)" for the module "([^"]*)" and click "([^"]*)"$/ do |link, name, action|
  htmlmodule = HtmlModule.find_by_content(name)
  htmlmodule.should_not be_nil
  selector = "\"#content_module_#{htmlmodule.id}\""
  with_scope(selector) do
    prepare_dialog_box(action)
    click_link(link)
  end
end

Then /^(?:|I )should see "([^"]*)" inside the container "([^"]*)"/ do |content, container|
  layout_selector = "\"##{container.downcase.gsub(" ", "_")}\""
  with_scope(layout_selector) do
    if page.respond_to? :should
      page.should have_content(content)
    else
      assert page.has_content?(content)
    end
  end
end

When /^I follow "([^"]*)" inside the container "([^"]*)"$/ do |link, container|
  layout_selector = "#{container.downcase.gsub(" ", "_")}"
  container = find(:xpath,"//div[@data-layout-type='#{layout_selector}']")
  container.click_link(link)
end

Then /^"([^"]*)" should be selected for "([^"]*)"$/ do |value, field|
  field_labeled(field).text.should =~ /#{value}/
end

Then /^I should see "([^"]*)" as a jurisdiction$/ do |jurisdiction|
  find("#jurisdiction-select option[selected]").text.should eql jurisdiction
end

Then /^I should see "([^"]*)" as a party option$/ do |list_of_parties|
  with_scope("\"#parties\"") do
    list_of_parties.split(",").each do |party|
      page.should have_content(party)
    end
  end
end

Then /^I should see "([^"]*)" as a role option$/ do |list_of_roles|
  with_scope("\"#user_affiliation_role\"") do
    list_of_roles.split(",").each do |role|
      page.should have_content(role)
    end
  end
end

Then /^I should see "([^"]*)" as a check option and it should be selected$/ do  |args|
  find("#target-senate input[type=checkbox]")[:checked].should eql "true"
end

When /^I fill the added html module with some content$/ do
  page.execute_script('$("div.modules_container span.mceEditor iframe")[0].contentDocument.documentElement.innerHTML="<html>some content</html>"')
  sleep 2
end
