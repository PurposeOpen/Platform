require "spec_helper"

describe Admin::CampaignsController do
  include Devise::TestHelpers # to give your spec access to helpers

  before :each do
    @movement = FactoryGirl.create :movement
    @campaign = FactoryGirl.create :campaign
    # mock up an authentication in the underlying warden library
    request.env['warden'] = mock(Warden, :authenticate => FactoryGirl.create(:user, :is_admin => true),
                                         :authenticate! => FactoryGirl.create(:user, :is_admin => true))
  end

  describe 'index' do
    let(:mock_campaigns) {mock('campaigns')}

    before do
      Movement.any_instance.should_receive(:campaigns).and_return(mock_campaigns)
    end

    it 'should list all campaigns' do
      options = {per_page: Admin::CampaignsController::PAGE_SIZE, page: '12', order: 'updated_at DESC'}

      mock_campaigns.stub(:includes) { |relationships|
        mock_campaigns.tap { |proxy|
          proxy.should_receive(:paginate).with(options).and_return([@campaign])
        }
      }

      get :index, :movement_id => @movement.id, :page => '12'
      assigns[:movement].should == @movement
      assigns[:campaigns].should == [@campaign]
    end

    it 'should list campaigns matching the query' do
      options = {per_page: Admin::CampaignsController::PAGE_SIZE, page: '12', order: 'updated_at DESC',
                conditions: ["lower(name) like ?", "%some%"]}

      mock_campaigns.stub(:includes) { |relationships|
        mock_campaigns.tap { |proxy|
          proxy.should_receive(:paginate).with(options).and_return([@campaign])
        }
      }

      get :index, :movement_id => @movement.id, :page => '12', :query => 'Some'
      assigns[:movement].should == @movement
      assigns[:campaigns].should == [@campaign]
    end
  end

  describe "correctly shows with action sequences" do
    it "should load paginated the action sequences for the campaign" do
      ActionSequence.stub(:includes) do |relationships|
        ActionSequence.tap do |proxy|
          proxy.should_receive(:paginate).with(:per_page => Admin::CampaignsController::PAGE_SIZE, :page => "3", :order => 'created_at DESC', :conditions => {:campaign_id => @campaign.id})
        end
      end

      get :show, :id => @campaign.id, :page => 3, :movement_id=>@movement.id 
    end
  end

  describe "responding to POST create" do
    describe "with valid params" do
      it "should create a campaign and redirect to its admin page" do
        post :create, :movement_id => @movement.id, :campaign => {:name => "Hello"}

        @campaign = assigns(:campaign)
        @campaign.should_not be_new_record
        response.should redirect_to(admin_movement_campaign_path(@movement, @campaign))
      end
    end

    describe "with invalid params" do
      it "should not save the campaign and re-render the form" do
        post :create, :movement_id => @movement.id, :campaign => nil
        @campaign = assigns(:campaign)
        @campaign.should be_new_record
        response.should render_template("campaigns/new")
      end
    end

    describe "responding to PUT update" do
      describe "with valid params" do
        it "should update a campaign and redirect to its admin page" do
          put :update, {:movement_id => @movement.id, :id => @campaign.id, :campaign => {:name => "Something Else"}}
          @campaign.reload
          @campaign.name.should == "Something Else"
          response.should redirect_to(admin_movement_campaign_path(@movement, @campaign))
        end
      end

      describe "with invalid params" do
        it "should not save the campaign and re-render the form" do
          put :update, {:id => @campaign.id, :campaign => {:name => ""}, :movement_id => @movement.id}
          response.should render_template("campaigns/edit")
        end
      end
    end
  end

  describe "responding to DELETE destroy" do
    it "should delete the campaign redirect to campaign index" do
      delete :destroy, :movement_id => @movement.id, :id => @campaign.id
      @campaign.reload
      @campaign.should be_deleted
      response.should redirect_to(admin_movement_campaigns_path(@movement))
    end
  end



  describe "responding to GET ask_stats_report" do
    it "should render a stats table for all asks within the campaign" do
      sequence = FactoryGirl.create(:action_sequence, :name => "Dummy Action Sequence Name", :campaign => @campaign)
      page = FactoryGirl.create(:action_page, :action_sequence => sequence, :name => "Dummy Page")
      page.content_modules << FactoryGirl.create(:donation_module)

      get :ask_stats_report, :id => @campaign.id, :movement_id => @movement.id

      csv = response.body.split("\n")
      csv[0].should == "Created,Action Sequence,Page,Ask Type,Actions,New Members,Total $,Avg. $"
      csv[1].should match /[\d-]+,Dummy Action Sequence Name,Dummy Page,Donation module,0,0/
    end
  end

  describe "responding to GET show" do
    it "should make the necessary models available" do
      page = FactoryGirl.create(:action_page, :action_sequence => FactoryGirl.create(:action_sequence, :campaign => @campaign))
      page.content_modules << FactoryGirl.create(:donation_module)
      taf_module_link1 = create(:taf_module_link)
      taf_module_link2 = create(:taf_module_link)
      share_stat1 = create(:campaign_share_stat, :campaign => @campaign, :taf_page_id => taf_module_link1.page.id)
      share_stat2 = create(:campaign_share_stat, :campaign => @campaign, :taf_page_id => taf_module_link2.page.id)
      FactoryGirl.create(:push,  :campaign => @campaign)

      get :show, :id => @campaign.id, :movement_id => @movement.id

      assigns(:campaign).should_not be_nil
      assigns(:sequences).should_not be_nil
      assigns(:pushes).should_not be_nil
      assigns(:share_stats).should == [share_stat1, share_stat2]
    end

    context 'ask stats are cached' do
      it 'should return cached ask stats' do
        Rails.cache.write("campaign_#{@campaign.id}_ask_stats_page_1", 'cached stats', :expires_in => 5.minutes)
        Campaign.should_not_receive(:paginate_by_sql)

        get :show, :id => @campaign.id, :movement_id => @movement.id

        assigns[:stats].should == 'cached stats'
      end
    end

    context 'ask stats are not cached' do
      it 'should generate ask stats' do
        Rails.cache.delete("campaign_#{@campaign.id}_ask_stats_page_1")
        Campaign.should_receive(:paginate_by_sql)

        get :show, :id => @campaign.id, :movement_id => @movement.id
      end
    end
  end

  describe "responding to GET Pushes" do
    it "should return the pushes of the given campaign" do
       push1 = create(:push, :campaign => @campaign)
       push2 = create(:push, :campaign => create(:campaign))
       get :pushes_for_combo, :id => @campaign.id, :movement_id => @movement.id
       response.should be_success
       pushes_response = JSON.parse(response.body)
       pushes_response.length.should == 1
       pushes_response[0]["label"].should == push1.name
       pushes_response[0]["value"].should == push1.id
      end
  end
end
