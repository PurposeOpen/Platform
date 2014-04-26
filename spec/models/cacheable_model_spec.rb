require "spec_helper"

describe CacheableModel do
  describe "#find_from_cache" do
    it "should load the page from cache if found" do
      page = FactoryGirl.create(:action_page, :content_modules => [FactoryGirl.create(:html_module)])
      Rails.cache.write(ActionPage.generate_cache_key(page.id), page)

      ActionPage.should_not_receive(:find)
      ActionPage.get_from_cache(page.id).should eql page
    end

    it "should retrieve the page from the db if not found in the cache" do
      Rails.cache.clear
      page = FactoryGirl.create(:action_page, :content_modules => [FactoryGirl.create(:html_module)])

      ActionPage.get_from_cache(page.id).should eql page
    end

    it "should yield the identifier to the given block, using it as the finder" do
      user = FactoryGirl.create(:user, :email => "i.am@cach.ed")
      Rails.cache.write(User.generate_cache_key(user.email), user)

      User.should_not_receive(:find_by_email)
      User.get_from_cache(user.email) do |model, identifier|
        model.find_by_email(identifier)
      end.should eql user
    end

    it "should should retrieve the object from the db if not found in the cache" do
      Rails.cache.clear
      user = FactoryGirl.create(:user, :email => "i.am@cach.ed")

      User.get_from_cache(user.email) do |model, identifier|
        model.find_by_email(identifier)
      end.should eql user
    end
  end
end
