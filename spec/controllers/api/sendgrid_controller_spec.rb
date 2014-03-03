require 'spec_helper'

describe Api::SendgridController do
  before(:all) do
    Delayed::Worker.delay_jobs = false
  end

  before(:each) do
    @action_page = FactoryGirl.create(:action_page)
    @movement = @action_page.movement
    @unsubscribe = FactoryGirl.create(:unsubscribe_module, pages: [@action_page])
    @campaign = FactoryGirl.create(:campaign, movement: @movement)
    @push = FactoryGirl.create(:push, campaign: @campaign)
    @blast = FactoryGirl.create(:blast, push: @push)
    @email = FactoryGirl.create(:email, blast: @blast)
    @supporter = FactoryGirl.create(:user,
                                    :email => "bob@example.com",
                                    :movement => @movement, :is_member => true)
  end


  ## Helpers

  def handle_events(json, user: AppConstants.sendgrid_events_username, password: AppConstants.sendgrid_events_password)
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
    @request.env['RAW_POST_DATA'] = json
    @request.env['HTTP_ACCEPT'] = 'application/json'

    post :event_handler, :movement_id => @movement.id
  end

  def quote(str)
    "\"#{str}\""
  end

  def find_by_email(email)
    User.find_by_email_and_movement_id(email, @movement.id)
  end

  def make_event(type, email_address, email_id)
    %[{ "event": #{quote(type.to_s)}, "email": #{quote(email_address)}, "unique_args": {"email_id": #{quote(email_id.to_s)}} }]
  end

  def make_events(events)
    "[#{events.map { |evt| make_event(*evt) }.join(',')}]"
  end

  def make_user(email)
    FactoryGirl.create(:user,
                       :email => email,
                       :movement => @movement, :is_member => true)
  end


  ## Specs

  describe '#event_handler' do
    it 'prevents unauthorized access' do
      handle_events("{}", password: "ff334444g")
      expect(response.code).to eq("401")
    end

    it 'always responds with success to authorized requests' do
      handle_events("{}")
      expect(response.code).to eq("200")
    end

    context 'with a list of events' do
      let(:supporter1) { make_user('one@example.com') }
      let(:supporter2) { make_user('two@example.com') }

      it 'processes all events' do
        expect(find_by_email(supporter1.email).is_member).to be_true
        expect(find_by_email(supporter2.email).is_member).to be_true

        events = make_events([
                              [:bounce, supporter1.email, @email.id],
                              [:spamreport, supporter2.email, @email.id]
                             ])
        handle_events(events)

        expect(response.code).to eq("200")
        expect(find_by_email(supporter1.email).is_member).to be_false
        expect(find_by_email(supporter2.email).is_member).to be_false
      end
    end

    # Correct handling of individual events is tested in the spec for SendgridEvents
  end
end
