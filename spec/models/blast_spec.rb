# == Schema Information
#
# Table name: blasts
#
#  id             :integer          not null, primary key
#  push_id        :integer
#  name           :string(255)
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  delayed_job_id :integer
#  failed_job_ids :string(255)
#

require "spec_helper"

describe Blast do
  def build_email(overrides={})
    email = create(:email, :test_sent_at => Time.now)
    email.attributes = overrides
    email.save
    email
  end

  describe "validations" do
    it "should require a name between 3 and 64 characters" do
      build(:blast, :name => "Save the kittens!").should have(0).errors_on(:name)
      build(:blast, :name => "AB").should have(1).errors_on(:name)
      build(:blast, :name => "X" * 64).should have(0).errors_on(:name)
      build(:blast, :name => "Y" * 65).should have(1).errors_on(:name)
    end
  end

  describe "proofed_emails" do
    it "should return a list of proofed emails" do
      list = create(:list)
      blast = create(:blast, :name => "Fight like a mongoose!", :list => list)
      email = build_email(:body => "Proofed", :blast => blast)
      other_email = build_email(:body => "Not proofed", :test_sent_at => nil, :blast => blast)

      blast.proofed_emails.should == [email]
    end
  end

  describe "has_pending_jobs?" do
    it "should return true if there are pending jobs" do
      list = create(:list)
      blast = create(:blast, :name => "Fight like a mongoose!", :list => list)
      email = build_email(:body => "Proofed", :blast => blast, :delayed_job_id => 10)
      build_email(:body => "Proofed", :blast => blast, :delayed_job_id => nil)

      blast.has_pending_jobs?.should be_true
    end

    it "should return false if there are no pending jobs" do
      list = create(:list)
      blast = create(:blast, :name => "Fight like a mongoose!", :list => list)
      build_email(:body => "Proofed", :blast => blast, :delayed_job_id => nil)

      blast.has_pending_jobs?.should be_false
    end
  end

  describe "send_proofed_emails!" do
    before(:each) do
      @blast = create(:blast, :name => "Save the walruses!")
      @english = create(:language)
      @spanish = create(:language)
      @english_proofed_emails = create_list(:email, 2, :test_sent_at => Time.now, :blast => @blast, :language => @english)
      @english_unproofed_email = create(:email, :test_sent_at => nil, :blast => @blast, :language => @english)
      @english_sent_email = create(:email, :test_sent_at => Time.now, :sent => true, :blast => @blast, :language => @english)
      @spanish_proofed_email = create(:email, :test_sent_at => Time.now, :blast => @blast, :language => @spanish)
      @limit = 100
      @run_at_utc = 10.days.from_now.utc
    end

    it "should enqueue only unsent proofed emails" do
      proofed_emails = [@english_proofed_emails[0], @english_sent_email]
      @blast.stub_chain(:proofed_emails, :all).and_return(proofed_emails)
      proofed_emails[0].should_receive(:enqueue_job).with(1, 0, @limit, @run_at_utc)
      proofed_emails[1].should_not_receive(:enqueue_job)
      @blast.send_proofed_emails!(limit: @limit, :run_at_utc => @run_at_utc)
    end

    it "should enqueue proofed emails grouped by language" do
      proofed_emails = [*@english_proofed_emails, @spanish_proofed_email]
      @blast.stub_chain(:proofed_emails, :all).and_return(proofed_emails)
      proofed_emails[0].should_receive(:enqueue_job).with(2, 0, @limit, @run_at_utc)
      proofed_emails[1].should_receive(:enqueue_job).with(2, 1, @limit, @run_at_utc)
      proofed_emails[2].should_receive(:enqueue_job).with(1, 0, @limit, @run_at_utc)
      @blast.send_proofed_emails!(limit: @limit, :run_at_utc => @run_at_utc)
    end

    it "should enqueue proofed emails grouped by language for given email ids" do
      proofed_emails = [@english_proofed_emails[0], @spanish_proofed_email]
      @blast.stub_chain(:proofed_emails, :for_ids, :all).and_return(proofed_emails)
      proofed_emails[0].should_receive(:enqueue_job).with(1, 0, @limit, @run_at_utc)
      proofed_emails[1].should_receive(:enqueue_job).with(1, 0, @limit, @run_at_utc)
      @blast.send_proofed_emails!(limit: @limit, email_ids: proofed_emails.map(&:id), :run_at_utc => @run_at_utc)
    end
  end

  describe "delivery" do
    let(:push) { create(:push) }
    let(:language) { create(:language) }
    let(:blast) { create(:blast, :name => "Save the walruses!", :push => push) }
    let(:list) { create(:list, :blast => blast) }

    it "should cancel the delivery of any pending, non-locked jobs" do
      list = create(:list)
      blast = Blast.create!(:name => "Save the walruses!", :list => list, :delayed_job_id => 17, :push => create(:push))

      job_double = double()
      job_double.should_receive(:destroy_all)
      Delayed::Job.should_receive(:where) do |hash|
        hash[:id].should eql 17
        hash[:locked_at].should be_nil
        job_double
      end

      blast.cancel.should be_true

      blast.reload
      blast.delayed_job_id.should be_nil
    end

    it "should return false if no job ids are available" do
      list = create(:list)
      blast = Blast.create!(:name => "Save the walruses!", :list => list, :push => create(:push))

      Delayed::Job.should_not_receive(:destroy)

      blast.cancel.should be_false
    end
  end

  describe "#remaining_time_for_existing_jobs" do
    it "should return the remaining time in seconds for any pending jobs" do
      class DelayedJob < ActiveRecord::Base;
      end
      job = DelayedJob.create(:run_at => 14.minutes.from_now)
      blast = Blast.create!(:name => "Save the walruses!", :delayed_job_id => job.id, :push => create(:push))

      blast.remaining_time_for_existing_jobs.should > 0
    end

    it "should return zero if negative result" do
      class DelayedJob < ActiveRecord::Base;
      end
      job = DelayedJob.create(:run_at => 1.minute.ago)
      blast = Blast.create!(:name => "Save the walruses!", :push => create(:push))
      build_email(:delayed_job_id => job.id, :test_sent_at => Time.now, :blast => blast)

      blast.remaining_time_for_existing_jobs.should == 0
    end

    it "should return 0 when there are no pending jobs" do
      blast = Blast.create!(:name => "Save the walruses!", :push => create(:push))
      build_email(:test_sent_at => Time.now, :blast => blast)

      blast.remaining_time_for_existing_jobs.should == 0
    end
  end

  describe "counts" do
    it "should return the latest use count" do
      blast = create(:blast)
      proofed_emails = create_list(:email, 2, :test_sent_at => Time.now, :blast => blast)
      UniqueActivityByEmail.create(activity: 'email_sent', email_id: proofed_emails[0].id, total_count: 10)
      UniqueActivityByEmail.create(activity: 'email_sent', email_id: proofed_emails[1].id, total_count: 20)
      UniqueActivityByEmail.create(activity: 'email_sent', email_id: create(:email).id, total_count: 30)

      blast.latest_sent_user_count.should == 30
    end

    it "should return the latest unsent user count" do
      list = create(:list)
      list.should_receive(:user_count).and_return(100)
      blast = create(:blast, :list => list)
      blast.should_receive(:latest_sent_user_count).and_return(90)
      blast.latest_unsent_user_count.should == 10
    end
  end

  describe 'update campaign' do
    let(:sometime_in_the_past) { Time.zone.parse '2001-01-01 01:01:01' }
    let(:campaign) { create(:campaign, :updated_at => sometime_in_the_past) }
    let(:push) { create(:push, :campaign => campaign) }

    it 'should touch campaign when added' do
      blast = create(:blast, :push => push)
      campaign.reload.updated_at.should > sometime_in_the_past
    end

    it 'should touch campaign when updated' do
      blast = create(:blast, :push => push)
      campaign.update_column(:updated_at, sometime_in_the_past)
      blast.update_attributes(:name => 'A new updated blast')
      campaign.reload.updated_at.should > sometime_in_the_past
    end
  end

  describe '#list_cuttable?' do
    before do
      @blast = create(:blast)
    end

    it 'should not be list_cuttable if an email is scheduled' do
      unscheduled_email = create(:email, :test_sent_at => Time.now, :blast => @blast, :delayed_job_id => nil)
      scheduled_email = create(:email, :test_sent_at => Time.now, :blast => @blast, :delayed_job_id => 23)
      @blast.should_not be_list_cuttable
    end

    it 'should not be list_cuttable if an email is sent' do
      unscheduled_email = create(:email, :test_sent_at => Time.now, :blast => @blast, :delayed_job_id => nil)
      sent_email = create(:email, :test_sent_at => Time.now, :blast => @blast, :delayed_job_id => nil, :sent => true)
      @blast.should_not be_list_cuttable
    end

    it 'should be list_cuttable if none of the emails is scheduled or sent' do
      unscheduled_email = create(:email, :test_sent_at => Time.now, :blast => @blast, :delayed_job_id => nil)
      @blast.should be_list_cuttable
    end
  end
end
