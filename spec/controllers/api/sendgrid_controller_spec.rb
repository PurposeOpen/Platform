require 'spec_helper'

describe Api::SendgridController do
  let(:movement) { FactoryGirl.create(:movement) }
  let(:user)     { FactoryGirl.create(:user, email: 'member@movement.com', movement: movement) }

  def expect_user_to_be_permanently_unsubscribed(&block)
    UserActivityEvent.should_receive(:unsubscribed!).with(user, nil)

    yield

    user.reload
    expect(user).to_not be_member
    expect(user.can_subscribe?).to be_false
  end

  describe '#event_handler' do

    it 'should return 200 in order to prevent sendgrid from retrying' do
      Delayed::Job.should_receive(:enqueue) { raise "some error" }

      post :event_handler, movement_id: movement.id, '_json' => [{}]

      expect(response.code).to eq('200')
    end

    context 'dropped:' do

      def dropped_event_params(email_address, reason)
        [{'email' =>  email_address,
          'event' =>  'dropped',
          'reason' =>  reason
         }]
      end

      context 'Unsubscribed Address' do

        it 'should unsubscribe the user' do
          UserActivityEvent.should_receive(:unsubscribed!).with(user, nil)

          post :event_handler, movement_id: movement.id, '_json' => dropped_event_params(user.email, 'Unsubscribed Address')

          user.reload
          expect(user).to_not be_member
          expect(user.can_subscribe?).to be_true
        end

      end

      context 'Bounced Address' do

        it 'should permanently unsubscribe the user' do
          expect_user_to_be_permanently_unsubscribed {
            post :event_handler, movement_id: movement.id, '_json' => dropped_event_params(user.email, 'Bounced Address')
          }
        end

      end

      context 'Spam Reporting Address' do

        it 'should permanently unsubscribe the user' do
          expect_user_to_be_permanently_unsubscribed {
            post :event_handler, movement_id: movement.id, '_json' => dropped_event_params(user.email, 'Spam Reporting Address')
          }
        end

      end

      context 'Invalid' do

        it 'should permanently unsubscribe the user' do
          expect_user_to_be_permanently_unsubscribed {
            post :event_handler, movement_id: movement.id, '_json' => dropped_event_params(user.email, 'Invalid')
          }
        end

      end

    end

    context 'bounce:' do

      it 'should permanently unsubscribe the member' do
        expect_user_to_be_permanently_unsubscribed {
          post :event_handler, movement_id: movement.id, '_json' => [{'email' =>  user.email,
                                                                      'event' =>  'bounce',
                                                                      'email_id' => '1'
                                                                      }]
        }
      end

    end

    context 'unsubscribe:' do

      it 'should unsubscribe the user and associate the event with an email' do
        email = create(:email)
        UserActivityEvent.should_receive(:unsubscribed!).with(user, email)

        post :event_handler, movement_id: movement.id, '_json' => [{'email' =>  user.email,
                                                                    'event' =>  'unsubscribe',
                                                                    'email_id' => email.id.to_s
                                                                    }]

        user.reload
        expect(user).to_not be_member
        expect(user.can_subscribe?).to be_true
      end

    end

    context 'spamreport:' do

      it 'should permanently unsubscribe the member, record a spam event, and associate both events with an email' do
        email = create(:email)
        UserActivityEvent.should_receive(:email_spammed!).with(user, email)
        UserActivityEvent.should_receive(:unsubscribed!).with(user, email)

        post :event_handler, movement_id: movement.id, '_json' => [{'email' =>  user.email,
                                                                    'event' =>  'spamreport',
                                                                    'email_id' => email.id.to_s
                                                                    }]

        user.reload
        expect(user).to_not be_member
        expect(user.can_subscribe?).to be_false
      end

    end
  end
end
