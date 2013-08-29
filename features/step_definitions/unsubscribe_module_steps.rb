When /^I enter details required for creating the  Unsubscribe page (.+)$/ do|page_name|
  click_link(page_name)
  fill_in("Button text",:with => "Unsubscribe")
  page.find(:css,"div[data-layout-type='header_content'] ul.add_module_buttons a.html_module").click
  sleep 5
  page.execute_script('$("div.modules_container span.mceEditor iframe")[0].contentDocument.documentElement.innerHTML="<html>This is header content</html>"')
  page.find(:css,"div[data-layout-type='main_content'] ul.add_module_buttons a.html_module").click
  sleep 5
  page.execute_script('$("div.modules_container span.mceEditor iframe")[1].contentDocument.documentElement.innerHTML="<html>This is main content</html>"')
  click_button "Save page"
  sleep 5
end

When /^I Unsubscribe (.+) from the movement$/ do|email_id|
  fill_in("member_info_email",:with=>email_id)
  click_button("Unsubscribe Button")
end

When /^I enter button name as(.+)$/ do |button_name|
  fill_in("Button text",:with => button_name)
end

# p page.has_css? ("div[data-layout-type='sidebar'] input")
  # element = find(:css,"div[data-layout-type='sidebar'] input:last")
 # p element
  #p element.methods
