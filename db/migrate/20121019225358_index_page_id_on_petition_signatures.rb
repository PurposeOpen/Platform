class IndexPageIdOnPetitionSignatures < ActiveRecord::Migration
  def change
    add_index 'petition_signatures', ['page_id']
  end
end
