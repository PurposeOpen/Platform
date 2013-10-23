class List < ActiveRecord::Base
end

class MigrateActionTakenRulePageIds < ActiveRecord::Migration
  def up
    List.find_each(:batch_size => 100) do |list|
      list.rules.each do |rule|
        if rule.class == ListCutter::ActionTakenRule
          rule.page_ids = rule.page_ids.split(',')
          list.save
        end
      end
    end
  end

  def down
    List.find_each(:batch_size => 100) do |list|
      list.rules.each do |rule|
        if rule.class == ListCutter::ActionTakenRule
          rule.page_ids = rule.page_ids.join(',')
          list.save
        end
      end
    end
  end
end
