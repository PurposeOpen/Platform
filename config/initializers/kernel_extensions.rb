unless Rails.env.production?
  module Kernel
    def clear_tables
      [Blast, Push, Email, ActionPage, UserActivityEvent, ActionSequence, Campaign, Event, List].each do |table|
        table.destroy_all
      end
    end
  end
end
