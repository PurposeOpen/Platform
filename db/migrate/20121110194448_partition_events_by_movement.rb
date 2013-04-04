class PartitionEventsByMovement < ActiveRecord::Migration
  class Movement         < ActiveRecord::Base; end
  class PushSentEmail    < ActiveRecord::Base; end
  class PushSpammedEmail < ActiveRecord::Base; end
  class PushClickedEmail < ActiveRecord::Base; end
  class PushViewedEmail  < ActiveRecord::Base; end

  def up
    movements = Movement.all

    return if (movements.empty? || Rails.env != 'production') # No need for partitions in test mode.

    partitions = movements.map do |m|
      "PARTITION p_#{m.slug} VALUES IN(#{m.id})"
    end.join(', ')

    [ PushSentEmail, PushSpammedEmail, PushClickedEmail, PushViewedEmail ].each do |evts|
      execute "ALTER TABLE #{evts.table_name} PARTITION BY LIST(movement_id) (#{partitions})"
    end
  end

  def down
  end
end
