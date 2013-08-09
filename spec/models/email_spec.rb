# == Schema Information
#
# Table name: emails
#
#  id                :integer          not null, primary key
#  blast_id          :integer
#  name              :string(255)
#  sent_to_users_ids :text
#  subject           :string(255)
#  body              :text
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  test_sent_at      :datetime
#  delayed_job_id    :integer
#  language_id       :integer
#  from              :string(255)
#  reply_to          :string(255)
#  alternate_key_a   :string(25)
#  alternate_key_b   :string(25)
#  sent              :boolean
#

require "spec_helper"

def create_users_with_descending_randomicity(movement, emails)
  random = 5
  users = emails.inject([]) do |acc, email|
    user = create(:user, :first_name => email.split('@')[0], :email => email, :country_iso => "AU", :postcode => random.to_s.rjust(4, "0"))
    user.random = random
    user.movement = movement
    user.save!
    random -= 1
    acc << user
  end
  users
end

def tracking_hash_for(email, *users)
  users.map do |user|
    EmailTrackingHash.new(email, user).encode
  end
end

describe Email do
  def build_email(overrides={})
    email = create(:email)
    email.attributes = overrides
    email.save
    email
  end

  describe "self methods" do
    it "should return all emails scoped within a given movement" do
      without_timestamping_of do
        january, february, march = Date.strptime("2012-01-01"), Date.strptime("2012-02-01"), Date.strptime("2012-03-01")
        walkfree = create(:movement)
        walkfree_blast = create(:blast, push: create(:push, campaign: create(:campaign, movement: walkfree)))
        walkfree_email = create(:email, blast: walkfree_blast, created_at: january, updated_at: january)

        allout = create(:movement)
        allout_blast = create(:blast, push: create(:push, campaign: create(:campaign, movement: allout)))
        allout_email_1 = create(:email, blast: allout_blast, created_at: january, updated_at: february)
        allout_email_2 = create(:email, blast: allout_blast, created_at: january, updated_at: january)
        allout_email_3 = create(:email, blast: allout_blast, created_at: march, updated_at: march)

        Email.page_options(walkfree.id).should == [[walkfree_email.name, walkfree_email.id]]
        Email.page_options(allout.id).should == [[allout_email_3.name, allout_email_3.id], [allout_email_1.name, allout_email_1.id], [allout_email_2.name, allout_email_2.id]]
      end
    end
  end

  describe "validation" do
    it "requires all fields to be present" do
      build_email.should be_valid
      build_email(:blast => nil).should_not be_valid
      build_email(:name => "").should_not be_valid
      build_email(:from => "").should_not be_valid
      build_email(:subject => "").should_not be_valid
      build_email(:body => "").should_not be_valid
    end

    it 'should validate from with valid format' do
      build_email(:from => 'A B').should_not be_valid
      build_email(:from => 'A B <a@b.com>').should be_valid
      build_email(:from => 'a@b.co').should be_valid
    end
  end

  it 'should get its footer' do
    english = create(:english)
    walkfree = create(:movement, :languages => [english])

    blast = create(:blast, :push => create(:push, :campaign => create(:campaign, :movement => walkfree)) )
    email = create(:email, :language => english, :blast => blast)

    email.footer.should == walkfree.movement_locales.first.email_footer
  end

  it 'should get its movement' do
    english = create(:english)
    walkfree = create(:movement, :languages => [english])

    blast = create(:blast, :push => create(:push, :campaign => create(:campaign, :movement => walkfree)) )
    email = create(:email, :language => english, :blast => blast)

    email.movement.should == walkfree
  end

  describe "delivery" do
    it "should deliver a test email to the default test recipient and mark it as a sent test" do
      email = build_email(:body => "awesome", :subject=>"stuff")
      email_double = double()
      SendgridMailer.stub(:blast_email) { email_double }
      SendgridMailer.should_receive(:blast_email).with(email, :recipients => [ Email::DEFAULT_TEST_EMAIL_RECIPIENT ], :test => true)
      email_double.should_receive(:deliver)

      email.test_sent_at.should be_nil
      email.send_test!
      Email.find(email.id).test_sent_at.should_not be_nil
    end

    it "should deliver a test emails to the default test recipient and the provided email addresses" do
      email = build_email(:body => "awesome", :subject=>"stuff")
      email_double = double()
      SendgridMailer.stub(:blast_email) { email_double }
      SendgridMailer.should_receive(:blast_email).with(email, :recipients => ['another_recipient@gmail.com', Email::DEFAULT_TEST_EMAIL_RECIPIENT], :test => true)
      email_double.should_receive(:deliver)

      email.send_test!(['another_recipient@gmail.com'])
    end

    it "should replace links content with URL for plain text" do
      email = build_email(:body => "Pls click <a href=\"http://somewhere.com\">here</a>")
      email.plain_text_body.should == "Pls click http://somewhere.com?t={TRACKING_HASH|NOT_AVAILABLE}"

      email = build_email(:body => "Pls click <a href=\"http://somewhere.com\"><span>this is the link</span></a>")
      email.plain_text_body.should == "Pls click http://somewhere.com?t={TRACKING_HASH|NOT_AVAILABLE}"

      email = build_email(:body => "Pls click <a href=\"http://somewhere.com\"><img src='http://example.com/my_image.jpg' /></a>")
      email.plain_text_body.should == "Pls click http://somewhere.com?t={TRACKING_HASH|NOT_AVAILABLE}"
    end

    it "should pre-process the body for html" do
      email = build_email(:body => "Pls click <a href=\"http://somewhere.com\">here</a>")
      email.html_body.should == "Pls click <a href=\"http://somewhere.com?t={TRACKING_HASH|NOT_AVAILABLE}\">here</a>"
    end

    it "should pre-process the body for plain text" do
      email = build_email(:body => "Pls click <a href=\"http://somewhere.com\">here</a>")
      email.plain_text_body.should == "Pls click http://somewhere.com?t={TRACKING_HASH|NOT_AVAILABLE}"

      email = build_email(:body => "Pls click <a href=\"http://somewhere.com\">http://somewhere.com</a>")
      email.plain_text_body.should == "Pls click http://somewhere.com?t={TRACKING_HASH|NOT_AVAILABLE}"
    end

    it "should clear test_sent_at upon saving an email" do
      email = create(:email, :body => "Pls click <a href=\"http://somewhere.com\">here</a>", :test_sent_at => Time.now)

      email.test_sent_at.should_not be_nil
      email.clear_test_timestamp!
      email.test_sent_at.should be_nil
    end
  end

  describe "blast" do
    before do
      AppConstants.stub(:enable_unfiltered_blasting) { true }
    end

    it "should send a blast to all recipients in a given list up to the specified limit" do
      list = create(:list)
      list.add_rule(:country_rule, :country_iso => "AU")
      list.save

      english = create(:english)
      walkfree = create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english])
      users = create_users_with_descending_randomicity(walkfree, ['another_recipient@gmail.com', 'james@metallica.com', 'dave@megadeth.com', 'scott@anthrax.com', 'slash@slash.com'])
      email = build_email(:language => english, :body => "Hello {NAME|Friend}! Pls click <a href=\"http://somewhere.com\">here</a>. Oh and you probably live near {POSTCODE|Nowhere}")
      email.movement = walkfree
      slash_hash, scott_hash, dave_hash = tracking_hash_for(email, users[4], users[3], users[2])

      expected_sendgrid_header = {
        :to => ['dave@megadeth.com', 'scott@anthrax.com', 'slash@slash.com'],
        :category => [
          "push_#{email.blast.push.id}", "blast_#{email.blast.id}", "email_#{email.id}", walkfree.friendly_id, Rails.env, email.language.iso_code
        ],
        :sub => {
          "{NAME|Friend}" => ["dave", "scott", "slash"],
          "{POSTCODE|Nowhere}" => ["0003", "0002", "0001"],
          "{TRACKING_HASH|NOT_AVAILABLE}" => [dave_hash, scott_hash, slash_hash]
        },
        :unique_args => { :email_id => email.id }
      }

      email.deliver_blast_in_batches([users[4],users[3],users[2]].map(&:id))

      ActionMailer::Base.deliveries.size.should eql(1)
      delivered = ActionMailer::Base.deliveries.last
      delivered.header['X-SMTPAPI'].value.should eq expected_sendgrid_header.to_json
    end

    it "should batch up email delivery" do
      english = create(:english)
      walkfree = create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english])
      leonardo = create(:user, :email=> 'leonardo@borges.com', :is_member => true, :movement => walkfree)
      another_dude = create(:user, :email=> 'another@dude.com', :is_member => true, :movement => walkfree)
      email_to_send = create(:email_with_tokens, :language => english)
      email_to_send.blast.push.campaign.movement = walkfree
      email_to_send.save!

      email_to_send.deliver_blast_in_batches([leonardo, another_dude].map(&:id), 1)

      email_to_send.blast.push.count_by_activity(:email_sent).should eql 2
      ActionMailer::Base.deliveries.size.should eql(2)
    end


    it "should not send mails when SendGrid interaction is disable" do
      english = create(:english)
      walkfree = create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english])
      leonardo = create(:user, :email=> 'leonardo@borges.com', :is_member => true, :movement => walkfree)
      another_dude = create(:user, :email=> 'another@dude.com', :is_member => true, :movement => walkfree)
      email_to_send = create(:email_with_tokens, :language => english)
      email_to_send.blast.push.campaign.movement = walkfree
      email_to_send.save!

      ENV['DISABLE_SENDGRID_INTERACTION'] = 'true'

      email_to_send.deliver_blast_in_batches([leonardo, another_dude].map(&:id), 1)

      ActionMailer::Base.deliveries.size.should eql(0)
    end

    it "should log push issues" do
      user1 = create(:user, :email=> 'leonardo@borges.com', :is_member => true)
      user2 = create(:user, :email=> 'another@dude.com', :is_member => true)
      email_to_send = create(:email_with_tokens, :delayed_job_id => 666)
      User.stub(:select) { raise Exception.new("Damn!") }
      email_to_send.deliver_blast_in_batches([user1, user2].map(&:id), 1)

      PushLog.count.should eql 2
      email_to_send.delayed_job_id.should be_nil
    end
  end

  describe "enqueue_job" do
    it "should queue the job on a given time" do
      number_of_jobs = 1
      current_job_index = 0
      limit = 100
      run_at = Time.now.utc + 14.minutes
      email = create(:email)
      Delayed::Job.should_receive(:enqueue).with  do |blast_job, options|
        options[:run_at].to_s.should == run_at.in_time_zone(Time.zone).to_s
        blast_job.options[:no_jobs].should == number_of_jobs
        blast_job.options[:current_job_id].should == current_job_index
        blast_job.options[:limit].should == limit
        blast_job.email.should == email
        blast_job.list.should == email.blast.list
      end.and_return(mock(Delayed::Job, id: 100))
      email.should_receive(:solr_index)
      email.enqueue_job(number_of_jobs, current_job_index, limit, run_at)
    end
  end

  describe 'remaining_time_to_send' do
    it 'should return 0 when theres no delayed job for self' do
      build(:email, :delayed_job_id => nil).remaining_time_to_send.should be_zero
    end

    it 'should return the time remaining when there is a delayed job for self' do
      class DelayedJob < ActiveRecord::Base;
      end
      job = DelayedJob.create(:run_at => 3.minutes.from_now.utc)
      email = create(:email, :delayed_job_id => job.id)
      time_remaining = email.remaining_time_to_send
      time_remaining.should be_a_kind_of(Fixnum)
      time_remaining.should be >= 170
      time_remaining.should be <= 180
    end
  end

  describe 'cancel' do
    it 'should cancel the delivery of any pending, non-locked jobs' do
      job_double = double()
      job_double.should_receive(:destroy_all)
      Delayed::Job.should_receive(:where).with(:id => 17, :locked_at => nil).and_return(job_double)
      email = create(:email, :delayed_job_id => 17)
      email.cancel_schedule.should be_true
      email.reload.delayed_job_id.should be_nil
    end

    it 'should return false when there is an exception' do
      job_double = double()
      job_double.should_receive(:destroy_all).and_raise("Some Exception")
      Delayed::Job.should_receive(:where).with(:id => 17, :locked_at => nil).and_return(job_double)
      email = create(:email, :delayed_job_id => 17)
      email.cancel_schedule.should be_false
    end

    it "should return false if no job ids are available" do
      build(:email, :delayed_job_id => nil).cancel_schedule.should be_false
    end
  end

  describe 'update campaign' do
    let(:sometime_in_the_past) { Time.zone.parse '2001-01-01 01:01:01' }
    let(:campaign) { create(:campaign, :updated_at => sometime_in_the_past) }
    let(:blast) { create(:blast, :push => create(:push, :campaign => campaign)) }

    it 'should touch campaign when added' do
      create(:email, :blast => blast)
      campaign.reload.updated_at.should > sometime_in_the_past
    end

    it 'should touch campaign when updated' do
      email = create(:email, :blast => blast)
      campaign.update_column(:updated_at, sometime_in_the_past)
      email.update_attributes(:name => 'A new updated email')
      campaign.reload.updated_at.should > sometime_in_the_past
    end
  end

  describe 'schedulable' do
    before do
      class DelayedJob < ActiveRecord::Base;
      end

      @scheduled_email = create(:email, :delayed_job_id => DelayedJob.create(:run_at => 2.days.from_now).id, :sent => false)
      # @scheduled_email = create(:email, :delayed_job_id => 99, :sent => false)
      @sent_email = create(:email, :delayed_job_id => nil, :sent => true)
      @schedulable_email = create(:email, :delayed_job_id => nil, :sent => false)
      @schedulable_email2 = create(:email, :delayed_job_id => nil, :sent => nil)
    end

    it "should return unsent and unassigned to a delayed_job as schedulable_emails" do
      Email.schedulable_emails.any? { |e| !e.delayed_job.nil? || e.sent }.should be_false
      Email.schedulable_emails.include?(@schedulable_email).should be_true
      Email.schedulable_emails.include?(@schedulable_email2).should be_true
    end

    it "schedulable? should return false if sent or assigned to delayed_job" do
      @scheduled_email.schedulable?.should be_false
      @sent_email.schedulable?.should be_false
      @schedulable_email.schedulable?.should be_true
      @schedulable_email2.schedulable?.should be_true
    end
  end
end
