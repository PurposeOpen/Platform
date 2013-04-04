class ProfanalyzeNamesAndComments < ActiveRecord::Migration
  def up
    User.where(:name_safe => nil).all.each do |user|
      user.update_column(:name_safe, !Profanalyzer.profane?(user.name))
    end

    UserActivityEvent.where(:comment_safe => nil).all.each do |uae|
      uae.update_column(:comment_safe, !Profanalyzer.profane?(uae.comment))
    end
  end
end
