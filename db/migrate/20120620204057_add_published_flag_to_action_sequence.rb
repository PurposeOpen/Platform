class AddPublishedFlagToActionSequence < ActiveRecord::Migration
  def change
    add_column :action_sequences, :published, :boolean
    ActionSequence.all.each do |action_sequence|
      action_sequence.published = true
      action_sequence.save!
    end
  end
end
