# == Schema Information
#
# Table name: content_module_links
#
#  id                :integer          not null, primary key
#  page_id           :integer          not null
#  content_module_id :integer          not null
#  position          :integer
#  layout_container  :string(64)
#

require "spec_helper"

describe ContentModuleLink do
  describe "acts as list" do
    it "should be scoped to the containing page" do
      page = FactoryGirl.create(:action_page)
      another_page = FactoryGirl.create(:action_page)
      content_module = FactoryGirl.create(:html_module, :pages => [page, another_page])
      3.times { ContentModuleLink.create!(:content_module => content_module, :page => another_page, :layout_container => :main_content) }
      
      first_link = ContentModuleLink.create!(:content_module => content_module, :page => page, :layout_container => :main_content)
      second_link = ContentModuleLink.create!(:content_module => content_module, :page => page, :layout_container => :main_content)
      first_link.position.should == 0
      second_link.position.should == 1
    end

    it "should be scoped to the layout container" do
      page = FactoryGirl.create(:action_page)
      content_module = FactoryGirl.create(:html_module, :pages => [page])
      3.times { ContentModuleLink.create!(:content_module => content_module, :page => page, :layout_container => :main_content) }
      
      first_sidebar_link = ContentModuleLink.create!(:content_module => content_module, :page => page, :layout_container => :sidebar)
      second_sidebar_link = ContentModuleLink.create!(:content_module => content_module, :page => page, :layout_container => :sidebar)
      first_sidebar_link.position.should == 0
      second_sidebar_link.position.should == 1
      
      fourth_main_content_link = ContentModuleLink.create!(:content_module => content_module, :page => page, :layout_container => :main_content)
      fourth_main_content_link.position.should == 3
    end

    it "should be scoped to the content module link language" do
      page = FactoryGirl.create(:action_page)
      english_content_module = FactoryGirl.create(:html_module)
      spanish_content_module = FactoryGirl.create(:html_module, :language => FactoryGirl.create(:spanish))

      first_english_link = ContentModuleLink.create!(:content_module => english_content_module, :page => page, :layout_container => :main_content)
      second_english_link = ContentModuleLink.create!(:content_module => english_content_module, :page => page, :layout_container => :main_content)
      first_spanish_link = ContentModuleLink.create!(:content_module => spanish_content_module, :page => page, :layout_container => :main_content)

      first_english_link.position.should == 0
      second_english_link.position.should == 1
      first_spanish_link.position.should == 0
    end
  end
end
