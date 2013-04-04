class UpgradeFriendlyIdGem < ActiveRecord::Migration
  SLUGGED_MODELS = [Movement, Campaign, ActionSequence, Page]

  def up
    add_column :pages, :movement_id, :integer
    SLUGGED_MODELS.each do |model_class|
      add_column model_class.table_name.to_sym, :slug, :string
      add_index model_class.table_name.to_sym, :slug
      model_class.unscoped.find_each(&:save)
    end
  end

  def down
    SLUGGED_MODELS.each do |model_class|
      remove_index model_class.table_name.to_sym, :slug
      remove_column model_class.table_name.to_sym, :slug
    end
  end
end
