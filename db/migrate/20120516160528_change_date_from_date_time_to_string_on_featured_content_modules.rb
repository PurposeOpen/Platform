class ChangeDateFromDateTimeToStringOnFeaturedContentModules < ActiveRecord::Migration
  def up
    change_table :featured_content_modules do |t|
      t.change :date, :string
    end
  end

  def down
    change_table :featured_content_modules do |t|
      t.change :date, :datetime
    end
  end
end
