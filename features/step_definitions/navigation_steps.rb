When /^(?:|I )navigate to "([^"]*)"$/ do |link|
  within("#navbar") do
    click_link(link)
  end
end