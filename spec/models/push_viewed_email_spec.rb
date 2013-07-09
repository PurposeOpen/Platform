require "spec_helper"

describe PushViewedEmail do

  it { should validate_presence_of(:movement_id) }
  it { should validate_presence_of(:push_id) }
  it { should validate_presence_of(:email_id) }
  it { should validate_presence_of(:user_id) }

end