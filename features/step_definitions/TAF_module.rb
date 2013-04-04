When /^I enter details required for creating the TAF page (.+)$/ do|module_name|
 # click_link(module_name)

  sleep 10
  text_element=page.all(:css,"div.module_body textarea")
  element= page.all(:css,"div.module_body input")
  element[0].set("www.testurl.com")
  element[1].set("Test Headline")
  element[5].set("ImageURL")
  element[10].set("Email Subject")
  text_element[0].set("Test Message")
  text_element[2].set("Test Tweet")
  text_element[3].set("Email Body")
  page.find(:css,"div[data-layout-type='header_content'] ul.add_module_buttons a.html_module").click
  sleep 1
  page.execute_script('$("div.modules_container span.mceEditor iframe")[0].contentDocument.documentElement.innerHTML="<html>This is header content</html>"')
  sleep 1
  page.find(:css,"div[data-layout-type='main_content'] ul.add_module_buttons a.html_module").click
  sleep 1
  page.execute_script('$("div.modules_container span.mceEditor iframe")[1].contentDocument.documentElement.innerHTML="<html>This is main content</html>"')
  sleep 1
  element[5].set("ImageURL")
  click_button "Save page"
  sleep 5
end

When /^I check for the share options$/ do
  p page.has_xpath?("//div[@id='fb_share_button']")
  assert(page.has_xpath?("//div[@id='fb_share_button']"),"true")
  assert(page.has_xpath?("//div[@id='twitter_share_button_holder']"),"true")
  assert(page.has_xpath?("//div[@id='email_share_button_end']"),"true")
end
Then /^I go select (.+)$/ do |page_name|
  click_link(page_name)
end