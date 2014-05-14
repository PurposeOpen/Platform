require 'spec_helper'

describe Admin::FeaturedContentCollectionsController do
  before do
    admin = create(:user, is_admin: true)
    @movement = create(:movement)
    @homepage = create(:homepage, movement: @movement)
    @homepage_fcc = create(:featured_content_collection, featurable: @homepage)
    content_page_collection = create(:content_page_collection, movement: @movement)
    @content_page = create(:content_page, content_page_collection: content_page_collection)
    @content_page_fcc = create(:featured_content_collection, featurable: @content_page)

    request.env['warden'] = mock(Warden, authenticate: admin, authenticate!: admin)
  end

  it 'should group featured_content_collection by featurable' do
    get :index, movement_id: @movement.id
    assigns[:featured_pages].should == {@homepage => [@homepage_fcc], @content_page => [@content_page_fcc]}
  end

  it 'should ignore featured_content_collections belonging to draft homepage' do
    @homepage.duplicate_for_preview
    get :index, movement_id: @movement.id
    assigns[:featured_pages].should == {@homepage => [@homepage_fcc], @content_page => [@content_page_fcc]}
  end
end
