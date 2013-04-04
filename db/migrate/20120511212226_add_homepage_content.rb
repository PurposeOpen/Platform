class AddHomepageContent < ActiveRecord::Migration
  def up
  	rename_table :homepages, :homepage_contents
  	create_table :homepages do |t|
  		t.integer :movement_id 
  	end
  	add_column :homepage_contents, :homepage_id, :integer
  	add_column :homepage_contents, :language_id, :integer
  	ActiveRecord::Base.connection.execute("SELECT id FROM movements").each do |row|
  		movement_id = row.first
  		ActiveRecord::Base.connection.execute("INSERT INTO homepages (movement_id) VALUES (#{movement_id})")
  	end
  	ActiveRecord::Base.connection.execute("SELECT homepage_contents.id, movement_locales.movement_id, movement_locales.language_id FROM homepage_contents, movement_locales WHERE homepage_contents.movement_locale_id = movement_locales.id").each do |row|
  		homepage_content_id, movement_id, language_id = row
  		homepage_id = ActiveRecord::Base.connection.execute("SELECT id FROM homepages WHERE movement_id = #{movement_id}").first.first
  		ActiveRecord::Base.connection.execute("UPDATE homepage_contents SET language_id = #{language_id}, homepage_id = #{homepage_id} WHERE id = #{homepage_content_id}")
  	end
  	remove_column :homepage_contents, :movement_locale_id
  end

  def down
  	add_column :homepage_contents, :movement_locale_id, :integer
  	ActiveRecord::Base.connection.execute("SELECT id, movement_id FROM homepages").each do |row|
  		homepage_id, movement_id = row
  		ActiveRecord::Base.connection.execute("SELECT movement_locales.id, languages.id FROM movement_locales, languages WHERE movement_locales.movement_id = #{movement_id} AND movement_locales.language_id = languages.id").each do |row|
  			movement_locale_id, language_id = row
				ActiveRecord::Base.connection.execute("UPDATE homepage_contents SET movement_locale_id = #{movement_locale_id} WHERE homepage_id = #{homepage_id} AND language_id = #{language_id}")
  		end
  	end
  	remove_column :homepage_contents, :homepage_id
  	remove_column :homepage_contents, :language_id
  	drop_table :homepages
  	rename_table :homepage_contents, :homepages
  end
end