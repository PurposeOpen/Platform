require 'spec_helper'
require File.join File.dirname(__FILE__), '..', '..', 'db', 'migrate', '20120823190201_update_content_module_link_position'

describe UpdateContentModuleLinkPosition do

  before do
    english = FactoryGirl.create(:english)
    spanish = FactoryGirl.create(:spanish)

    petition_page = FactoryGirl.create(:action_page)
    @petition_english_header_module_1_link  = create_link(petition_page, english, :header, 10)
    @petition_english_header_module_2_link  = create_link(petition_page, english, :header, 15)
    @petition_english_sidebar_module_1_link = create_link(petition_page, english, :sidebar, 20)
    @petition_english_sidebar_module_2_link = create_link(petition_page, english, :sidebar, 25)
    @petition_english_sidebar_module_3_link = create_link(petition_page, english, :sidebar, 30)
    
    @petition_spanish_header_module_1_link  = create_link(petition_page, spanish, :header, 11)
    @petition_spanish_header_module_2_link  = create_link(petition_page, spanish, :header, 16)
    @petition_spanish_sidebar_module_1_link = create_link(petition_page, spanish, :sidebar, 21)
    @petition_spanish_sidebar_module_2_link = create_link(petition_page, spanish, :sidebar, 26)
    @petition_spanish_sidebar_module_3_link = create_link(petition_page, spanish, :sidebar, 31)
    @petition_spanish_sidebar_module_4_link = create_link(petition_page, spanish, :sidebar, 36)

    donation_page = FactoryGirl.create(:action_page)
    @donation_english_header_module_1_link  = create_link(donation_page, english, :header, 10)
    @donation_english_header_module_2_link  = create_link(donation_page, english, :header, 15)
    @donation_english_sidebar_module_1_link = create_link(donation_page, english, :sidebar, 20)
    @donation_english_sidebar_module_2_link = create_link(donation_page, english, :sidebar, 25)
    @donation_english_sidebar_module_3_link = create_link(donation_page, english, :sidebar, 30)
    
    @donation_spanish_header_module_1_link  = create_link(donation_page, spanish, :header, 11)
    @donation_spanish_header_module_2_link  = create_link(donation_page, spanish, :header, 16)
    @donation_spanish_sidebar_module_1_link = create_link(donation_page, spanish, :sidebar, 21)
    @donation_spanish_sidebar_module_2_link = create_link(donation_page, spanish, :sidebar, 26)
    @donation_spanish_sidebar_module_3_link = create_link(donation_page, spanish, :sidebar, 31)
    @donation_spanish_sidebar_module_4_link = create_link(donation_page, spanish, :sidebar, 36)
  end

  def create_link(page, language, container, position)
    content_module = FactoryGirl.create(:html_module, language: language)
    ContentModuleLink.create!(position: position, content_module: content_module, page: page, layout_container: container)
  end

  describe 'up' do
    it 'updates the position of all content module links based on the page, layout container and language they belong to' do
      UpdateContentModuleLinkPosition.suppress_messages do
        UpdateContentModuleLinkPosition.migrate(:up)
      end
      
      @petition_english_header_module_1_link.reload.position.should  == 0
      @petition_english_header_module_2_link.reload.position.should  == 1
      @petition_english_sidebar_module_1_link.reload.position.should == 0
      @petition_english_sidebar_module_2_link.reload.position.should == 1
      @petition_english_sidebar_module_3_link.reload.position.should == 2

      @petition_spanish_header_module_1_link.reload.position.should  == 0
      @petition_spanish_header_module_2_link.reload.position.should  == 1
      @petition_spanish_sidebar_module_1_link.reload.position.should == 0
      @petition_spanish_sidebar_module_2_link.reload.position.should == 1
      @petition_spanish_sidebar_module_3_link.reload.position.should == 2
      @petition_spanish_sidebar_module_4_link.reload.position.should == 3

      @donation_english_header_module_1_link.reload.position.should  == 0
      @donation_english_header_module_2_link.reload.position.should  == 1
      @donation_english_sidebar_module_1_link.reload.position.should == 0
      @donation_english_sidebar_module_2_link.reload.position.should == 1
      @donation_english_sidebar_module_3_link.reload.position.should == 2

      @donation_spanish_header_module_1_link.reload.position.should  == 0
      @donation_spanish_header_module_2_link.reload.position.should  == 1
      @donation_spanish_sidebar_module_1_link.reload.position.should == 0
      @donation_spanish_sidebar_module_2_link.reload.position.should == 1
      @donation_spanish_sidebar_module_3_link.reload.position.should == 2
      @donation_spanish_sidebar_module_4_link.reload.position.should == 3
    end
  end
end