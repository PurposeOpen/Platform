When /^(?:|I )follow the "([^"]*)" breadcrumb$/ do |link|
  within(".breadcrumbs") do
    click_link(link)
  end
end