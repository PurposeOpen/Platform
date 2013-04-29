require 'spec_helper'

describe Api::HealthDashboardController do
  before :each do
    Net::HTTP.stub(:get_response) { Net::HTTPOK.new(nil, 200, "") }
    @movement = FactoryGirl.create(:movement)
  end

  describe "responding to JSON" do
    it "should return the overall status for the platform" do
      get :index, :format => 'json', :movement_id=>@movement.id

      services = JSON.parse(response.body)['services']
      services['platform'].should eql "OK"
    end

    it "should return CRITICAL if the database is down" do
      ActiveRecord::Base.connection.should_receive(:execute).and_raise(ActiveRecord::StatementInvalid)
      ActiveRecord::Base.connection.should_receive(:execute)

      get :index, :format => 'json', :movement_id=>@movement.id

      services = JSON.parse(response.body)['services']
      services['platform'].should eql "CRITICAL - database is down"
      services['database'].should eql "CRITICAL - Error: ActiveRecord::StatementInvalid"
    end

    it "should return OK if the database is up and able to handle queries" do
      get :index, :format => 'json', :movement_id=>@movement.id

      services = JSON.parse(response.body)['services']
      services['platform'].should eql "OK"
      services['database'].should eql "OK"
    end

    it "should return OK if the mail service is up" do
      Net::HTTP.should_receive(:get_response).and_return(Net::HTTPOK.new(nil, 200, ""))

      get :index, :format => 'json', :movement_id=>@movement.id

      services = JSON.parse(response.body)['services']
      services['platform'].should eql "OK"
      services['mail'].should eql "OK"
    end

    it "should return CRITICAL if the mail service can't be reached" do
      Net::HTTP.should_receive(:get_response).and_raise(SocketError)

      get :index, :format => 'json', :movement_id=>@movement.id

      services = JSON.parse(response.body)['services']
      services['platform'].should eql "WARNING - mail is down"
      services['mail'].should eql "CRITICAL - Error: SocketError"
    end

    it "should return CRITICAL if the mail service returns a non-successful response" do
      Net::HTTP.should_receive(:get_response).and_return(Net::HTTPOK.new(nil, 403, ""))

      get :index, :format => 'json', :movement_id=>@movement.id

      services = JSON.parse(response.body)['services']
      services['platform'].should eql "WARNING - mail is down"
      services['mail'].should eql "CRITICAL - response code: 403"
    end
  end

  describe "responding to HTML" do
    it "should return the overall status for the platform" do
      get :index, :format => 'html', :movement_id=>@movement.id

      response.should be_success

      service_statuses = assigns(:service_statuses)
      service_statuses[:services][:platform].should eql "OK"
    end

    it "should return CRITICAL if the database is down" do
      ActiveRecord::Base.connection.should_receive(:execute).and_raise(ActiveRecord::StatementInvalid)
      ActiveRecord::Base.connection.should_receive(:execute)

      get :index, :format => 'html', :movement_id=>@movement.id

      response.should be_success
      service_statuses = assigns(:service_statuses)
      service_statuses[:services][:platform].should eql "CRITICAL - database is down"
      service_statuses[:services][:database].should eql "CRITICAL - Error: ActiveRecord::StatementInvalid"
    end

    it "should return OK if the database is up and able to handle queries" do
      get :index, :format => 'json', :movement_id=>@movement.id

      response.should be_success
      service_statuses = assigns(:service_statuses)
      service_statuses[:services][:platform].should eql "OK"
      service_statuses[:services][:database].should eql "OK"
    end

    it "should return OK if the mail service is up" do
      Net::HTTP.should_receive(:get_response).and_return(Net::HTTPOK.new(nil, 200, ""))

      get :index, :format => 'json', :movement_id=>@movement.id

      response.should be_success
      service_statuses = assigns(:service_statuses)
      service_statuses[:services][:platform].should eql "OK"
      service_statuses[:services][:mail].should eql "OK"
    end

    it "should return CRITICAL if the mail service can't be reached" do
      Net::HTTP.should_receive(:get_response).and_raise(SocketError)

      get :index, :format => 'json', :movement_id=>@movement.id

      response.should be_success
      service_statuses = assigns(:service_statuses)
      service_statuses[:services][:platform].should eql "WARNING - mail is down"
      service_statuses[:services][:mail].should eql "CRITICAL - Error: SocketError"
    end

    it "should return CRITICAL if the mail service returns a non-successful response" do
      Net::HTTP.should_receive(:get_response).and_return(Net::HTTPOK.new(nil, 403, ""))

      get :index, :format => 'json', :movement_id=>@movement.id

      response.should be_success
      service_statuses = assigns(:service_statuses)
      service_statuses[:services][:platform].should eql "WARNING - mail is down"
      service_statuses[:services][:mail].should eql "CRITICAL - response code: 403"
    end

    it "should return CRITICAL if there are dead jobs" do
      Delayed::Job.should_receive(:where).and_return([mock()])

      get :index, :format => 'html', :movement_id=>@movement.id

      response.should be_success
      service_statuses = assigns(:service_statuses)
      service_statuses[:services][:delayedJobs].should eql "CRITICAL - Dead jobs: 1"
    end

  end
end
