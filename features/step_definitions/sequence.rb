When /^I add a (.+) action sequence$/ do|sequence_name|
  sleep 1
  click_link("Add an action sequence")
  fill_in("action_sequence_name",with:sequence_name)
  click_button("Create action sequence")
  end
When /^I go back to the sequence (.+)$/ do |sequence_name|
  click_link(sequence_name)
end
When /^I enable languages (.+)$/ do|language|

  case language
    when /English/
      language_name='en'
    when /Indonesian/
      language_name='id'
    when /Tagalog/
      language_name='tl'
  end
  find(:xpath,"//div[@data-lang='"+language_name+"']/label").click
  sleep 2

end
When /^I publish the sequence$/ do
  element=find(:css,"div.toggle_wrapper label")
  element.click
  sleep 2
end
