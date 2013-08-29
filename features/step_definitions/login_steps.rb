
When /^I log in as (.+),(.+) to Platform$/ do |role,password|
  fill_in("platform_user_email", :with => role )
  fill_in("platform_user_password", :with => password )
  click_button "Sign in"
end
And /^I select the movement(.+)$/ do|movement_name|
  sleep 5
  #if  page.should have_css('h2', :text => movement_name)
    #click_link (movement_name)
 #end
  movement_link=find(:xpath,"//div[@id='application']//h2//a[text()='"+movement_name+"']")
  movement_link.click
end
When /^I search for Campaign (.+)$/ do|campaign_name|
  fill_in("query", :with => campaign_name )
  #click_button("Search")
end
When /^I select the Campaign (.+) from results$/ do |campaign_name|
  click_link (campaign_name)
end

When /^I create a new page action with (.+) named (.+)$/ do |module_type,module_name|
  click_link("Add a page")
  fill_in "action_page_name", :with => module_name

 case module_type
   when "Unsubscribe"
    button= "action_page_seeded_module_unsubscribe_module"
 when "Petition"
    button ="action_page_seeded_module_petition_module"
   when "Tell A Friend"
    button="action_page_seeded_module_tell_a_friend_module"
   when "Donation 501(c)3"
    button="action_page_seeded_module_tax_deductible_donation_module"
   when "Donation 501(c)4"
     button="action_page_seeded_module_non_tax_deductible_donation_module"
   when "Join"
     button="action_page_seeded_module_join_module"
 end
  choose(button)
  click_button("Create page")
end
When /^I goto action Page  (.+)$/ do|page_name|
  click_link(page_name)
  sleep 25
end
When /^I add HTML for Header content$/ do
#  page.all(:css,"ul.add_module_buttons")[1].click
  page.find(:css,"div[data-layout-type='header_content'] ul.add_module_buttons a.html_module").click
  sleep 10
end
When /^I enter my information for the header content as (.+)$/ do|header_text|

#page.execute_script('$("#foo_description_raw").tinymce().setContent("Pants are pretty sweet.")')
page.execute_script('$("div.modules_container span.mceEditor iframe")[0].contentDocument.documentElement.innerHTML="<html>'+ header_text+'</html>"')

end
When /^I add HTML for Main content$/ do
  page.find(:css,"div[data-layout-type='main_content'] ul.add_module_buttons a.html_module").click
  sleep 10
end
When /^I Save Page$/ do
  click_button "Save page"
  sleep 5
end
When /^I check if am on the sequence page$/ do
  assert page.should have_content("Edit sequence")
end
When /^I check if I am on campaigns page$/ do
  assert page.should have_content("Edit sequence")
end
When /^I goto the (.+) sequence$/ do|sequence_name|
  click_link (sequence_name)
end
When /^I enter my information for the Main content as (.+)$/ do|main_text|
  page.execute_script('$("div.modules_container span.mceEditor iframe")[1].contentDocument.documentElement.innerHTML="<html>'+ main_text+'</html>"')
end

When /^I delete the action page (.+)$/ do|page_name|
  click_link("Delete page")
  click_button("Yes")
end
