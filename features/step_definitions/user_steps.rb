Given /^a user "([^"]*)" "([^"]*)" with (.*)$/ do |first_name, last_name, details|
  user_params = {:first_name => first_name, :last_name => last_name}
  details.split(" and ").each do |field_and_value|
    match_data = /(.*) "(.*)"/.match(field_and_value)
    field, value = *match_data.captures
    user_params[field] = value
  end
  FactoryGirl.create(:user, user_params.merge(:password => "password"))
end

Given /^a "([^"]*)" with email "(.*)"$/ do |role, email|
  case role
  when /admin/ then 
    FactoryGirl.create(:platform_user, {:first_name => "Some", :last_name => "User", :email => email, :is_admin => true, :password => "password"})
  when /campaigner/ then
    user = FactoryGirl.create(:platform_user, {:first_name => "Some", :last_name => "User", :email => email, :is_admin => false, :password => "password"})
    movement = Movement.create!(:name => "Some movement", :languages => [FactoryGirl.create(:english)], :url => "http://some-movement.com")
    UserAffiliation.create!(:movement_id => movement.id, :user_id => user.id, :role => "campaigner")
  when /volunteer/ then
    FactoryGirl.create(:user, {:first_name => "Some", :last_name => "User", :email => email, :is_volunteer => true, :password => "password"})
  else
    FactoryGirl.create(:user, {:first_name => "Some", :last_name => "User", :email => email, :is_admin => false, :password => "password"})
  end
end

Given /a user ([A-Z][a-z]+) ([A-Z][a-z]+) with email ([a-z]+@[a-z.]+)$/ do |first, last, email|
  FactoryGirl.create(:user, :first_name => first, :last_name => last, :email => email).save
end

Then /^the user "([^"]*)" should be subscribed$/ do |email|
  u = User.find_by_email(email)
  u.should_not be_nil
  u.is_member.should be_true
end

Then /^the user "([^"]*)" should be unsubscribed$/ do |email|
  u = User.find_by_email(email)
  u.should_not be_nil
  u.is_member.should be_false
end

Given /^I am logged into the platform as a platform admin$/ do
  unless page.body.include? "Log Out"
    credentials = {:email => "theadminuser@yourdomain.org", :password => "password"}
    visit new_platform_user_session_path
    user = PlatformUser.find_by_email(credentials[:email])

    if user.nil?
      user = FactoryGirl.create(:admin_platform_user, :email => credentials[:email],
                                :first_name => "Admin", :last_name => "User",
                                :password => credentials[:password])
    end

    fill_in("Email", :with => user.email )
    fill_in("Password", :with => user.password )
    click_button("Sign in")
  end
end

Given /^"([^"]*)" is logged into the platform as a platform user$/ do |email|
  visit new_platform_user_session_path
  user = PlatformUser.find_by_email(email) || FactoryGirl.create(:platform_user, :email => email, :first_name => "Normal", :last_name => "User", :password => "password") unless PlatformUser.find_by_email("theadminuser@yourdomain.org")
  fill_in("Email", :with => user.email )
  fill_in("Password", :with => "password" )
  click_button("Sign in")
end

Given /^I am logged in as (a|an) ([^"]*)$/ do |_, role|
  visit new_platform_user_session_path
  user = FactoryGirl.create(:platform_user, :email => "theadminuser@yourdomain.org", :first_name => "Admin", :last_name => "User", :is_admin => (role == 'admin'), :password => "password") unless PlatformUser.find_by_email("theadminuser@yourdomain.org")
  fill_in("Email", :with => user.email )
  fill_in("Password", :with => "password" )
  click_button("Sign in")
end

When /^I am logged in as (a platform admin|a non-admin) "([^"]*)" with the following roles:$/ do |is_admin, user_email, table|
  user = PlatformUser.find_by_email(user_email) || FactoryGirl.create(:platform_user, :email => user_email, :first_name => "Normal", :last_name => "User", :password => "password") unless PlatformUser.find_by_email("theadminuser@yourdomain.org")
  table.hashes.each do |item|
    movement = Movement.find_or_create_by_name(item['movement'])
    user.is_admin = (is_admin == 'a platform admin')
    UserAffiliation.create!(:movement_id => movement.id, :user_id => user.id, :role => item['role'])
  end
  visit new_platform_user_session_path
  fill_in("Email", :with => user.email )
  fill_in("Password", :with => "password" )
  click_button("Sign in")
