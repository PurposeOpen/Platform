# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

require "spec_helper"

describe JoinModule do
  def validated_join_module(attrs)
    default_attrs = {active: 'true'}
    pm = FactoryGirl.build(:join_module, default_attrs.merge(attrs))
    pm.valid?
    pm
  end

  describe 'defaults' do
    it "should be active by default" do
      join = JoinModule.new
      join.active.should be_true
    end

    it "should have comments enabled by default" do
      join = JoinModule.new
      join.comments_enabled.should be_true
    end

    it "should not reset comments enabled if there is already a setting for this option" do
      pm = create(:join_module, :comments_enabled => false)
      ContentModule.find(pm.id).comments_enabled.should be_false
    end

    it "should be active by default" do
      join = JoinModule.new
      join.active.should be_true
    end
  end

  describe "validation" do
    it "should warn about comment label and text if comments are enabled" do
      join_module = PetitionModule.new

      join_module.should_not be_valid_with_warnings
      join_module.errors[:comment_label].any?.should be_true
    end

    it "should require a title between 3 and 128 characters" do
      validated_join_module(:title => "Save the kittens!").should be_valid_with_warnings
      validated_join_module(:title => "X" * 128).should be_valid_with_warnings
      validated_join_module(:title => "X" * 129).should_not be_valid_with_warnings
      validated_join_module(:title => "AB").should_not be_valid_with_warnings
    end

    it "should require a button text between 1 and 64 characters" do
      validated_join_module(:button_text => "Save the kittens!").should be_valid_with_warnings
      validated_join_module(:button_text => "X" * 64).should be_valid_with_warnings
      validated_join_module(:button_text => "X" * 65).should_not be_valid_with_warnings
      validated_join_module(:button_text => "").should_not be_valid_with_warnings
    end

    it "should require a join statement" do
      validated_join_module(:button_text => "Save the kittens!").should be_valid_with_warnings
      validated_join_module(:button_text => "X" * 64).should be_valid_with_warnings
      validated_join_module(:button_text => "").should_not be_valid_with_warnings
    end

    it "should required disabled title/content if disabled" do
      validated_join_module(active: 'true', disabled_title: '', disabled_content:
        '').should be_valid_with_warnings
      validated_join_module(active: 'false', disabled_title: '', disabled_content:
        'bar').should_not be_valid_with_warnings
      validated_join_module(active: 'false', disabled_title: 'foo', disabled_content:
        '').should_not be_valid_with_warnings
      validated_join_module(active: 'false', disabled_title: 'foo', disabled_content:
        'bar').should be_valid_with_warnings
    end
  end

  describe "taking action" do
    it "should send out a join email if it hasn't been sent to that user yet" do
      join_page = FactoryGirl.create(:action_page, :name => "Join")
      join_module = FactoryGirl.create(:join_module, :pages => [join_page])
      movement = join_page.movement
      FactoryGirl.create(:join_email, :subject => "Welcome to the jungle!",
          :language => movement.languages.first, :movement => movement)
      user = FactoryGirl.create(:user, :movement => movement, :language => movement.languages.first,
          :join_email_sent => false)

      join_module.take_action(user, {}, join_page)

      user.join_email_sent.should be_true
      ActionMailer::Base.deliveries.size.should == 1
      mail = ActionMailer::Base.deliveries.first
      mail.should have_subject(/Welcome/)
    end

    it "should be an ask module, but..." do
      FactoryGirl.build(:join_module).is_ask?.should be_true
    end
  end

  describe 'as json' do
    it 'should not have post join attributes' do
      join_module = FactoryGirl.build(:join_module)

      json = join_module.to_json
      data = JSON.parse(json)

      data['options']['post_join_join_statement'].should be_nil
      data['options']['post_join_button_text'].should be_nil
      data['options']['post_join_content'].should be_nil
      data['options']['post_join_title'].should be_nil
    end

    context 'email parameter provided' do
      it 'should render post join content to json' do
        join_module = FactoryGirl.build(:join_module)

        json = join_module.to_json(:email => 'banana@hammock.com')
        data = JSON.parse(json)

        data['title'].should == 'Post join title'
        data['content'].should == 'Post join content'
        data['options']['join_statement'].should == 'Post join join statement'
        data['options']['button_text'].should == 'Post join button text'
      end

      context 'post join content is blank' do
        it 'should render pre join content to json' do
          join_module = FactoryGirl.build(:join_module,
              :button_text              => 'Join the movement!',
              :content                  => "<p>Lorem ipsum dolor sit amet</p>",
              :title                    => "Lorem Ipsum",
              :join_statement           => "We want stuff",
              :post_join_title          => "",
              :post_join_join_statement => "",
              :post_join_content        => "",
              :post_join_button_text    => ""
          )

          json = join_module.to_json(:email => 'banana@hammock.com')
          data = JSON.parse(json)

          data['title'].should == "Lorem Ipsum"
          data['content'].should == "<p>Lorem ipsum dolor sit amet</p>"
          data['options']['join_statement'].should == "We want stuff"
          data['options']['button_text'].should == 'Join the movement!'
        end
      end
    end

    context 'email parameter not provided' do
      it "it should render 'pre join' content to json" do
        join_module = FactoryGirl.build(:join_module, :title => 'title',
            :content => 'content', :join_statement => 'join statement',
            :button_text => 'button text')

        json = join_module.to_json
        data = JSON.parse(json)

        data['title'].should == 'title'
        data['content'].should == 'content'
        data['options']['join_statement'].should == 'join statement'
        data['options']['button_text'].should == 'button text'
      end
    end

    context 'member has joined' do
      it 'should render post join content to json' do
        join_module = FactoryGirl.build(:join_module)

        json = join_module.to_json(:member_has_joined => 'true')
        data = JSON.parse(json)

        data['title'].should == 'Post join title'
        data['content'].should == 'Post join content'
        data['options']['join_statement'].should == 'Post join join statement'
        data['options']['button_text'].should == 'Post join button text'
      end
    end

    it_should_behave_like "content module with disabled content", :join_module
  end
end
