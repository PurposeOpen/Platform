class AddSlugToMovement < ActiveRecord::Migration
  def up
    Movement.find_each(&:save)
  end

  def down
    # Nah.
  end
end
