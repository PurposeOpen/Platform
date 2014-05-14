# == Schema Information
#
# Table name: petition_signatures
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  content_module_id  :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  page_id            :integer          not null
#  email_id           :integer
#  dynamic_attributes :text
#  comment            :string(255)
#

require 'spec_helper'

describe PetitionSignature do

  it 'should validate that comment is 200 characters or less' do
    excessively_long_comment = 'x' * 201
    petition_module = FactoryGirl.create(:petition_module)
    petition_signature = PetitionSignature.new(comment: excessively_long_comment,
        content_module: petition_module)

    petition_signature.valid?.should be_false
    petition_signature.errors.messages[:comment].should == ["is too long (maximum is 200 characters)"]
  end

  it 'should create a user activity event after create' do
    page = FactoryGirl.create(:action_page)
    petition_module = FactoryGirl.create(:petition_module)
    email = FactoryGirl.create(:email)
    FactoryGirl.create(:sidebar_module_link, page: page, content_module: petition_module)

    petition_signature = FactoryGirl.create(:petition_signature, page_id: page.id,
        email_id: email.id, content_module_id: petition_module.id)

    uae = UserActivityEvent.where(page_id: page.id, content_module_id: petition_module.id,
        action_sequence_id: page.action_sequence.id, campaign_id: page.action_sequence.campaign.id,
        activity: 'action_taken', user_response_id: petition_signature.id,
        user_response_type: 'PetitionSignature', email_id: petition_signature.email.id,
        movement_id: page.action_sequence.campaign.movement.id).all

    uae.count.should == 1
  end

end
