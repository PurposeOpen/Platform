class RemoveSlugsTable < ActiveRecord::Migration

  def up
    regenerate_slugs_and_ensure_they_exist Movement
    regenerate_slugs_and_ensure_they_exist Campaign
    regenerate_slugs_and_ensure_they_exist ActionSequence
    regenerate_slugs_and_ensure_they_exist Page

    drop_table :slugs
  end

  def down
    create_table "slugs", :force => true do |t|
      t.string   "name"
      t.integer  "sluggable_id"
      t.integer  "sequence", :default => 1, :null => false
      t.string   "sluggable_type", :limit => 40
      t.string   "scope"
      t.datetime "created_at"
    end

    move_slugs_to_slugs_table Movement
    move_slugs_to_slugs_table Campaign
    move_slugs_to_slugs_table ActionSequence
    move_slugs_to_slugs_table Page
    move_slugs_to_slugs_table GetTogether
    move_slugs_to_slugs_table Event
  end

  private

  def regenerate_slugs_and_ensure_they_exist(clazz)
    clazz.unscoped.all.each do |entity|
      entity.send(:set_slug)
      entity.save(:validate => false)
    end
    if clazz.unscoped.exists?(:slug => nil)
      raise "Could not create slugs for all records of '#{clazz.name}'."
    end
  end

  def move_slugs_to_slugs_table(clazz)
    clazz.unscoped.all.each do |entity|
      name = entity.slug
      sluggable_id = entity.id
      sluggable_type = clazz.name
      ActiveRecord::Base.connection.execute("INSERT INTO slugs (name, sluggable_id, sluggable_type) VALUES ('#{name}', #{sluggable_id}, '#{sluggable_type}')")
    end
    remove_column clazz.table_name, :slug
  end
end
