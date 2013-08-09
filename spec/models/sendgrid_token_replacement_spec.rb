require "spec_helper"

describe SendgridTokenReplacement do
  include SendgridTokenReplacement

  it "should always contain the tracking info in the substitutions hash" do
    english = FactoryGirl.create(:english)
    walkfree = FactoryGirl.create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english]) 
    donald = FactoryGirl.create(:leo, :first_name => "Donald", :movement => walkfree)
    steve = FactoryGirl.create(:brazilian_dude, :first_name => "Steve", :movement => walkfree)
    email_to_send = FactoryGirl.create(:email_with_tokens, :body => "No links here", :language => english, :language => english)
    donald_hash = Base64.urlsafe_encode64("userid=#{donald.id},emailid=#{email_to_send.id}")
    steve_hash = Base64.urlsafe_encode64("userid=#{steve.id},emailid=#{email_to_send.id}")
    users = User.select("users.id, users.first_name, users.last_name, users.postcode").where("email in (?)", [donald.email, steve.email]).order("users.id")

    expected_hash = {
                       "{NAME|Friend}" => ["Donald", "Steve"],
                       "{TRACKING_HASH|NOT_AVAILABLE}" => [donald_hash, steve_hash]
                    }

    generate_replacement_tokens(email_to_send, users).should == expected_hash
  end

  it "should generate substitutions hash based on the email body and the given users" do
    english = FactoryGirl.create(:english)
    walkfree = FactoryGirl.create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english])
    leo = FactoryGirl.create(:leo, :first_name => "Leo", :email => "leo@yourdomain.com", :movement => walkfree)
    steve = FactoryGirl.create(:brazilian_dude, :first_name => "Steve", :email => "steve@yourdomain.com", :movement => walkfree)
    email_to_send = FactoryGirl.create(:email_with_tokens, :language => english)
    email_to_send.movement = walkfree
    leo_hash = Base64.urlsafe_encode64("userid=#{leo.id},emailid=#{email_to_send.id}")
    steve_hash = Base64.urlsafe_encode64("userid=#{steve.id},emailid=#{email_to_send.id}")
    users = User.where("email in (?)", [leo.email, steve.email]).order("users.id")

    expected_hash = {
      "{NAME|Friend}" => ["Leo", "Steve"],
      "{EMAIL|}" => ["leo@yourdomain.com", "steve@yourdomain.com"],
      "{MOVEMENT_URL|}" => [ walkfree.url, walkfree.url ],
      "{POSTCODE|Nowhere}" => ["9999", "9999"],
      "{TRACKING_HASH|NOT_AVAILABLE}" => [leo_hash, steve_hash]
    }

    generate_replacement_tokens(email_to_send, users).should == expected_hash
  end

  it "should generate substitutions hash with default values based on the email body and the given users" do
    english = FactoryGirl.create(:english)
    walkfree = FactoryGirl.create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english])
    email_to_send = FactoryGirl.create(:email_with_tokens, :language => english)
    donald = FactoryGirl.create(:leo, :first_name => nil, :movement => walkfree)
    steve = FactoryGirl.create(:brazilian_dude, :first_name => nil, :movement => walkfree)
    email_to_send = FactoryGirl.create(:email_with_tokens, :language => english)
    donald_hash = Base64.urlsafe_encode64("userid=#{donald.id},emailid=#{email_to_send.id}")
    steve_hash = Base64.urlsafe_encode64("userid=#{steve.id},emailid=#{email_to_send.id}")

    expected_hash = {
      "{EMAIL|}" => [""],
      "{MOVEMENT_URL|}" => [ "" ],
      "{NAME|Friend}" => ["Friend"],
      "{POSTCODE|Nowhere}" => ["Nowhere"],
      "{TRACKING_HASH|NOT_AVAILABLE}" => ["NOT_AVAILABLE"]
    }

    generate_replacement_tokens(email_to_send, []).should == expected_hash
  end

  describe "#get_substitutions_list" do
    it "should return default tokens for test blasts" do
      english = FactoryGirl.create(:english)
      walkfree = FactoryGirl.create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english])
      email_to_send = FactoryGirl.create(:email_with_tokens, :language => english)
      email_to_send.movement = walkfree
      leo = FactoryGirl.create(:leo, :first_name => "Leonardo", :email => "leo@yourdomain.com", :movement => walkfree)
      leo_hash = Base64.urlsafe_encode64("userid=#{leo.id},emailid=#{email_to_send.id}")
      expected_hash = {
        "{EMAIL|}" => ["non-member@gmail.com", "leo@yourdomain.com"],
        "{MOVEMENT_URL|}" => [ walkfree.url, walkfree.url ],
        "{NAME|Friend}" => ["Friend", "Leonardo"],
        "{POSTCODE|Nowhere}" => ["Nowhere", "9999"],
        "{TRACKING_HASH|NOT_AVAILABLE}" => ["NOT_AVAILABLE", "NOT_AVAILABLE" ]
      }

      get_substitutions_list(email_to_send, :recipients => ["non-member@gmail.com", leo.email], :test => true).should == expected_hash
    end

    it "should scope users by the email's movement" do
      english = FactoryGirl.create(:english)
      walkfree = FactoryGirl.create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english])
      allout = FactoryGirl.create(:movement, :name => "AllOut", :url => "http://allout.org", :languages => [english])
      email_to_send = FactoryGirl.create(:email_with_tokens, :language => english)
      email_to_send.movement = allout
      
      leo_walkfree_member = FactoryGirl.create(:user, :first_name => "Leo WalkFree", :email => "leo@yourdomain.com", :postcode => "01234", :movement => walkfree)
      leo_allout_member = FactoryGirl.create(:user, :first_name => "Leo AllOut", :email => "leo@yourdomain.com", :postcode => "43210", :movement => allout)

      expected_hash = {
        "{EMAIL|}" => ["leo@yourdomain.com"],
        "{MOVEMENT_URL|}" => ["http://allout.org"],
        "{NAME|Friend}" => ["Leo AllOut"],
        "{POSTCODE|Nowhere}" => ["43210"],
        "{TRACKING_HASH|NOT_AVAILABLE}" => [Base64.urlsafe_encode64("userid=#{leo_allout_member.id},emailid=#{email_to_send.id}") ]
      }

      get_substitutions_list(email_to_send, :recipients => ["leo@yourdomain.com"], :test => false).should == expected_hash
    end

    it "should scan the subject line for tokens" do
      english = FactoryGirl.create(:english)
      walkfree = FactoryGirl.create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english])
      email_to_send = FactoryGirl.create(:email_with_tokens, :body => "no tokens", :subject => "Hey, {NAME|Friend}!", :language => english)
      email_to_send.movement = walkfree
      leo = FactoryGirl.create(:leo, :first_name => "Leonardo", :movement => walkfree)
      leo_hash = Base64.urlsafe_encode64("userid=#{leo.id},emailid=#{email_to_send.id}")
      expected_hash = {
        "{TRACKING_HASH|NOT_AVAILABLE}" => [leo_hash, "NOT_AVAILABLE"],
        "{NAME|Friend}" => ["Leonardo", "Friend"]
      }

      get_substitutions_list(email_to_send, :recipients => ["non-member@gmail.com", leo.email], :test => false).should == expected_hash
    end
  end
end
