# == Schema Information
#
# Table name: homepages
#
#  id          :integer          not null, primary key
#  movement_id :integer
#  draft       :boolean          default(FALSE)
#

require 'spec_helper'
describe Homepage do
  before do
    @homepage = create(:homepage)
    @content1 = create(:homepage_content, :homepage => @homepage)
    @featured_content_collection = create(:featured_content_collection, :featurable => @homepage)
    @featured_content_modules = 2.times.collect{create(:featured_content_module, :featured_content_collection => @featured_content_collection)}
  end

  describe "duplicate_for_preview" do
    it 'should duplicate the current homepage with homepage_content attributes' do
      clone = @homepage.duplicate_for_preview({:homepage_content =>{@content1.iso_code => {:banner_image => "A NEW IMAGE URL FOR PREVIEW"}}}.with_indifferent_access)

      clone.should be_draft
      @homepage.homepage_contents.size.should == clone.homepage_contents.size
      @homepage.homepage_contents.first.attributes.except("id", "homepage_id", "updated_at", 'banner_image').should ==
        clone.homepage_contents.first.attributes.except("id", "homepage_id", "updated_at", 'banner_image')
      clone.homepage_contents.first.banner_image.should == "A NEW IMAGE URL FOR PREVIEW"
      clone.should have(2).featured_content_modules
      clone.featured_content_modules.first.attributes.except('id', 'created_at', 'updated_at', 'featured_content_collection_id').should ==
        @featured_content_modules.first.attributes.except('id', 'created_at', 'updated_at', 'featured_content_collection_id')
      clone.featured_content_modules.last.attributes.except('id', 'created_at', 'updated_at', 'featured_content_collection_id').should ==
        @featured_content_modules.last.attributes.except('id', 'created_at', 'updated_at', 'featured_content_collection_id')
    end

    it 'should duplicate the current homepage with featured_content_modules attributes' do
      first_fcm, last_fcm = @featured_content_modules
      first_fcm_update_attributes = {"title" => "The Rules at Rio+20", "image" => "", "description" => "The Rules will be at Rio + 20.", "url" => "http://therules.org", "button_text" => "Take Action", "date" => ""}
      last_fcm_update_attributes = {"title" => "One more", "image" => "SOME IMAGE", "description" => "A desc", "url" => "", "button_text" => "", "date" => "12/12/2013"}

      clone = @homepage.duplicate_for_preview({"featured_content_modules" => {first_fcm.id => first_fcm_update_attributes, last_fcm.id => last_fcm_update_attributes}}.with_indifferent_access)

      clone.should be_draft
      @homepage.homepage_contents.size.should == clone.homepage_contents.size
      @homepage.homepage_contents.first.attributes.except("id", "homepage_id", "updated_at").should == clone.homepage_contents.first.attributes.except("id", "homepage_id", "updated_at")
      clone.should have(2).featured_content_modules
      clone.featured_content_modules.first.attributes.except('id', 'created_at', 'updated_at', 'featured_content_collection_id').should == first_fcm_update_attributes.merge('language_id' => first_fcm.language_id, 'position' => first_fcm.position)
      clone.featured_content_modules.last.attributes.except('id', 'created_at', 'updated_at', 'featured_content_collection_id').should == last_fcm_update_attributes.merge('language_id' => last_fcm.language_id, 'position' => last_fcm.position)
    end
  end

  context 'destroy' do
    it 'should destroy all featured_content_collections and homepage_contents' do
      @homepage.destroy
      expect{@homepage.reload}.to raise_error(ActiveRecord::RecordNotFound)
      expect{@content1.reload}.to raise_error(ActiveRecord::RecordNotFound)
      expect{@featured_content_collection.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
