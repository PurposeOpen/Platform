class CreateActionSequencesLanguages < ActiveRecord::Migration
  def change
    create_table :action_sequences_languages do |t|
      t.integer :action_sequence_id
      t.integer :language_id

      t.timestamps
    end
    ActionSequence.all.each do |action_sequence|
      if action_sequence.options[:enabled_languages].present?
        action_sequence.enabled_languages = action_sequence.options[:enabled_languages].map do |iso_code|
          Language.find_by_iso_code iso_code
        end.compact
        action_sequence.options.delete :enabled_languages
      else
        action_sequence.enabled_languages = action_sequence.campaign.movement.languages
      end
      action_sequence.save!
    end
  end
end
