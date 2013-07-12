require 'spec_helper'

describe ExternalAction do

  it { should validate_presence_of(:movement_id) }
  it { should validate_presence_of(:source) }
  it { should validate_presence_of(:action_slug) }
  it { should validate_presence_of(:action_language_iso) }

end
