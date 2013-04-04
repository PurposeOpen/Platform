class AddCommentToPetitionSignatures < ActiveRecord::Migration
  def change
    add_column :petition_signatures, :comment, :string
  end
end
