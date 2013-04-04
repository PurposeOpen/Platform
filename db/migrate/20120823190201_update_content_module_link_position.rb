require 'ostruct'
class ContentModuleLink < ActiveRecord::Base; end

class UpdateContentModuleLinkPosition < ActiveRecord::Migration

  def up
    content_module_links = ContentModuleLink.find(:all,
      :select => "content_module_links.*, content_modules.language_id as language_id",
      :joins => "INNER JOIN content_modules ON content_modules.id = content_module_links.content_module_id",
      :order => "page_id, layout_container, language_id, position ASC")

    scope = OpenStruct.new
    
    position = 0
    content_module_links.each do |cml|
      position = new_scope?(scope, cml) ? 0 : position + 1
      cml.update_column(:position, position)
      set_scope scope, cml
    end
  end
  
  def new_scope?(scope, content_module_link)
    scope.page_id != content_module_link.page_id ||
    scope.layout_container != content_module_link.layout_container ||
    scope.language_id != content_module_link.language_id
  end

  def set_scope(scope, content_module_link)
    scope.page_id = content_module_link.page_id
    scope.layout_container = content_module_link.layout_container
    scope.language_id = content_module_link.language_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
