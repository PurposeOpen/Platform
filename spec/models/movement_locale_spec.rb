# == Schema Information
#
# Table name: movement_locales
#
#  id          :integer          not null, primary key
#  movement_id :integer
#  language_id :integer
#  default     :boolean          default(FALSE)
#

require 'spec_helper'

describe MovementLocale do

  describe 'ensure join email exists' do

    context "a join email exists when the movement locale is created" do

      it "should not create a new one" do
        movement_locale = FactoryGirl.build(:movement_locale)
        movement_locale.join_email = FactoryGirl.build(:join_email,
            :movement_locale => movement_locale,
            :subject => "Welcome here!",
            :body => "It's good to have you!")
        
        movement_locale.save!

        movement_locale.join_email.subject.should eql "Welcome here!"
        movement_locale.join_email.body.should eql "It's good to have you!"
      end
    end

    context "a join email does not exist when the movement locale is created" do

      it "should create a new one with no defaults" do
        movement_locale = FactoryGirl.create(:movement_locale, :join_email => nil)

        movement_locale.join_email.should_not be_nil
        movement_locale.join_email.subject.should eql ""
        movement_locale.join_email.body.should eql ""
        movement_locale.join_email.from.should eql ""
        movement_locale.join_email.reply_to.should eql ""
      end
    end

  end

  describe 'ensure email footer exists' do

    context "an email footer exists when the movement locale is created" do

      it "should not create a new one" do
        movement_locale = FactoryGirl.build(:movement_locale)
        movement_locale.email_footer = FactoryGirl.build(:email_footer, :movement_locale => movement_locale)
        movement_locale.save!

        movement_locale.reload
        MovementLocale.find(movement_locale.id).email_footer.should == movement_locale.email_footer
      end
    end

    context "an email footer does not exist when the movement locale is created" do

      it "should create a new one" do
        movement_locale = FactoryGirl.create(:movement_locale, :email_footer => nil)
        movement_locale.email_footer.should_not be_nil
      end
    end

  end
end
