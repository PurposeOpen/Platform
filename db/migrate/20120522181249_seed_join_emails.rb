class JoinEmail < ActiveRecord::Base; end

class SeedJoinEmails < ActiveRecord::Migration
  def up
    MovementLocale.all.each do |movement_locale|
      movement_locale.join_email = JoinEmail.new(:movement_locale_id => movement_locale.id)
      movement_locale.save!
    end
  end

  def down
  end
end
