When /^I enter the details required for creating the petition page (.+)$/ do |petition_name|
  click_link(petition_name)
  page.find(:css,"div[data-layout-type='header_content'] ul.add_module_buttons a.html_module").click
  sleep 2
  page.execute_script('$("div.modules_container span.mceEditor iframe")[0].contentDocument.documentElement.innerHTML="<html>This is header content</html>"')
  page.find(:css,"div[data-layout-type='main_content'] ul.add_module_buttons a.html_module").click
  sleep 2
  page.execute_script('$("div.modules_container span.mceEditor iframe")[1].contentDocument.documentElement.innerHTML="<html>This is main content</html>"')
  element=page.all(:css,"div.module_body input")
  element[2].set("Regression Title")
  page.execute_script('$("div.modules_container span.mceEditor iframe")[2].contentDocument.documentElement.innerHTML="<html>This is petition statement</html>"')
  element[4].set("10")
  element[5].set("1")
  sleep 2
end
