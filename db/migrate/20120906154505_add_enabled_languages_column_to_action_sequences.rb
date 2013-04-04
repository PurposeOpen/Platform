class ActionSequence < ActiveRecord::Base
  has_and_belongs_to_many :enabled_languages, :class_name => Language.name
  serialize :enabled_languages_as_text, Array
end

class AddEnabledLanguagesColumnToActionSequences < ActiveRecord::Migration
  def up
    add_column :action_sequences, :enabled_languages_as_text, :text
    ActionSequence.all.each do |action_sequence|
      action_sequence.enabled_languages_as_text = []
      action_sequence.enabled_languages.each {|language| action_sequence.enabled_languages_as_text << language.iso_code.to_s}
      action_sequence.save!
    end
    drop_table :action_sequences_languages
    rename_column :action_sequences, :enabled_languages_as_text, :enabled_languages
  end

  def down
    rename_column :action_sequences, :enabled_languages, :enabled_languages_as_text
    create_table :action_sequences_languages do |t|
      t.integer :action_sequence_id
      t.integer :language_id
      t.timestamps
    end
    ActionSequence.all.each do |action_sequence|
      action_sequence.enabled_languages = Language.find_all_by_iso_code(action_sequence.enabled_languages_as_text)
    end
    remove_column :action_sequences, :enabled_languages_as_text
  end
end
