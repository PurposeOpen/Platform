require 'spec_helper'

describe ExternalTag do

  it { should validate_presence_of(:movement_id) }
  it { should validate_presence_of(:name) }

end
