When /^I add create a (.+) push$/ do |push_name|
  click_link("Add a push")
  fill_in("push_name",:with=>push_name)
  click_button("Create push")
end
When /^I add a (.+) blast$/ do |blast_name|
  click_link("Add a blast")
  fill_in("blast_name",:with=>blast_name)
  click_button("Create blast")
  sleep 2
end
When /^I add new email (.+) to the blast$/ do|email_name|
  #page.execute_script('$("ul.actions li span.button").trigger("mouseenter")')
 # p page.driver.methods
  #p page.methods
  #p page.driver.browser.methods
  #p page.driver.browser.action.methods
  #p page.driver.browser.mouse.methods
  #mouse_over_element = page.driver.browser.find_element(:css => "ul.actions li span.button")
  #p mouse_over_element
  #page.driver.browser.action.move_to(mouse_over_element).perform()
  #sleep 5
  #find(:css,"ul.actions li span.button")
  #sleep 5
  #p find(:css,"ul.actions li span.button").methods
  #p find(:xpath,"//ul[@class='actions']/li[2]//a")
  #find(:xpath,"//ul[@class='actions']/li[2]").native.click
  #email_create = page.driver.browser.find_element(:css => "ul.actions li ul li a")
  #p email_create

  #p email_create.size()
  #p email_create[1]
  #p email_create[1].methods
  #email_create.click()
  page.execute_script('$("ul.actions li ul li a")[0].click()')
  sleep 2
  fill_in("email_name",:with=>email_name)
end

When /^I enter the details of the email$/ do
  fill_in("email_from",:with=>"noreply@yourdomain.com")
  fill_in("email_reply_to",:with=>"noreply@yourdomain.com")
  fill_in("email_subject",:with=>"Test Email")
  page.execute_script('$("iframe")[0].contentDocument.documentElement.innerHTML="<html>This is creating a new test blast email</html>"')
  sleep 5
  click_button("Save")
  sleep 10
end

When /^(?:|I )write in "([^"]*)" with "([^"]*)"$/ do |field, value|
  page.execute_script('$("iframe")[0].contentDocument.documentElement.innerHTML="<html>#{value}</html>"')
end

Then /^I goto the push (.+)$/ do|push_name|
  click_link(push_name)
end

When /^I Save push$/ do
  find(:xpath)
end

When /^I enter the new name as (.+) for the same push$/ do |push_name|
  fill_in("push_name",:with=>push_name)
end

When /I expand Add an Email to click New Email/ do
  page.execute_script('$("ul.actions li ul li a")[0].click()')
  sleep 2
end

Then /^I check for the changed push name (.+)$/ do|push_name|
  #sleep 30
  push = Push.find_by_name(push_name)
  element=page.all(:css,"div.push a")
    assert_equal(element[0].present?,true)
end
When /^I press Rename$/ do

  link=page.all(:css,"div.push a")
   rename=find(:css,"div.push a.right")
  p rename
  #p link[1]
  #link[1].click
  rename.click()
  sleep 20
end
When /^I press Save Push button$/ do
  click_button("Save push")
end
When /^I check for Add an email$/ do
  find(:xpath,"//ul[@class='actions']/li/span[@class='button']").should have_content("Add an email")
end