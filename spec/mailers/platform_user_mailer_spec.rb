require "spec_helper"

describe PlatformUserMailer do
  it 'should send subscription confirmation email' do
    platform_user = FactoryGirl.create(:platform_user, first_name:"Leo", last_name: "Borges")

    ActionMailer::Base.deliveries.size.should eql(1)
    @delivered = ActionMailer::Base.deliveries.last
    @delivered.parts.length.should be(2)

    @delivered.parts[0].should have_body_text(/#{platform_user.full_name}/)
    @delivered.parts[0].should have_body_text(/Your Name Movement Management Platform/)
    @delivered.parts[0].should have_body_text(/platform_users\/password\/new/)
    @delivered.parts[1].should have_body_text(/#{platform_user.full_name}/)
    @delivered.parts[1].should have_body_text(/Your Name Movement Management Platform/)
    @delivered.parts[1].should have_body_text(/platform_users\/password\/new/)

    @delivered.should have_subject(/Your Name Movement Management Platform!/)
    @delivered.should deliver_to(platform_user.email)
  end

end 