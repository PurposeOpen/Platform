require 'spec_helper'

describe PaymentMailer do
  let(:english) { create(:english) }
  let(:campaign) { create(:campaign, :movement => movement) }
  let(:action_sequence) { create(:published_action_sequence, :campaign => campaign, :enabled_languages => [english.iso_code]) }
  let(:page) { create(:action_page, :name => "Donation page", :action_sequence => action_sequence) }
  let(:donation) { FactoryGirl.create(:recurring_donation) }
  let(:member) { donation.user }
  let(:movement) { donation.user.movement }

  describe "expiring_credit_card" do
    before :each do
      ActionMailer::Base.delivery_method = :test
      ENV["#{movement.slug}_CONTACT_EMAIL".upcase] = "noreply@#{movement.slug}.org"
      member.update_attribute('country_iso', :us)
      PaymentMailer.expiring_credit_card(donation).deliver
    end

    let(:delivered) { ActionMailer::Base.deliveries.last }

    it "should deliver a single email" do
      ActionMailer::Base.deliveries.size.should == 1
    end

    it "should deliver a single email with the correct to, from, and subject fields" do
      delivered.to.length.should == 1
      delivered.to.first.should == donation.user.email
      delivered.from.length.should == 1
      delivered.from.first.should == "noreply@#{movement.slug}.org"
      delivered.subject.should == "Please continue supporting #{movement.name}"
    end

    it "should deliver email with the correct body" do
      delivered.should have_body_text("Your credit card is expiring soon")
      delivered.should have_body_text(/#{member.first_name}/) if member.first_name.present?
      delivered.should have_body_text(/#{member.last_name}/) if member.last_name.present?
      delivered.should have_body_text(/#{member.postcode}/) if member.postcode.present?
      delivered.should have_body_text(/UNITED STATES/)
      delivered.should have_body_text(/#{member.email}/)
      delivered.should have_body_text("$20.00 #{donation.frequency}")
      delivered.should have_body_text("#{donation.created_at.strftime("%F")}")
      delivered.should have_body_text("#{donation.payment_method_token}")
    end
  end
end
