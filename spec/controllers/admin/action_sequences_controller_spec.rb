require "spec_helper"

describe Admin::ActionSequencesController do
  include Devise::TestHelpers
  
  before :each do
    @movement = create(:movement)
    @campaign = create(:campaign, :movement => @movement)
    admin_platform_user = create(:user, :is_admin => true)
    request.env['warden'] = mock(Warden, :authenticate => admin_platform_user, :authenticate! => admin_platform_user)
  end
  
  describe "responding to POST create" do
    describe "with valid params" do
      it "should create a action sequence and redirect to its campaigns admin page" do
        post :create, :movement_id => @movement.id, :campaign_id => @campaign.id, :action_sequence => {:name => "Hello"}

        action_sequence = assigns(:action_sequence)
        action_sequence.should_not be_new_record
        action_sequence.campaign.should == @campaign
        response.should redirect_to(admin_movement_action_sequence_path(@movement, action_sequence))
      end
    end
    
    describe "with invalid params" do
      it "should not save the action sequence and re-render the form" do
        post :create, :movement_id => @movement.id, :campaign_id => @campaign.id, :action_sequence => {:name => "lo"}
        action_sequence = assigns(:action_sequence)
        action_sequence.should be_new_record
        response.should render_template("action_sequences/new")
      end
    end
  end
  
  describe "responding to PUT update" do
    before :each do
      @action_sequence = create(:action_sequence, :campaign => @campaign, :name => "Hello")
    end
    
    describe "with valid params" do
      it "should update a action sequence and redirect to its admin page" do
        put :update, :movement_id => @movement.id, :campaign_id => @campaign.id, :id => @action_sequence.id, :action_sequence => {:name => "Hola"}
        @action_sequence.reload
        @action_sequence.name.should == "Hola"
        response.should redirect_to(admin_movement_action_sequence_path(@movement, @action_sequence))
      end
    end
  
    describe "with invalid params" do
      it "should not save the action sequence and re-render the form" do
        put :update, :movement_id => @movement.id, :campaign_id => @campaign.id, :id => @action_sequence.id, :action_sequence => {:name => "lo"}
        @action_sequence.reload
        @action_sequence.name.should == "Hello"
        response.should render_template("action_sequences/edit")
      end
    end
  end
  
  describe "responding to PUT sort" do
    it "should reorder pages even if validation fails" do
      @action_sequence = create(:action_sequence, :campaign => @campaign, :name => "Hello")
      p1 = create(:action_page, :action_sequence => @action_sequence, :name => "sequence1")
      p2 = create(:action_page, :action_sequence => @action_sequence, :name => "sequence2")

      p1.position.should == 1
      p2.position.should == 2
      
      put :sort_pages, :id => @action_sequence.id, :page => [p2.id.to_s, p1.id.to_s], :movement_id => @movement.id
      
      p1.reload.position.should == 2
      p2.reload.position.should == 1
    end
  end

  describe "responding to PUT toggle_published_status" do
    it "should publish action sequence" do
      @action_sequence = create(:action_sequence, :published => false)

      put :toggle_published_status, :id => @action_sequence.id, :published => "true", :movement_id => @movement.id

      ActionSequence.find(@action_sequence.id).published.should be_true
    end

    it "should unpublish action sequence" do
      @action_sequence = create(:action_sequence, :published => true)

      put :toggle_published_status, :id => @action_sequence.id, :published => "false", :movement_id => @movement.id

      ActionSequence.find(@action_sequence.id).published.should be_false
    end
  end

  describe "responding to PUT toggle_enabled_language" do
    it "should enable the action sequence for a language" do
      @action_sequence = create(:action_sequence, :enabled_languages => [])

      put :toggle_enabled_language, :id => @action_sequence.id, :iso_code => 'en', :enabled => 'true', :movement_id => @movement.id

      ActionSequence.find(@action_sequence.id).enabled_languages.should == ['en']
    end

    it "should disable the action sequence for a language" do
      @action_sequence = create(:action_sequence, :enabled_languages => ['en'])

      put :toggle_enabled_language, :id => @action_sequence.id, :iso_code => 'en', :enabled => 'false', :movement_id => @movement.id

      ActionSequence.find(@action_sequence.id).enabled_languages.should == []
    end
  end

  describe "POST duplicate" do
    it "should duplicated action sequence along with action pages" do
      action_sequence = create(:action_sequence, name: "Name")
      create(:action_page, action_sequence: action_sequence)
      campaign = action_sequence.campaign
      movement = campaign.movement
      lambda { post :duplicate, movement_id: movement.id, id: action_sequence.id }.should change(ActionSequence, :count).by(1)
      response.should redirect_to(admin_movement_campaign_path(movement, campaign))
      duplicated_action_sequence = ActionSequence.where(name: "Name(1)").all.first
      duplicated_action_sequence.should_not be_nil
      duplicated_action_sequence.action_pages.size.should == 1
    end
  end

  describe "GET preview" do
    it "should preview the action sequence" do
      language = create(:language)
      action_sequence = create(:action_sequence, :campaign => @campaign, :name => "Hello")
      get :preview, :movement_id => @movement.id, :id => action_sequence.id, :iso_code => language.iso_code
      response.should be_ok
      assigns[:action_sequence].should == action_sequence
      assigns[:action_pages].should be_same_array_regardless_of_order(action_sequence.action_pages)
      assigns[:language].should == language
    end
  end

end