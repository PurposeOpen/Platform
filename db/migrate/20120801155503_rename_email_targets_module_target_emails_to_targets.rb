class ContentModule < ActiveRecord::Base; end
class EmailTargetsModule < ContentModule; end

class RenameEmailTargetsModuleTargetEmailsToTargets < ActiveRecord::Migration
  def up
    EmailTargetsModule.all.each do |mod|
      if mod.options.is_a?(Hash)
        mod.options[:targets] = mod.options[:target_emails]
        mod.options.delete(:target_emails)
        mod.save!
      end
    end
  end

  def down
    EmailTargetsModule.all.each do |mod|
      if mod.options.is_a?(Hash)
        mod.options[:target_emails] = mod.options[:targets]
        mod.options.delete(:targets)
        mod.save!
      end
    end
  end
end
