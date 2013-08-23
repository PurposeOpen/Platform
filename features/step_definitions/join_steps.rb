When /^I enter details for creating a join module (.+)$/ do|module_name|
  click_link(module_name)
  page.find(:css,"div[data-layout-type='header_content'] ul.add_module_buttons a.html_module").click
  sleep 2
  page.execute_script('$("div.modules_container span.mceEditor iframe")[0].contentDocument.documentElement.innerHTML="<html>This is header content</html>"')
  page.find(:css,"div[data-layout-type='main_content'] ul.add_module_buttons a.html_module").click
  sleep 2
  page.execute_script('$("div.modules_container span.mceEditor iframe")[1].contentDocument.documentElement.innerHTML="<html>This is main content</html>"')
  element=page.all(:css,"div.module_body input")
  element[2].set("Join Title")
  page.execute_script('$("div.modules_container span.mceEditor iframe")[2].contentDocument.documentElement.innerHTML="<html>This is join statement</html>"')
  sleep 2
  click_button "Save page"
  sleep 2
end
When /^I sign the join as (.+)$/ do|mail_id|
  sleep 2
  fill_in("member_info_email",:with=> mail_id)
  sleep 2
  fill_in("member_info_first_name",:with=>"First Name")
  fill_in("member_info_last_name",:with=>"Last Name")
  p find(:css,"a.selectBox").methods
  find(:css,"a.selectBox").click
  sleep 2
  find(:css,"a.selectBox").set("Afghanistan")
  sleep 2
  click_button("Join")
end
When /^I filter Join Date by (.+)$/ do |selected_by|
  find(:css,"div.list-cutter-filter-type select").select("Join Date")
  filter_date=find(:css,"div.rule-details select")
  sleep 2
  filter_date.select(selected_by)
  sleep 2
end
When /^I select (.+) date$/ do|date|
  case date
    when "today's"
      date_today=Date.today
      date_today=date_today.strftime('%m/%d/%Y')
      fill_in("rules_join_date_rule_0_join_date",:with=>date_today)
    when "yesterday's"
      date_yesterday=Date.yesterday
      date_yesterday=date_yesterday.strftime('%m/%d/%Y')
      fill_in("rules_join_date_rule_0_join_date",:with=>date_yesterday)
    when "earlier"
      date_earlier= "12/01/2012"
      #date_earlier=date_today

      #date_earlier=date_today.strftime('%m/%d/%Y')
      fill_in("rules_join_date_rule_0_join_date",:with=>date_earlier)
  end

end
