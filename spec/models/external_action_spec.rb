# == Schema Information
#
# Table name: external_actions
#
#  id                  :integer          not null, primary key
#  movement_id         :integer          not null
#  source              :string(255)      not null
#  partner             :string(255)
#  action_slug         :string(255)      not null
#  unique_action_slug  :string(255)      not null
#  action_language_iso :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'spec_helper'

describe ExternalAction do

  it { should validate_presence_of(:movement_id) }
  it { should validate_presence_of(:source) }
  it { should validate_presence_of(:action_slug) }
  it { should validate_presence_of(:action_language_iso) }

end
