And /^I click "([^\"]*)"$/ do |selector|
  find(selector).click
end

When /^I select "([^\"]*)" as the "(\d*).{2}" filter type$/ do |value, position|
  find(:xpath, "//fieldset/ul/li[#{position}]/span/select").select(value)
end
When /^I select recipients$/ do
  find(:css,"ul.actions li a").click
end
When /^I select Country by (.+)$/ do|selected_by|
  filter = find(:css, "div.list-filter")
  within(filter) do
    find(:css,"div.list-cutter-filter-type select").select("Country")
  end
  sleep 2
  within(filter) do
    find(:css,"div.rule-details select.selected_by").select(selected_by)
  end
end
When /^I select Country Name as (.+)$/ do|country_name|
  filter_details = find(:css, "div.rule-details")
  within(filter_details) do
    find(:css, ".filter-negate").select("is")
  end
  find(:css,"button.ui-multiselectcheckbox").click
  find(:css,"div.ui-multiselectcheckbox-filter input").set(country_name)
  find(:css,"a.ui-multiselectcheckbox-all span")[0].click
end
When /^I check the member count$/ do
  click_button("Show count")
end
When /^I check if the count is (.+)$/ do|count|
   sleep 1
  count_flag=find(:css,"div.list-cutter-result p").text.should have_content(count)
  assert_equal(count_flag,true,"The member count matches the ecpected count")
end
When /^I save count and go to blast$/ do
  click_button("Save List")
  click_link("Back")
end
When /^I select the Member Activity (.+) (.+) than (.+)$/ do|option1,option2,count|
  find(:css,"div.list-cutter-filter-type select").select("Member Activity")
  sleep 2
  find(:css,"div.rule-negate select").select(option1)
   case option2
     when /greater/
       find(:css,"div.rule-details select").("More Than")
     when /lesser/
       find(:css,"div.rule-details select").("Less Than")
     when/equal/
       find(:css,"div.rule-details select").("Equal to")
   end
   fill_in("rules_member_activity_rule_4_activity_count",:with=>count)

end
When /^I select (.+) module$/ do|module_name|
  find(:css,"button.ui-multiselectcheckbox").click
  find(:css,"div.ui-multiselectcheckbox-filter input").set(module_name)
  find(:css,"a.ui-multiselectcheckbox-all span").click
end

Then /^I should see Join Date is before today/ do
  target_date = Date.today.strftime("%m/%d/%Y")
  text_to_search = "Join Date is before #{target_date}"
  if page.respond_to? :should
    page.should have_content(text_to_search)
  else
    assert page.has_content?(text_to_search)
  end

end
Given /^I select Domain$/ do
  find(:css,"div.list-cutter-filter-type select").select("Domain")
end