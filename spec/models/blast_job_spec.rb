require "spec_helper"

describe BlastJob do
  let(:no_jobs) { 2 }
  let(:current_job_id) { 0 }
  let(:limit) { 10 }
  let(:user_ids) { [1,2,3] }
  let(:email) { FactoryGirl.create(:email, :test_sent_at => Time.now, :delayed_job_id => 10)}
  let(:list_intermediate_result) { FactoryGirl.create(:list_intermediate_result) }
  let(:list) { FactoryGirl.create(:list, :saved_intermediate_result => list_intermediate_result) }

  it "should perform the job" do
    list.should_receive(:filter_by_rules_excluding_users_from_push).with(email, hash_including(
      :limit => limit,
      :no_jobs => no_jobs,
      :current_job_id => current_job_id
    )).and_return(user_ids)
    email.should_receive(:deliver_blast_in_batches).with(user_ids)
    email.delayed_job_id.should_not be_nil

    job = BlastJob.new(
      :no_jobs => no_jobs,
      :current_job_id => current_job_id,
      :list => list,
      :email => email,
      :limit => limit
    )
    job.perform

    email.reload
    email.delayed_job_id.should be_nil
    email.should be_sent
  end

  it "should update the list intermediate results just before sending the emails" do
    list.should_receive(:filter_by_rules_excluding_users_from_push).with(email, hash_including(
      :limit => limit,
      :no_jobs => no_jobs,
      :current_job_id => current_job_id
    )) do
      email.should_receive(:deliver_blast_in_batches).with(user_ids) do
        list_intermediate_result.should_receive(:update_results!).once
      end
      user_ids
    end

    job = BlastJob.new(
      :no_jobs => no_jobs,
      :current_job_id => current_job_id,
      :list => list,
      :email => email,
      :limit => limit
    )

    job.perform
  end

  it "should remove the email delayed_job_id if the emailer throws an exception" do
    list.should_receive(:filter_by_rules_excluding_users_from_push).with(email, hash_including(:limit => limit, :no_jobs => no_jobs, :current_job_id => current_job_id)).and_return(user_ids)

    email.should_receive(:deliver_blast_in_batches).with(user_ids).and_raise RuntimeError

    job = BlastJob.new(
      :no_jobs => no_jobs,
      :current_job_id => current_job_id,
      :list => list,
      :email => email,
      :limit => limit
    )

    lambda { job.perform }.should raise_error RuntimeError

    email.reload
    email.delayed_job_id.should be_nil
    email.should_not be_sent
    PushLog.count.should eql 1
  end
end
