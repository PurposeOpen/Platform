def tracking_data(email_address, email_name)
  user = User.find_by_email(email_address)
  user.should_not be_nil
  email = Email.find_by_name(email_name)
  email.should_not be_nil
  t = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")  
end

Then /^show me the last email for "([^"]*)"$/ do|address|
  open_email(address)
  y current_email.header.inspect
  y current_email.default_part_body.inspect
end

Given /^I visit the admin push page for "([^"]*)"$/ do |name|
  push = Push.find_by_name(name)
  push.should_not be_nil
  visit admin_movement_push_path(push.campaign.movement, push)
end

When /^"([^"]*)" opens the email "([^"]*)"$/ do |email_address, email_name|
  t = tracking_data(email_address, email_name)
  visit "/api/movements/dummy-movement/email_tracking/email_opened?t=#{t}"
end

When /^"([^"]*)" visits the "([^"]*)" page from the email "([^"]*)"$/ do |email_address, page_name, email_name|  
  page = ActionPage.find_by_name(page_name)
  page.should_not be_nil
  t = tracking_data(email_address, email_name)
  post "/api/movements/dummy-movement/email_tracking/email_clicked?t=#{t}", { :page_id => page.id }
end

When /^"([^"]*)" visits the unsubscribe me page from the email "([^"]*)"$/ do |email_address, email_name|  
  t = tracking_data(email_address, email_name)
  visit unsubscribe_path(:t => t)
end

Then /^I should see the following statistics for the email "([^"]*)":$/ do |email_name, stats|
  email = Email.find_by_name(email_name)
  email.should_not be_nil

  column_offset = 3
  ths = page.all(:css, 'table.email-statistics thead th')
  table_row = "//td[text()=\"#{email_name}\"]/.."
  tds = []
  within(:xpath, table_row) { page.all(:css, 'td').each {|element| tds << element} }

  stats.hashes.first.each_with_index do |(header, value), index|
    position = index + column_offset

    th = ths[position].text
    td = tds[position].text

    [th, td].should == [header, value]
  end
end


# stub job processing visibility for view purposes
When /^blasts are queued for delivery indefinitely$/ do
  Email.class_eval do
    alias_method :old_delayed_job_id, :delayed_job_id
    def delayed_job_id
      999
    end
  end

  Blast.class_eval do
    alias_method :old_has_pending_jobs?, :has_pending_jobs?
    def has_pending_jobs?
      true
    end
  end
end

When /^blasts are processed again$/ do
  Email.class_eval do
    alias_method :delayed_job_id, :old_delayed_job_id
    remove_method :old_delayed_job_id
  end

  Blast.class_eval do
    alias_method :has_pending_jobs?, :old_has_pending_jobs?
    remove_method :old_has_pending_jobs?
  end
end

When /^I refresh the push stats aggregation table$/ do
  UniqueActivityByEmail.update!
end