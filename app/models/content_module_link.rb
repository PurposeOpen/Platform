# == Schema Information
#
# Table name: content_module_links
#
#  id                :integer          not null, primary key
#  page_id           :integer          not null
#  content_module_id :integer          not null
#  position          :integer
#  layout_container  :string(64)
#

class ContentModuleLink < ActiveRecord::Base
  belongs_to :page
  belongs_to :content_module
  acts_as_list top_of_list: 0

  def move_to_container(new_container, new_position)
    remove_from_list
    update_attribute :layout_container, new_container
    insert_at new_position
  end

  def layout_container
    str = read_attribute(:layout_container)
    str ? str.to_sym : nil
  end

  def scope_condition
    content_module_ids = ContentModule.where("content_modules.language_id = ?", content_module.language_id)
                                      .pluck("content_modules.id").join(",")
    "page_id=#{page_id} AND layout_container=\'#{layout_container}\' AND content_module_id IN (#{content_module_ids})"
  end
end
