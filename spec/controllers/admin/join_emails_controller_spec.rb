require "spec_helper"

describe Admin::JoinEmailsController do
  before do
    @admin_user = FactoryGirl.create(:user, :is_admin => true)
    request.env['warden'] = mock(Warden, :authenticate => @admin_user, :authenticate! => @admin_user)

    @language1 = FactoryGirl.create(:language)
    @language2 = FactoryGirl.create(:language)
    @movement = FactoryGirl.create(:movement, :languages => [@language1, @language2])

    @first_email = @movement.join_emails.first
    @second_email = @movement.join_emails.last
  end

  it "should load the join emails" do
    get :index, :movement_id => @movement.id

    assigns(:join_emails).should =~ @movement.join_emails.all
  end

  it "should update the join emails" do
    post :update, :movement_id => @movement.id, :join_emails => {
      @first_email.id => {:subject => "New subject", :body => "New body", :reply_to => 'coconut@bongos.com'},
      @second_email.id  => {:subject => "Novo assunto", :body => "Novo conteudo", :reply_to => 'banana@hammock.com'}
    }

    first_email = JoinEmail.find(@first_email.id)
    second_email = JoinEmail.find(@second_email.id)
    first_email.subject.should eql "New subject"
    first_email.reply_to.should eql 'coconut@bongos.com'
    second_email.subject.should eql "Novo assunto"
    second_email.reply_to.should eql  'banana@hammock.com'

    flash[:notice].should eql "Join emails updated."

    response.should redirect_to admin_movement_path(@movement)
  end

  describe 'user stampable' do
    before do
      @join_email = FactoryGirl.create(:join_email)
    end
    it 'should record the user that created the join email' do
      @join_email.created_by.should == @admin_user.full_name
    end

    it 'should record the user that updated the join email' do
      @join_email.update_attribute(:subject, 'Fruit Bats')
      @join_email.reload

      @join_email.updated_by.should == @admin_user.full_name
    end
  end

end