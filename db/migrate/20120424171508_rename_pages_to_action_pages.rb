class RenamePagesToActionPages < ActiveRecord::Migration
  def up
    ContentPage.connection.execute("UPDATE content_pages set type = 'ActionPage' where type = 'Page'")
  end

  def down
    ContentPage.connection.execute("UPDATE content_pages set type = 'Page' where type = 'ActionPage'")
  end
end
