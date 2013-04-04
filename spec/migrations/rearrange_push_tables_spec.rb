require 'spec_helper'
require File.join File.dirname(__FILE__), '..', '..', 'db', 'migrate', '20121025163715_rearrange_push_tables'

describe RearrangePushTables do
  # without_transactional_fixtures do

  #   let(:email1) { create(:email) }
  #   let(:email2) { create(:email) }
  #   let(:email3) { create(:email) }
  #   let(:user) { create(:user) }

  #   let(:pushes) { [email1.blast.push, email2.blast.push, email3.blast.push] }
    # before { pushes.each { |p| p.create_activities_table } }
    # after { pushes.each { |p| p.drop_activities_table } }

    xit 'moves data from old push tables into the new tables' do
      Push.log_activity!(:email_sent, user, email1)
      sent_email1_created_at = email1.blast.push.activities.find_by_activity_and_user_id_and_email_id('email_sent', user.id, email1.id).created_at
      Push.log_activity!(:email_viewed, user, email1)
      viewed_email1_created_at = email1.blast.push.activities.find_by_activity_and_user_id_and_email_id('email_viewed', user.id, email1.id).created_at

      Push.log_activity!(:email_sent, user, email2)
      sent_email2_created_at = email2.blast.push.activities.find_by_activity_and_user_id_and_email_id('email_sent', user.id, email2.id).created_at
      Push.log_activity!(:email_viewed, user, email2)
      viewed_email2_created_at = email2.blast.push.activities.find_by_activity_and_user_id_and_email_id('email_viewed', user.id, email2.id).created_at
      Push.log_activity!(:email_clicked, user, email2)
      clicked_email2_created_at = email2.blast.push.activities.find_by_activity_and_user_id_and_email_id('email_clicked', user.id, email2.id).created_at

      Push.log_activity!(:email_sent, user, email3)
      sent_email3_created_at = email3.blast.push.activities.find_by_activity_and_user_id_and_email_id('email_sent', user.id, email3.id).created_at


      RearrangePushTables.suppress_messages { RearrangePushTables.migrate(:up) }

      all_sent_emails = PushM::SentEmail.all
      all_sent_emails.size.should == 3
      all_sent_emails_attributes = all_sent_emails.collect{|sent_email| sent_email.attributes.slice('user_id', 'push_id', 'email_id', 'created_at')}
      [{'user_id' => user.id, 'push_id' => email1.blast.push.id, 'email_id' => email1.id, 'created_at' => sent_email1_created_at},
       {'user_id' => user.id, 'push_id' => email2.blast.push.id, 'email_id' => email2.id, 'created_at' => sent_email2_created_at},
       {'user_id' => user.id, 'push_id' => email3.blast.push.id, 'email_id' => email3.id, 'created_at' => sent_email3_created_at}].should =~ all_sent_emails_attributes

      all_viewed_emails = PushM::ViewedEmail.all
      all_viewed_emails.size.should == 2
      all_viewed_emails_attributes = all_viewed_emails.collect{|viewed_email| viewed_email.attributes.slice('user_id', 'push_id', 'email_id', 'created_at')}
      [{'user_id' => user.id, 'push_id' => email1.blast.push.id, 'email_id' => email1.id, 'created_at' => viewed_email1_created_at},
       {'user_id' => user.id, 'push_id' => email2.blast.push.id, 'email_id' => email2.id, 'created_at' => viewed_email2_created_at}].should =~ all_viewed_emails_attributes

      all_clicked_emails = PushM::ClickedEmail.all
      all_clicked_emails.size.should == 1
      all_clicked_emails_attributes = all_clicked_emails.collect{|clicked_email| clicked_email.attributes.slice('user_id', 'push_id', 'email_id', 'created_at')}
      [{'user_id' => user.id, 'push_id' => email2.blast.push.id, 'email_id' => email2.id, 'created_at' => clicked_email2_created_at}].should =~ all_clicked_emails_attributes
    end

  # end
end