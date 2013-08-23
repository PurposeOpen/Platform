When /^I visit the page "([^"]*)"$/ do |url|
  visit(url)
end
When /^I sign the petition as (.+)$/ do|mail_id|
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
  click_button("Sign")
end
