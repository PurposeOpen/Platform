When /^I enter details for creating a donation module (.+)$/ do|module_name|
  click_link(module_name)
  element=page.all(:css,"div.module_body input")
  element[2].set("Regression Title")
  element[4].set("10")
  #find(:css,"")
  page.find(:css,"div[data-layout-type='header_content'] ul.add_module_buttons a.html_module").click
  sleep 2
  page.execute_script('$("div.modules_container span.mceEditor iframe")[0].contentDocument.documentElement.innerHTML="<html>This is header content</html>"')
  page.find(:css,"div[data-layout-type='main_content'] ul.add_module_buttons a.html_module").click
  sleep 2
  page.execute_script('$("div.modules_container span.mceEditor iframe")[1].contentDocument.documentElement.innerHTML="<html>This is main content</html>"')
end
When /^I choose the currency as (.+)$/ do |currency|
  sleep 2
  drop_down=page.all(:css,"div.module_body select")
  drop_down[0].click
  sleep 2
  drop_down[0].select(currency)
  sleep 2
end
When /^I choose the default amount as (.+)$/ do |amount|
  find(:xpath,"//fieldset[@id='currencies']/details/summary[text()='"+amount+"']").click
  sleep 2
  case amount
    when /EUR - Euro/
      $suggested_amount='eur'
    when /AUD - Australian Dollar/
      $suggested_amount='aud'
    when /CAD - Canadian Dollar/
      $suggested_amount='cad'
    when /GBP - British Pound/
      $suggested_amount='gbp'
    when /JPY - Japanese Yen/
      $suggested_amount='jpy'
    when /USD - United States Dollar/
      $suggested_amount='jpy'
  end
end
When /^I enter the suggested amounts as (.+)$/ do |value|
  content_modules = page.all(:css, "#language_tabs .tab_content:not(.ui-tabs-hide) .content_module")
  donation_modules = content_modules.select {|content_module| content_module.all(:css, "fieldset#currencies").size > 0 }
  content_module_id = donation_modules.first["data-id"]
  page.execute_script("$('#content_modules_#{content_module_id}_suggested_amounts_"+$suggested_amount+"_tag').val("+value+")")
  sleep 2
  find(:css, "#content_modules_#{content_module_id}_suggested_amounts_"+$suggested_amount+"_tag").native.send_keys(:return)
  sleep 2
end
When /^I select the default amount as (.+)$/ do|amount|
  choose(amount)
  sleep 2
  p find(:xpath,"//div[@class='buttonbar']/input[@value='Save page']")
   find(:xpath,"//div[@class='buttonbar']/input[@value='Save page']").click
  #click_button "Save page"
  sleep 2
end
