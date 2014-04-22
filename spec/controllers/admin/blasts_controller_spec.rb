require "spec_helper"

describe Admin::BlastsController do
  before :each do
    @push = FactoryGirl.create(:push)
    @movement = @push.campaign.movement
    @list = FactoryGirl.create(:list)
    @valid_params = {
      :name => "Ceci nes pas une blast"
    }
    @blast = Blast.create!(@valid_params.merge(:push => @push, :list => @list))
    # mock up an authentication in the underlying warden library
    request.env['warden'] = mock(Warden, :authenticate => FactoryGirl.create(:user, :is_admin => true),
                                         :authenticate! => FactoryGirl.create(:user, :is_admin => true))
  end

  describe "responding to POST create" do
    describe "with valid params" do
      it "should create a blast and redirect to its push page" do
        post :create, :push_id => @push.id, :blast => @valid_params, :movement_id => @movement.id
        blast = assigns(:blast)
        blast.should_not be_new_record
        response.should redirect_to(admin_movement_push_path(@movement, @push))
      end
    end

    describe "with invalid params" do
      it "should not save the blast and re-render the form" do
        post :create, :push_id => @push.id, :blast => nil, :movement_id => @movement.id
        blast = assigns(:blast)
        blast.should be_new_record
        response.should render_template("blasts/new")
      end
    end
  end

  describe "responding to PUT update" do
    describe "with valid params" do
      it "should update an blast and redirect to its blast admin page" do
        put :update, :id => @blast.id, :blast => @valid_params.merge(:name => "Something Else"), :movement_id => @movement.id
        @blast.reload
        @blast.name.should == "Something Else"
        response.should redirect_to(admin_movement_push_path(@movement, @push))
      end
    end

    describe "with invalid params" do
      it "should not save the blast and re-render the form" do
        put :update, :id => @blast.id, :movement_id => @movement.id, :blast => {:name => ""}
        response.should render_template("blasts/edit")
      end
    end
  end

  describe "responding to DELETE destroy" do
    context 'completed blast delivery exists' do
      it "should not delete the blast" do

        delete :destroy, :id => @blast.id, :movement_id => @movement.id
        @blast.reload
        @blast.should be_deleted
        response.should redirect_to(admin_movement_push_path(@movement, @push))
      end
    end

    context 'no completed blast deliveries exist' do
      it "should delete the blast and redirect to push admin page" do
        delete :destroy, :id => @blast.id, :movement_id => @movement.id
        @blast.reload
        @blast.should be_deleted
        response.should redirect_to(admin_movement_push_path(@movement, @push))
      end
    end
  end

  describe "responding to POST delivery" do
    let(:run_at_param) { "#{Time.now.year+1}-12-01" }
    let(:run_at_hour_param) { "12:25" }
    let(:run_at) { DateTime.strptime("#{run_at_param} #{run_at_hour_param}", '%Y-%m-%d %H:%M').to_time.utc }

    before do
      Blast.stub(:find) { @blast }
      @list.stub(:summary) { { :number_of_selected_users => 1000 } }
    end

    describe "time parameters" do
      before(:each) do
        @blast.should_receive(:send_proofed_emails!) do |options|
          options[:run_at].should be_within(2).of(Time.now.utc+AppConstants.blast_job_delay)
        end
      end

      after(:each) do
        response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      end

      it 'schedules now regardless of time selection when selected to run now' do
        post :deliver, id: @blast.id, run_now: "true", run_at: run_at_param, 
             run_at_hour: run_at_hour_param, email_id: "all", movement_id: @movement.id 
      end

      it 'should schedule with default delay period if user has not chosen any time' do
        post :deliver, :id => @blast.id, :run_at => '', :run_at_hour => '',
             :email_id => "all", :movement_id => @movement.id
      end

      it 'should schedule with default delay period if user has not chosen any date' do
        post :deliver, :id => @blast.id, :run_at => '', :run_at_hour => run_at_hour_param,
             :email_id => "all", :movement_id => @movement.id
      end

      it 'should schedule with default delay period if user has not chosen any hour' do
        post :deliver, :id => @blast.id, :run_at => run_at_param, :run_at_hour => '',
             :email_id => "all", :movement_id => @movement.id
      end
    end

    context 'using the movement default timezone' do
      before { @movement.update_attribute(:time_zone, 'America/New_York') }

      it 'blasts the email at the given time for movement zone converted to UTC' do
        @blast.should_receive(:send_proofed_emails!)
              .with(:run_at => Time.parse('2015-12-01 17:25:00 UTC'))

        post :deliver, id: @blast.id, run_at: run_at_param, run_at_hour: run_at_hour_param,
                     email_id: "all", movement_id: @movement.id
      end
    end



    it "should blast all proofed emails" do
      @blast.should_receive(:send_proofed_emails!).with(:run_at => run_at)

      post :deliver, :id => @blast.id, :run_at => run_at_param, :run_at_hour => run_at_hour_param,
                     :email_id => "all", :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
    end

    it "should blast all proofed emails up to a given limit" do
      @blast.should_receive(:send_proofed_emails!).with(limit: 500, :run_at => run_at)

      post :deliver, :id => @blast.id, :run_at => run_at_param, :run_at_hour => run_at_hour_param,
                     :email_id => "all", :member_count_select => Blast::LIMIT_MEMBERS, :limit => 500, :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
    end

    it "should blast a given email" do
      @blast.should_receive(:send_proofed_emails!).with(email_ids: ["1"], :run_at => run_at)

      post :deliver, :id => @blast.id, :run_at => run_at_param, :run_at_hour => run_at_hour_param,
                     :email_id => "1", :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
    end

    it "should blast a given email up to a given limit" do
      @blast.should_receive(:send_proofed_emails!).with(limit: 500, email_ids: ["1"], :run_at => run_at)

      post :deliver, :id => @blast.id, :run_at => run_at_param, :run_at_hour => run_at_hour_param,
                     :email_id => "1", :member_count_select => Blast::LIMIT_MEMBERS, :limit => 500, :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
    end

    it "should return an error if limit is selected and it is not a number greater than zero" do
      @blast.should_not_receive(:send_proofed_emails!)
      time = Time.now.utc+AppConstants.blast_job_delay - 1.minute
      post :deliver, :id => @blast.id, :run_at => time.strftime('%Y-%m-%d'), :run_at_hour => time.strftime('%H:%M'),
                     :email_id => "1", :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      flash[:error].should == "Scheduled time should be in at least #{AppConstants.blast_job_delay} minutes later than current time"
    end

    it "should return error for invalid date format" do
      @blast.should_not_receive(:send_proofed_emails!)
      post :deliver, :id => @blast.id, :run_at => '12341234', :run_at_hour => '0:00',
                     :email_id => "1", :movement_id => @movement.id
      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      flash[:error].should == "Invalid date format"
    end

    it "should return an error if limit is selected and it is not a number greater than zero" do
      post :deliver, :id => @blast.id, :run_at => run_at_param, :run_at_hour => run_at_hour_param,
                     :email_id => "1", :member_count_select => Blast::LIMIT_MEMBERS, :limit => 'asdf', :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      flash[:error].should == "Limit must be a number greater than 0."
    end

    it "should return error if no recipients list is selected" do
      blast_with_no_list = Blast.create!(@valid_params.merge(:push => @push))
      Blast.stub(:find) { blast_with_no_list }

      post :deliver, :id => blast_with_no_list.id, :run_at => run_at_param, :run_at_hour => run_at_hour_param,
                     :email_id => "1", :member_count_select => Blast::ALL_MEMBERS, :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      flash[:error].should == "A non-empty list of recipients must be selected."
    end

    it "should return error if recipients list count is nil" do
      list = FactoryGirl.create(:list)
      list.stub(:summary) { nil }
      blast_with_no_list = Blast.create!(@valid_params.merge(:push => @push))
      Blast.stub(:find) { blast_with_no_list }

      post :deliver, :id => blast_with_no_list.id, :run_at => run_at_param, :run_at_hour => run_at_hour_param,
                     :email_id => "1", :member_count_select => Blast::ALL_MEMBERS, :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      flash[:error].should == "A non-empty list of recipients must be selected."
    end

    it "should return error if recipients list count is zero" do
      list = FactoryGirl.create(:list)
      list.stub(:summary) { { :number_of_selected_users => 0 } }
      blast_with_no_list = Blast.create!(@valid_params.merge(:push => @push))
      Blast.stub(:find) { blast_with_no_list }

      post :deliver, :id => blast_with_no_list.id, :run_at => run_at_param, :run_at_hour => run_at_hour_param,
                     :email_id => "1", :member_count_select => Blast::ALL_MEMBERS, :movement_id => @movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      flash[:error].should == "A non-empty list of recipients must be selected."
    end
  end
end
