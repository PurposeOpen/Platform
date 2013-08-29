class RemoveTransactionRecordsFromUserActivityEvents < ActiveRecord::Migration
  class UserActivityEvent         < ActiveRecord::Base; end

  def up
    execute "DELETE from #{UserActivityEvent.table_name} where user_response_type = 'Transaction'"
  end

  def down
  end

end
