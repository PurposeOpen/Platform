# == Schema Information
#
# Table name: autofire_emails
#
#  id             :integer          not null, primary key
#  subject        :string(255)
#  body           :text
#  enabled        :boolean
#  action_page_id :integer
#  language_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  from           :string(255)
#  reply_to       :string(255)
#

require 'spec_helper'

describe AutofireEmail do

  context 'autofire email is destroyed' do
    it 'paranoia should preserve the record and set deleted_at' do
      autofire_email = create(:autofire_email)
      autofire_email.destroy

      AutofireEmail.with_deleted.find(autofire_email.id).should == autofire_email
    end
  end

  context 'set defaults' do
    it "should set page's default autofire subject and body when initialized" do
      action_page = create(:action_page)
      donation_module = create(:donation_module, :pages => [action_page])

      email = AutofireEmail.new(:action_page => action_page, :language => donation_module.language)

      email.enabled.should be_true
      email.from.should eql donation_module.default_autofire_sender
      email.subject.should eql donation_module.default_autofire_subject(action_page.movement)
      email.body.should eql donation_module.default_autofire_body(action_page.movement)
    end

    it "should not set page's defaults if the autofire_email is already persisted" do
      autofire_email = create(:autofire_email)
      AutofireEmail.any_instance.should_receive(:action_page).never
      AutofireEmail.find(autofire_email.id)
    end

    it 'should not set default email subject and body when initialized and its action page is not known' do
      email = AutofireEmail.new
      email.subject.should == nil
      email.body.should == nil
    end

    it 'should return default translations for body and subject when movement is not configured for translations ' do
      movement = create(:movement)
      translation_map = AutofireEmail.translated_defaults_map(movement)
      translation_map.should_not be_nil
      translation_map.should == AutoFireEmailDefaults[:common]
    end

    it 'should set default email subject and body when initialized and its action page set' do
      action_page = create(:action_page)
      petition_module = create(:petition_module, :pages => [action_page])
      email = AutofireEmail.new(:action_page => action_page, :language => petition_module.language)
      email.enabled.should be_true
      email.from.should eql AutofireEmail::DEFAULT_SENDER
      email.subject.should eql "Thanks for taking action!"
      email.body.should eql "Dear {NAME|Friend},\n\nThank you for taking action on this issue."
    end
  end

	describe 'validations,' do
		context 'two emails for the same action page and language,' do
			it 'should fail unique by action page and language validation' do
				email = create(:autofire_email, :enabled => false)
				email2 = FactoryGirl.build(:autofire_email, :action_page_id => email.action_page.id, :language_id => email.language.id, :enabled => false)

				email2.valid?.should be_false
				email2.should have(1).errors_on(:action_page_id)
			end
		end

		context 'two emails with the same action page and different languages,' do
			it 'should pass validations for both emails' do
				email = create(:autofire_email, :enabled => false)
				french = create(:french)
				email2 = FactoryGirl.build(:autofire_email, :action_page_id => email.action_page.id, :language_id => french.id, :enabled => false)

				email2.valid?.should be_true
			end
		end

		context 'enabled' do
			before do
        action_page = create(:action_page)
        petition_module = create(:petition_module, :pages => [action_page])
        @email = AutofireEmail.new(:action_page => action_page, :language => petition_module.language)
			end

      it 'should have no validation warnings on from, subject and body if they are not blank' do
				@email.should be_valid_with_warnings
			end

			it 'should have warnings on from, subject and body if they were blank' do
				clear_email_fields(@email)

        @email.should be_valid
				@email.should_not be_valid_with_warnings
				@email.errors[:from].should_not be_empty
				@email.errors[:subject].should_not be_empty
				@email.errors[:body].should_not be_empty
			end
		end

		context 'disabled' do
			it 'should not have warnings on subject and body if they are blank' do
				email = AutofireEmail.new(:enabled => false)
				clear_email_fields(email)
				email.should be_valid_with_warnings
			end
		end

		def clear_email_fields(email)
			email.subject = ''
			email.body = ''
			email.from = ''
		end

  end
end
