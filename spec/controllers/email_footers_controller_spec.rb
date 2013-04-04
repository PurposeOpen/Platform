require 'spec_helper'

describe Admin::EmailFootersController do

  before do
    @admin_user = FactoryGirl.create(:user, :is_admin => true)
    request.env['warden'] = mock(Warden, :authenticate => @admin_user, :authenticate! => @admin_user)

    @language1 = FactoryGirl.create(:language)
    @language2 = FactoryGirl.create(:language)
    @movement = FactoryGirl.create(:movement, :languages => [@language1, @language2])

    @first_footer = @movement.email_footers.first
    @second_footer = @movement.email_footers.last
  end

  it "should load the email footers" do
    get :index, :movement_id => @movement.id

    assigns(:email_footers).should =~ @movement.email_footers.all
  end

  it "should update the email footers" do
    post :update, :movement_id => @movement.id, :email_footer => {
      @first_footer.id => {:html => "<h5>FOOTER</h5>", :text => "FOOTER"},
      @second_footer.id  => {:html => "<h5>RODAPE</h5>", :text => "RODAPE"}
    }

    first_footer = EmailFooter.find(@first_footer.id)
    first_footer.html.should eql "<h5>FOOTER</h5>"
    first_footer.text.should eql "FOOTER"

    second_footer = EmailFooter.find(@second_footer.id)
    second_footer.html.should eql "<h5>RODAPE</h5>"
    second_footer.text.should eql "RODAPE"

    flash[:notice].should eql "Email footers updated."

    response.should redirect_to admin_movement_path(@movement)
  end

  describe 'user stampable' do
    before do
      @email_footer = FactoryGirl.create(:email_footer)
    end
    it 'should record the user that created the email footer' do
      @email_footer.created_by.should == @admin_user.full_name
    end

    it 'should record the user that updated the email footer' do
      @email_footer.update_attributes(:html => '<p>Fruit Bats</p>', :text => 'Fruit Bats')
      @email_footer.reload

      @email_footer.updated_by.should == @admin_user.full_name
    end
  end
end