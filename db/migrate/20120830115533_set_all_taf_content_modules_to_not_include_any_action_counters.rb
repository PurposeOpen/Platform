class SetAllTafContentModulesToNotIncludeAnyActionCounters < ActiveRecord::Migration
  def up
    TellAFriendModule.all.each do |content_module|
    	content_module.include_action_counter = false
    	content_module.save
    end
  end

  def down
  	TellAFriendModule.all.each do |content_module|
  		content_module.include_action_counter = nil
  	end
  end
end
