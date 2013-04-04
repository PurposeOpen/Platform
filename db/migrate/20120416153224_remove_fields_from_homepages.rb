class RemoveFieldsFromHomepages < ActiveRecord::Migration
  def up
    remove_column :homepages, :campaign_image
    remove_column :homepages, :campaign_url
    remove_column :homepages, :campaign_alt_text
    remove_column :homepages, :campaign2_image
    remove_column :homepages, :campaign2_url
    remove_column :homepages, :campaign2_alt_text
    remove_column :homepages, :campaign3_image
    remove_column :homepages, :campaign3_url
    remove_column :homepages, :campaign3_alt_text
  end

  def down
    add_column :homepages, :campaign_image,     :string
    add_column :homepages, :campaign_url,       :string
    add_column :homepages, :campaign_alt_text,  :string
    add_column :homepages, :campaign2_image,    :string
    add_column :homepages, :campaign2_url,      :string
    add_column :homepages, :campaign2_alt_text, :string
    add_column :homepages, :campaign3_image,    :string
    add_column :homepages, :campaign3_url,      :string
    add_column :homepages, :campaign3_alt_text, :string
  end
end