end

When /^I am logged in as (.*) with "([^"]*)" on movement "([^"]*)"$/ do |role, user_email, movement_name|
  step "\"#{user_email}\" is logged into the platform as a platform user"
  movement = Movement.find_or_create_by_name(movement_name)
  user = PlatformUser.find_by_email(user_email)
  user.is_admin = (role == 'admin')
  UserAffiliation.create!(:movement_id => movement.id, :user_id => user.id, :role => role)
end

Then /^I fill in "([^"]*)" with the member id of "([^"]*)"$/ do |query_field, member_email|
  user = User.find_by_email member_email
  fill_in(query_field, :with => user.id)
end

#TODO #223 - Refactor after the member/platform user split is done
Then /^I fill in "([^"]*)" with the platform user id of "([^"]*)"$/ do |query_field, member_email|
  user = PlatformUser.find_by_email member_email
  fill_in(query_field, :with => user.id)
end

#TODO #223 - Refactor after the member/platform user split is done
Then /^I should see details for the platform user "([^"]*)"$/ do |member_email|
  user = PlatformUser.find_by_email(member_email)
  text = "#{user.name}"
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end


Then /^I should see details for "([^"]*)"$/ do |member_email|
  user = User.find_by_email(member_email)
  text = "ID: #{user.id}"
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Given /^the following users exist:$/ do |table|
  table.hashes.each do |row|
    step %{a "#{row['Role']}" with email "#{row['Email']}"}
  end
end

Given /^I am logged in as "([^"]*)"$/ do |email|
  visit new_platform_user_session_path
  fill_in("Email", :with => email )
  fill_in("Password", :with => "password" )
  click_button("Sign in")
end

Given /^I am not logged in$/ do
  visit destroy_user_session_path
end

Given /^user "([^"]*)" has a weekly recurring donation for "([^"]*)" dollars$/ do |user_email, donation_amount|
  user = User.find_by_email(user_email)
  donation = FactoryGirl.create(:donation, :user => user)
  donation.amount_in_dollars = donation_amount
  donation.frequency = "weekly"
  donation.save
end

When /^I save the user$/ do
  click_button("Save")
end

When /^I (assign|revoke) Platform Administrator rights for user$/ do |action|
  if action == 'assign'
    check('Platform Administrator')
  else
    uncheck('Platform Administrator')
  end
end

When /^"([^"]*)" is a Platform Admin$/ do |user_email|
  user = PlatformUser.find_by_email(user_email)
  user.update_attribute(:is_admin, true)
end

Then /^"([^"]*)" (should|should not) be a Platform Administrator$/ do |user_email, be_admin|
  step "I am on the edit admin user page for \"#{user_email}\""
  if be_admin == 'should'
    find("#user_is_admin").checked?.should be_true
  else
    find("#user_is_admin").checked?.should be_false
  end
end

Then /^I should see an access denied page$/ do
  page.should have_content('Not authorised!')
  page.status_code.should == 401
end

Then /^I should see a not found page$/ do
  page.should have_content('Not found')
  page.status_code.should == 404
end

Then /^I should see "([^"]*)" as available movements$/ do |movement_names|
  page.find('.movement.menu').click

  within('#movements-container') do
    movement_names.split(",").each do |name|
      should have_content(name)
    end
  end
end

When /^I select the following roles:$/ do |table|
  table.hashes.each do |item|
    select(item['role'], :from => item['movement'])
  end
end

Then /^the user "([^"]*)" should have the following roles:$/ do |email, table|
  user = PlatformUser.find_by_email(email)
  table.hashes.each do |item|
    movement = Movement.find_by_name(item['movement'])
    user.movements.where(:id => movement.id, :user_affiliations => {:role => item['role'].downcase}).size.should eql 1
  end
end

Then /^all user details fields are disabled$/ do
  within('#edit_user') do
    page.all('input, select, checkbox').each do |e|
      e['disabled'].should eql 'true'
    end
  end
end

When /^"([^"]*)" is a movement administrator for "([^"]*)"$/ do |user_email, movement_name|
  user = PlatformUser.find_by_email(user_email)
  movement = Movement.find_by_name(movement_name)
  UserAffiliation.create!(:movement_id => movement.id, :user_id => user.id, :role => UserAffiliation::ADMIN)
end