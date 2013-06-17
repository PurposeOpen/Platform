require 'spec_helper'

describe EmailTrackingHash do

  describe '#self.decode,' do

    context 'valid tracking hash:' do

      it 'should return the tracked email and user' do
        email = FactoryGirl.create(:email)
        user = FactoryGirl.create(:user)
        tracking_hash = EmailTrackingHash.new(email, user).encode

        decoded_hash = EmailTrackingHash.decode(tracking_hash)

        decoded_hash.email.should == email
        decoded_hash.user.should == user
      end

    end

    context 'invalid tracking hash:' do

      it 'should return nil for tracked email and user' do
        invalid_tracking_hash = "dXNlcmlkPTAsZW1haWxpZD0w"

        decoded_hash = EmailTrackingHash.decode(invalid_tracking_hash)

        decoded_hash.email.should be_nil
        decoded_hash.user.should be_nil
      end

    end

  end

end