require 'spec_helper'

describe PaymentSuccessMailer do
  let(:english) { create(:english) }
  let(:campaign) { create(:campaign, :movement => movement) }
  let(:action_sequence) { create(:published_action_sequence, :campaign => campaign, :enabled_languages => [english.iso_code]) }
  let(:page) { create(:action_page, :name => "Donation page", :action_sequence => action_sequence) }

  before :each do
    ActionMailer::Base.delivery_method = :test
    ENV["#{movement.slug}_CONTACT_EMAIL".upcase] = "noreply@#{movement.slug}.org"
  end

  describe "confirm_purchase for one_off donation" do
    let(:donation) { FactoryGirl.create(:donation) }
    let(:member) { donation.user }
    let(:movement) { donation.user.movement }
    let(:transaction) { create(:transaction, :donation => donation, :amount_in_cents =>  donation.amount_in_cents) }

    it "should deliver a single email" do
      PaymentSuccessMailer.confirm_purchase(donation, transaction).deliver
      ActionMailer::Base.deliveries.size.should == 1
    end

    it "should deliver a single email with the correct to, from, and subject fields" do
      PaymentSuccessMailer.confirm_purchase(donation, transaction).deliver
      delivered = ActionMailer::Base.deliveries.last

      delivered.to.length.should == 1
      delivered.to.first.should == member.email
      delivered.from.length.should == 1
      delivered.from.first.should == "noreply@#{movement.slug}.org"
      delivered.subject.should == "Thank you for your gift to #{movement.name}"
    end

    it "should deliver email with the correct body" do
      PaymentSuccessMailer.confirm_purchase(donation, transaction).deliver
      delivered = ActionMailer::Base.deliveries.last

      delivered.should have_body_text(/#{member.first_name}/) if member.first_name.present?
      delivered.should have_body_text(/#{member.last_name}/) if member.last_name.present?
      delivered.should have_body_text(/#{member.postcode}/) if member.postcode.present?
      delivered.should have_body_text(/UNITED STATES/)
      delivered.should have_body_text(/#{member.email}/)
      delivered.should have_body_text("$10.00")
      delivered.should have_body_text("#{transaction.created_at.strftime("%F")}")
      delivered.should have_body_text("#{transaction.external_id}")
      delivered.should_not have_body_text("To cancel or modify your recurring donation")
    end
  end

  describe "confirm_purchase for recurring donation" do
    let(:donation) { FactoryGirl.create(:recurring_donation) }
    let(:member) { donation.user }
    let(:movement) { donation.user.movement }
    let(:transaction) { FactoryGirl.create(:transaction, :donation => donation, :amount_in_cents =>  donation.amount_in_cents) }

    it "should deliver email with the correct amount for a recurring donation" do
      PaymentSuccessMailer.confirm_purchase(donation, transaction).deliver
      delivered = ActionMailer::Base.deliveries.last

      delivered.should have_body_text("To cancel or modify your recurring donation")
      delivered.should have_body_text("$20.00 #{donation.frequency}")
    end
  end

  describe "confirm_recurring_purchase" do
    let(:donation) { create(:recurring_donation) }
    let(:movement) { donation.user.movement }
    let(:transaction) { create(:transaction, :donation => donation, :amount_in_cents =>  donation.subscription_amount) }
    let(:member) { donation.user }

    before :each do
      member.update_attribute('country_iso', :us)
      PaymentSuccessMailer.confirm_recurring_purchase(donation, transaction).deliver
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
      delivered.subject.should == "Thank you for your weekly gift to #{movement.name}"
    end

    it "should deliver email with the correct body" do
      delivered.should have_body_text(/#{member.first_name}/) if member.first_name.present?
      delivered.should have_body_text(/#{member.last_name}/) if member.last_name.present?
      delivered.should have_body_text(/#{member.postcode}/) if member.postcode.present?
      delivered.should have_body_text(/UNITED STATES/)
      delivered.should have_body_text(/#{member.email}/)
      delivered.should have_body_text("$20.00 #{donation.frequency}")
      delivered.should have_body_text("#{transaction.created_at.strftime("%F")}")
      delivered.should have_body_text("#{transaction.external_id}")
    end
  end
end
