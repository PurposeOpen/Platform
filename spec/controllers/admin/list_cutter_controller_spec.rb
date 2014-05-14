require 'spec_helper'

describe Admin::ListCutterController do
  before { login_as create(:admin_platform_user) }
  
  before(:each) do
        @movement = FactoryGirl.create(:movement)
  end

  describe "GET 'edit'" do
    it "should load an existing list object" do
      list = create(:list)
      get 'edit', list_id: list.id, movement_id:@movement.id 
      assigns(:list).should == list
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should create a new instance of the List object" do
      get 'new', movement_id:@movement.id 
      assigns(:list).should_not be_nil
      response.should be_success
    end

    it "should create a new instance and assign a blast id to it when given one" do
      blast = create(:blast)
      get 'new', blast_id: blast.id, movement_id:@movement.id 
      list = assigns(:list)
      list.should_not be_nil
      list.blast.should == blast
      response.should be_success
    end

    it "should not create a new instance for blast if already created" do
      blast = create(:blast)
      list = create(:list, blast: blast)
      get 'new', blast_id: blast.id, movement_id:@movement.id 
      list = assigns(:list)
      list.should_not be_nil
      list.should_not be_new_record
      list.blast.should == blast
      response.should be_success
    end
  end

  describe "POST 'count'" do
    it "should build a list with multiple rules of the same type" do
      blast = create(:blast)

      post 'count', blast_id: blast.id, movement_id:@movement.id, rules: {
          country_rule: {
              "0" => {activate: "1", selected_by: 'name', values: ["AUSTRALIA"]},
              "1" => {activate: "1", not: "true", selected_by: 'name', values: ["BRAZIL"]},
          },
          email_domain_rule: {"0" => {activate: "1", domain: "@gmail.com"}},
          campaign_rule: {
              "1" => {activate: "1", campaigns: "1,2,3"},
              "2" => {activate: "1", campaigns: "4"}
          }
      }

      response.should be_success

      list = assigns(:list)

      list.should_not be_nil
      list.rules.size.should == 0
      json = JSON.parse(response.body)
      json["intermediate_result_id"].should_not be_nil
      json["list_id"].should_not be_nil
    end

    it "should load and update an existing list if a valid id is given" do
      list = create(:list)
      list.add_rule :country_rule, selected_by: 'name', values: 'AUSTRALIA'
      list.save

      post 'count', list_id: list.id.to_s, blast_id: list.blast.id, movement_id:@movement.id, rules: {
          email_domain_rule: {"0" => {activate: "1", domain: "@gmail.com"}},
          country_rule: {"0" => {activate: "0", selected_by: 'name', values: "FRANCE"}}
      }

      existing_list = assigns(:list)
      existing_list.id.should == list.id
      existing_list.rules.size.should == 1
      existing_list.rules.first.domain.should == "gmail.com"
    end
  end

  describe "POST 'save'" do
    it "should build a list with multiple rules of the same type" do
      blast = create(:blast)

      post 'save', blast_id: blast.id, movement_id:@movement.id ,rules: {
          email_domain_rule: {"0" => {activate: "1", domain: "@gmail.com"}}
      }

      response.should be_success

      list = assigns(:list)

      list.should_not be_nil
      list.rules.size.should == 1
      list.saved_intermediate_result_id.should_not be_nil
      json = JSON.parse(response.body)
      json["intermediate_result_id"].should_not be_nil
      json["list_id"].should_not be_nil
    end

    it "should load and update an existing list" do
      list_intermediate_result = create(:list_intermediate_result, ready: true)
      list = create(:list, saved_intermediate_result: list_intermediate_result)
      list.add_rule :country_rule, selected_by: 'name', values: 'AUSTRALIA'
      list.save

      post 'save', list_id: list.id.to_s, blast_id: list.blast.id, movement_id:@movement.id , rules: {
          email_domain_rule: {"0" => {activate: "1", domain: "@gmail.com"}},
          country_rule: {"0" => {activate: "0", selected_by: 'name', values: "FRANCE"}}
      }

      existing_list = assigns(:list)
      existing_list.id.should == list.id
      existing_list.rules.size.should == 1
      existing_list.saved_intermediate_result_id.should_not be_nil
      existing_list.saved_intermediate_result.should_not == list_intermediate_result
    end

    it 'should raise error if blast is not list cuttable' do
      blast = create(:blast)
      create(:email, test_sent_at: Time.now, blast: blast, sent: true)

      lambda {
        post 'save', {blast_id: blast.id, movement_id:@movement.id , rules: {email_domain_rule: {"0" => {activate: "1", domain: "@gmail.com"}}}}
      }.should_not change{ListIntermediateResult.count}

      should respond_with 422
    end
  end

  describe "GET 'poll'" do
    describe 'a list that is ready' do
      let(:ready_list) { create(:list_intermediate_result, ready: true) }
      subject { get :poll, movement_id:@movement.id , result_id: ready_list.id }
      it { should render_template 'admin/list_cutter/_poll_summary' }
    end

    describe 'a list that is not ready yet' do
      let(:not_ready_list) { create(:list_intermediate_result, ready: false) }
      subject { get :poll, movement_id:@movement.id , result_id: not_ready_list.id }
      its(:code) { should eq '204' }
    end
  end

  describe "GET 'show'" do
    it "should load an existing list object" do
      list = create(:list)
      get 'show', movement_id:@movement.id , list_id: list.id
      assigns(:list).should == list
      response.should be_success
    end
  end
end
