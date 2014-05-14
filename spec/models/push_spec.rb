# == Schema Information
#
# Table name: pushes
#
#  id          :integer          not null, primary key
#  campaign_id :integer
#  name        :string(255)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "spec_helper"

describe Push do
  describe "validations" do
    it "should require a name between 3 and 64 characters" do
      Push.new(name: "Save the kittens!").should be_valid
      Push.new(name: "AB").should_not be_valid
      Push.new(name: "X" * 64).should be_valid
      Push.new(name: "Y" * 65).should_not be_valid
    end
  end


  describe "logging activities" do
    it "should log the given activity agains the appropriate push table" do
      user = FactoryGirl.create(:user)
      email = FactoryGirl.create(:email)
      push = email.blast.push

      Push.log_activity!(:email_viewed, user, email)

      push.count_by_activity(:email_viewed).should eql 1
    end
  end

  it "should return whether or not there are blasts currently being sent" do
    push = create(:push)
    in_progress_blast = create(:blast, push: push)
    blast_1 = create(:blast, push: push)
    create(:proofed_email, blast: blast_1, delayed_job_id: nil)
    push.should_not have_pending_jobs

    create(:proofed_email, blast: blast_1, delayed_job_id: 10)
    push.should have_pending_jobs
  end

  describe 'update campaign' do
    let(:sometime_in_the_past) { Time.zone.parse '2001-01-01 01:01:01' }
    let(:campaign) { create(:campaign, updated_at: sometime_in_the_past) }

    it 'should touch campaign when added' do
      @push = create(:push, campaign: campaign)
      campaign.reload.updated_at.should > sometime_in_the_past
    end

    it 'should touch campaign when updated' do
      @push = create(:push, campaign: campaign)
      campaign.update_column(:updated_at, sometime_in_the_past)
      @push.update_attributes(name: 'A new updated push')
      campaign.reload.updated_at.should > sometime_in_the_past
    end
  end
end
